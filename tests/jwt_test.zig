// Re-run inline tests from src/auth/jwt.zig through the public API.
const std = @import("std");
const am = @import("akamata");

test "JWT HS256 sign and verify round-trip" {
    var arena_state: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const Payload = struct { sub: []const u8, exp: i64 };
    const tok = try am.auth.jwt.sign(arena, "k", Payload{ .sub = "u", .exp = 9_999_999_999 });
    const c = try am.auth.jwt.verify(arena, "k", tok, 1_000_000_000);
    try std.testing.expectEqualStrings("u", c.sub.?);
}

test "JWT rejects wrong secret" {
    var arena_state: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const Payload = struct { sub: []const u8, exp: i64 };
    const tok = try am.auth.jwt.sign(arena, "k1", Payload{ .sub = "u", .exp = 9_999_999_999 });
    try std.testing.expectError(am.auth.jwt.JwtError.InvalidSignature, am.auth.jwt.verify(arena, "k2", tok, null));
}

const JwtState = struct {};
fn jwtOk(c: *am.Context(JwtState)) !void {
    try c.text("ok");
}
fn fixedNow() i64 {
    return 1_000;
}

fn dispatchJwt(token: []const u8, comptime require_exp: bool) !u16 {
    var app = am.App(JwtState).init(std.testing.allocator, .{});
    defer app.deinit();
    _ = try app.useAll(am.mw.jwt(JwtState, .{
        .secret = "01234567890123456789012345678901",
        .require_exp = require_exp,
        .now_fn = fixedNow,
    }));
    _ = try app.get("/", jwtOk);
    var arena_state: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena_state.deinit();
    const authorization = try std.fmt.allocPrint(arena_state.allocator(), "Bearer {s}", .{token});
    var req: am.Request = .{ .method = .GET, .raw_method = "GET", .path = "/", .query = "", .version = "HTTP/1.1", .headers = &.{.{ .name = "authorization", .value = authorization }}, .body = "", .keep_alive = false };
    var res = am.Response.init(arena_state.allocator());
    try app.dispatchWithPeer(arena_state.allocator(), &req, &res, null, null, null);
    return res.status_code;
}

test "JWT middleware enforces exp and nbf with injected clock" {
    var arena_state: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const secret = "01234567890123456789012345678901";
    const expired = try am.auth.jwt.sign(arena, secret, .{ .sub = "u", .exp = 1000 });
    try std.testing.expectEqual(@as(u16, 401), try dispatchJwt(expired, true));
    const future = try am.auth.jwt.sign(arena, secret, .{ .sub = "u", .exp = 2000, .nbf = 1001 });
    try std.testing.expectEqual(@as(u16, 401), try dispatchJwt(future, true));
    const valid = try am.auth.jwt.sign(arena, secret, .{ .sub = "u", .exp = 2000, .nbf = 999 });
    try std.testing.expectEqual(@as(u16, 200), try dispatchJwt(valid, true));
    const missing = try am.auth.jwt.sign(arena, secret, .{ .sub = "u" });
    try std.testing.expectEqual(@as(u16, 401), try dispatchJwt(missing, true));
    try std.testing.expectEqual(@as(u16, 200), try dispatchJwt(missing, false));
}

// This key is a public test fixture, never an application credential.
test "optional OpenSSL binding signs RSA SHA256 with the expected wire bytes" {
    const signature = am.crypto.rs256.signPem(std.testing.allocator, @embedFile("fixtures/rs256_test_key.pem"), "Akamata translated OpenSSL binding test") catch |err| {
        if (err == error.UnsupportedOnTarget) return error.SkipZigTest;
        return err;
    };
    defer std.testing.allocator.free(signature);
    try std.testing.expectEqual(@as(usize, 256), signature.len);
    const hex = std.fmt.bytesToHex(signature[0..256].*, .lower);
    try std.testing.expectEqualStrings("b856aac4f186413e061d620dcccc6839403ff8efbe1fee7b1c2e2f2f81541b6982952d7eaccd6284e343ec40441a60ef45cf6e0137965fd23a66ec5d7b3004b04a9517e582f26c6bf3dfec307b1083995203c68907881fd4fa62b425f4696e5901dbb07d7f10144060053c2986392b26e321759808879c38ea6946adacc61951ffb21dc2f236cb40827d26f06f0d4e18c848b49b9216fe915d9bbbac88a200f6601990dc312ecf16cd87aa8777c42cbf6b478da86c4406ea919fea2c47006a2726f604e24002e3c15aeec612fb1a2efb8bb06e4028225e9bbd549ceee063245be76e7eacc47e3f17fc7d3401bb7ec6909c995a3e6ef47dffb3adb72e8a545d37", &hex);
    try std.testing.expectError(error.KeyLoadFailed, am.crypto.rs256.signPem(std.testing.allocator, "invalid PEM", "message"));
}
