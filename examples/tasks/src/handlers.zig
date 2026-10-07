//! Typed HTTP work produces queue effects; the consumer owns delivery work.

const std = @import("std");
const am = @import("akamata");
const App = @import("app.zig").App;
const Task = @import("models.zig").Task;

const Ctx = am.Context(App);

/// The Repo type generated for our model. It exposes `find / all / where /
/// create / save / delete`, all of which take the live `Db` handle and an
/// allocator (typically the request arena).
const Tasks = am.model.repo(Task);

// =========================================================================
// Endpoint descriptors carry handler-derived metadata for both generators.
// =========================================================================

/// Wire-format wrappers that name the request/response shapes. We *could*
/// use the bare `Task` struct in both directions, but giving the input
/// payload its own name (`CreateTaskInput`) makes the generated TS read
/// `client.postTasks(input: CreateTaskInput)` instead of `client.postTasks(input: Task)`,
/// which would also include the auto-assigned `id` and `created_at`.
pub const CreateTaskInput = struct {
    title: []const u8,
    description: []const u8 = "",

    // Input types carry their own validation declarations so `c.input(T)`
    // checks them on the way in. We mirror the model's constraints rather
    // than relying on the Repo to fail at INSERT time — failing at the
    // boundary gives a 422 with field-level errors instead of a 500.
    pub const validation = Task.__schema.validates;
};

pub const UpdateTaskInput = struct {
    // All fields nullable — clients send only what they want to change.
    title: ?[]const u8 = null,
    description: ?[]const u8 = null,
    done: ?bool = null,

    // Validators see optional == null as "field not supplied" and skip
    // the length/format/range rules — so min_len(1) below only fires
    // when the client actually sent `"title": "..."` with an empty
    // string, never when the field is omitted. PATCH semantics work.
    pub const __schema = .{
        .validates = .{
            .title = .{ am.model.rule.min_len(1), am.model.rule.max_len(120) },
            .description = .{am.model.rule.max_len(2000)},
        },
    };
};

pub const TaskList = struct {
    tasks: []const Task,
};

pub const ListQuery = struct {
    /// Filter: `done=true` returns only completed tasks. Any value
    /// other than the string `"true"` or `"1"` is treated as false.
    done: ?[]const u8 = null,
};

pub fn health() []const u8 {
    return "ok";
}

pub fn listTasks(c: *Ctx, done: am.Query(?bool, "done")) !TaskList {
    const tasks = try Tasks.all(c.db(), c.arena);
    if (done.value) |want_done| {
        var filtered: std.ArrayList(Task) = .empty;
        for (tasks) |t| if (t.done == want_done) try filtered.append(c.arena, t);
        return .{ .tasks = filtered.items };
    }
    return .{ .tasks = tasks };
}
pub fn createTask(c: *Ctx, body: am.Json(CreateTaskInput)) !am.Result(Task, 201) {
    const created = try Tasks.create(c.db(), c.arena, .{ .title = body.value.title, .description = body.value.description });
    // DB commit and external queue admission are distinct effects. See README.
    const id = try std.fmt.allocPrint(c.arena, "task:{d}", .{created.id.?});
    try c.queue().dispatchDescriptor(c.arena, @import("contract.zig").TaskCreatedDescriptor, .{ .task_id = created.id.? }, .{ .event_id = id, .idempotency_key = id, .correlation_id = c.requestId() });
    return am.created(created);
}
pub fn showTask(c: *Ctx, id: am.Path(i64, "id")) !Task {
    return (try Tasks.find(c.db(), c.arena, id.value)) orelse error.NotFound;
}
pub fn updateTask(c: *Ctx, id: am.Path(i64, "id"), body: am.Json(UpdateTaskInput)) !Task {
    var task = (try Tasks.find(c.db(), c.arena, id.value)) orelse return error.NotFound;
    if (body.value.title) |t| task.title = t;
    if (body.value.description) |d| task.description = d;
    if (body.value.done) |d| task.done = d;
    try Tasks.save(c.db(), c.arena, &task);
    try emitEvent(c, "task.updated", task);
    return task;
}
pub fn deleteTask(c: *Ctx, id: am.Path(i64, "id")) !struct { deleted: i64 } {
    _ = (try Tasks.find(c.db(), c.arena, id.value)) orelse return error.NotFound;
    try Tasks.delete(c.db(), id.value);
    try emitEvent(c, "task.deleted", .{ .id = id.value });
    return .{ .deleted = id.value };
}

// =========================================================================
// SSE: live updates
// =========================================================================

/// `GET /events` — open-ended event stream. The client uses `EventSource`
/// to subscribe; we push a `data: {json}` payload every time a task is
/// touched. A periodic heartbeat keeps the connection alive through
/// proxies that drop idle streams.
pub fn streamEvents(c: *Ctx) !void {
    if (comptime am.backend == .workers) return c.json(.{ .error_kind = "NativeSseOnly" }, 501);
    const channel = c.state().events orelse return c.json(.{ .error_kind = "NativeSseOnly" }, 501);
    // Pick up the client's Last-Event-ID if it reconnected; we'll skip
    // events with seq <= that.
    var since: u64 = 0;
    if (c.req.header("last-event-id")) |s| {
        since = std.fmt.parseInt(u64, s, 10) catch 0;
    }

    // `am.sse.open` sets text/event-stream + cache-control: no-cache and
    // commits the response headers immediately. The returned Sse hands us
    // a `.send(...) / .heartbeat()` API on top of chunked transfer encoding.
    var sse = try am.sse.open(c);

    // Cap the stream lifetime: the request thread is otherwise pinned
    // forever, and load tests would happily DoS us. 60 s + a JS-side
    // reconnect on close is the standard SSE pattern.
    const deadline_ms = 60_000;
    const poll_ms: u32 = 50;
    const start = am.observability.clock.monotonicNs();
    var beat_ms: u32 = 0;

    while (am.observability.clock.elapsedNs(start) / std.time.ns_per_ms < deadline_ms) {
        if (channel.pollAfter(since)) |slot| {
            // Convert the seq to a string id so the client can resume.
            var id_buf: [24]u8 = undefined;
            const id_str = try std.fmt.bufPrint(&id_buf, "{d}", .{slot.seq});
            try sse.send(.{ .id = id_str, .event = "task", .data = slot.bytes[0..slot.len] });
            since = slot.seq;
            beat_ms = 0;
            continue;
        }
        sleepMs(poll_ms);
        beat_ms +|= poll_ms;
        if (beat_ms >= 15_000) {
            try sse.heartbeat();
            beat_ms = 0;
        }
    }
    // Falling off the loop closes the stream gracefully — the client
    // will get a clean EOF and reopen.
}

// =========================================================================
// Background job handler
// =========================================================================

/// Explicit consumer context borrowed by either queue owner. Duplicate delivery
/// uses a primary-key guard; an event is not an exactly-once guarantee.
pub const Effects = struct { db: am.db.Db, events: ?*@import("app.zig").EventChannel = null };
pub fn consumeCreated(raw: *anyopaque, payload: @import("contract.zig").TaskCreated, delivery: am.queue.Delivery) !void {
    const effects: *Effects = @ptrCast(@alignCast(raw));
    var stmt = try effects.db.prepare("INSERT INTO task_deliveries(event_id, task_id, attempt) VALUES (?, ?, ?) ON CONFLICT(event_id) DO NOTHING");
    defer stmt.deinit();
    try stmt.bindAll(.{ delivery.event_id, payload.task_id, delivery.attempt });
    _ = try stmt.step();
    if (effects.events) |channel| {
        var buffer: [256]u8 = undefined;
        const bytes = try std.fmt.bufPrint(&buffer, "{{\"kind\":\"task.notified\",\"task_id\":{d}}}", .{payload.task_id});
        try channel.publish(bytes);
    }
}

// The metadata view needs no live providers. Explicit anyerror breaks the
// normal Zig inference cycle: Application → handler → Application.Metadata.
pub fn openapiSpec(c: *Ctx) anyerror!void {
    var metadata: @import("setup.zig").Application.Metadata = .{};
    const fw = &metadata;
    const spec = try am.openapi.generate(@TypeOf(fw.*), fw, c.arena, .{
        .title = "Akamata Tasks API",
        .version = "1.0.0",
        .description = "Example task tracker showing best-practice usage of Akamata.",
    });
    try c.res.header("content-type", "application/json");
    try c.res.writeAll(spec);
}

pub fn typescriptClient(c: *Ctx) anyerror!void {
    var metadata: @import("setup.zig").Application.Metadata = .{};
    const fw = &metadata;
    const ts = try am.client_gen.generate(@TypeOf(fw.*), fw, c.arena, .{
        .target = .typescript,
        .base_url = "http://localhost:8080",
    });
    try c.res.header("content-type", "application/typescript");
    try c.res.writeAll(ts);
}

// =========================================================================
// Helpers
// =========================================================================

/// Encode `payload` as JSON and push it into the SSE channel. The handler
/// passes either a `Task` value or an `{ id }` shape; both serialize fine.
fn emitEvent(c: *Ctx, kind: []const u8, payload: anytype) !void {
    var aw: std.Io.Writer.Allocating = .init(c.arena);
    try std.json.Stringify.value(.{ .kind = kind, .payload = payload }, .{}, &aw.writer);
    if (c.state().events) |channel| try channel.publish(aw.written());
}

extern "c" fn usleep(usecs: c_uint) c_int;
fn sleepMs(ms: u32) void {
    _ = usleep(@as(c_uint, ms) * 1000);
}
