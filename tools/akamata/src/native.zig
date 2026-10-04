const builtin = @import("builtin");
pub const Timespec = extern struct { sec: c_long, nsec: c_long };

// `struct stat` is OS-specific; we only read st_mtim(espec). These layouts
// match darwin (_DARWIN_FEATURE_64_BIT_INODE, the default) and linux x86_64.
pub const stat_t = switch (builtin.os.tag) {
    .macos => extern struct {
        dev: i32,
        mode: u16,
        nlink: u16,
        ino: u64,
        uid: u32,
        gid: u32,
        rdev: i32,
        atim: Timespec,
        mtim: Timespec,
        ctim: Timespec,
        birthtim: Timespec,
        size: i64,
        blocks: i64,
        blksize: i32,
        flags: u32,
        gen: u32,
        lspare: i32,
        qspare: [2]i64,
    },
    else => extern struct {
        dev: u64,
        ino: u64,
        nlink: u64,
        mode: u32,
        uid: u32,
        gid: u32,
        _pad0: u32,
        rdev: u64,
        size: i64,
        blksize: i64,
        blocks: i64,
        atim: Timespec,
        mtim: Timespec,
        ctim: Timespec,
        _unused: [3]i64,
    },
};

pub extern "c" fn stat(path: [*:0]const u8, buf: *stat_t) c_int;

const c = @import("std").c;
pub const DIR = c.DIR;
pub const dirent = c.dirent;
pub const opendir = c.opendir;
pub const readdir = c.readdir;
pub const closedir = c.closedir;
pub const DT_DIR = 4;
pub const DT_REG = 8;
