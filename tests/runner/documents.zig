const std = @import("std");
const s = @import("support.zig");
pub fn links(h: s.H) !void {
    var documents: std.ArrayList([]const u8) = .empty;
    try documents.appendSlice(h.a, &.{ "README.md", "README.ja.md", "examples/README.md" });
    for ([_][]const u8{ "en", "ja" }) |language| {
        for ([_][]const u8{ "README.md", "quickstart.md", "tutorial.md", "handbook.md", "handler-api.md", "public-performance.md", "db-pool.md", "performance-reliability.md" }) |name|
            try documents.append(h.a, try h.fmt("docs/{s}/{s}", .{ language, name }));
        var dir = try std.Io.Dir.cwd().openDir(h.io, try h.fmt("docs/{s}/guides", .{language}), .{ .iterate = true });
        defer dir.close(h.io);
        var it = dir.iterate();
        while (try it.next(h.io)) |entry| if (std.mem.endsWith(u8, entry.name, ".md")) {
            try documents.append(h.a, try h.fmt("docs/{s}/guides/{s}", .{ language, entry.name }));
        };
    }
    var examples = try std.Io.Dir.cwd().openDir(h.io, "examples", .{ .iterate = true });
    defer examples.close(h.io);
    var it = examples.iterate();
    while (try it.next(h.io)) |entry| {
        const path = try h.fmt("examples/{s}/README.md", .{entry.name});
        if (h.exists(path)) try documents.append(h.a, path);
    }
    for (documents.items) |path| {
        const data = try h.read(path);
        var offset: usize = 0;
        while (std.mem.indexOfPos(u8, data, offset, "](")) |start| {
            const end = std.mem.indexOfScalarPos(u8, data, start + 2, ')') orelse break;
            offset = end + 1;
            const url = data[start + 2 .. end];
            if (std.mem.indexOf(u8, url, "://") != null or std.mem.startsWith(u8, url, "#")) continue;
            const fragment = std.mem.indexOfScalar(u8, url, '#') orelse url.len;
            const target = try h.fmt("{s}/{s}", .{ std.fs.path.dirname(path) orelse ".", url[0..fragment] });
            if (!h.exists(target)) {
                std.debug.print("broken documentation link: {s}: {s}\n", .{ path, url });
                return error.BrokenDocumentationLink;
            }
        }
    }
    std.debug.print("developer documentation links: {d} documents passed\n", .{documents.items.len});
}

/// Poppler reads the PDF format; all contract assertions live here in Zig.
pub fn slides(h: s.H) !void {
    for ([_][]const u8{ "en", "ja" }) |language| {
        const html = try h.read(if (std.mem.eql(u8, language, "en")) "tools/docgen/slides.html" else "tools/docgen/slides.ja.html");
        try s.check(std.mem.count(u8, html, "<section class=\"slide") == 13, "13 source slides");
        const path = try h.fmt("docs/{s}/slides.pdf", .{language});
        const info = try h.run(&.{ "pdfinfo", "-f", "1", "-l", "13", "-box", path }, null, null);
        var page_sizes: usize = 0;
        var lines = std.mem.splitScalar(u8, info, '\n');
        while (lines.next()) |line| {
            if (std.mem.startsWith(u8, line, "Pages:")) try s.eq(std.mem.trim(u8, line[6..], " \t"), "13");
            if (std.mem.startsWith(u8, line, "Page ")) if (std.mem.indexOf(u8, line, "size:")) |offset| {
                var words = std.mem.tokenizeAny(u8, line[offset + 5 ..], " \t");
                const width = try std.fmt.parseFloat(f64, words.next() orelse return error.MissingWidth);
                try s.eq(words.next() orelse "", "x");
                const height = try std.fmt.parseFloat(f64, words.next() orelse return error.MissingHeight);
                try s.check(@abs(width - 960) < 1 and @abs(height - 540) < 1, "slide dimensions");
                page_sizes += 1;
            };
        }
        try s.check(page_sizes == 13, "all PDF page dimensions checked");
        const text = try h.run(&.{ "pdftotext", "-layout", path, "-" }, null, null);
        var pages = std.mem.splitScalar(u8, text, 12);
        for (0..13) |_| try s.check(std.mem.trim(u8, pages.next() orelse return error.MissingPage, " \t\r\n").len > 80, "nonblank slide");
        for ([_][]const u8{ "fn hello()", "expectStatus", "0.17.0" }) |needle| try s.contains(text, needle);
        for ([_][]const u8{ "0.16", "v0.0.1", "ready for production", "Cloudflare certified" }) |needle|
            try s.check(std.mem.indexOf(u8, text, needle) == null, "stale PDF claim");
        const urls = try h.run(&.{ "pdfinfo", "-url", path }, null, null);
        var offset: usize = 0;
        while (std.mem.indexOfPos(u8, html, offset, "href=\"")) |start| {
            const end = std.mem.indexOfScalarPos(u8, html, start + 6, '"') orelse return error.InvalidHtmlLink;
            const url = html[start + 6 .. end];
            offset = end + 1;
            try s.contains(urls, url);
        }
        var words = std.mem.tokenizeAny(u8, urls, " \r\n\t");
        while (words.next()) |url| if (std.mem.startsWith(u8, url, "https://")) {
            const prefix = "https://github.com/moribit/Akamata/blob/main/";
            if (std.mem.startsWith(u8, url, prefix)) {
                const relative = std.Uri.percentDecodeInPlace(try h.a.dupe(u8, url[prefix.len..]));
                try s.check(h.exists(relative), relative);
            } else try s.eq(url, "https://github.com/moribit/Akamata");
        };
        std.debug.print("{s} PDF: 13 nonblank pages, current code and valid links\n", .{language});
    }
}
