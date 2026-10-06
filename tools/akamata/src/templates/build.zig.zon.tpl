.{
    .name = .{{NAME_ENUM}},
    .version = "0.0.1",
    .fingerprint = {{FINGERPRINT}},
    .minimum_zig_version = "0.17.0",
    .dependencies = .{
        // Pinned to a release-compatible Akamata revision. During Akamata
        // development, override it with: zig build --fork=/path/to/Akamata
        .akamata = .{
            .url = "https://github.com/moribit/Akamata/archive/refs/tags/v0.2.0.tar.gz",
            .hash = "akamata-0.2.0-uJIoI5q4OgFWiDgjeemHhRKrz22T9j6WdfVIWxIPfpUt",
        },
    },
    .paths = .{
        "build.zig",
        "build.zig.zon",
        "src",
        "migrations",
        "deploy",
        "README.md",
    },
}
