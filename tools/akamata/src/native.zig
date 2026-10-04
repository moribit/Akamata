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

pub const DIR = opaque {};

pub const dirent = switch (builtin.os.tag) {
    .macos => extern struct {
        ino: u64,
        seekoff: u64,
        reclen: u16,
        namlen: u16,
        type: u8,
        name: [1024]u8,
    },
    else => extern struct {
        ino: u64,
        off: i64,
        reclen: u16,
        type: u8,
        name: [256]u8,
    },
};

pub extern "c" fn opendir(path: [*:0]const u8) ?*DIR;

pub extern "c" fn readdir(d: *DIR) ?*dirent;

pub extern "c" fn closedir(d: *DIR) c_int;

pub const DT_DIR = 4;

pub const DT_REG = 8;
