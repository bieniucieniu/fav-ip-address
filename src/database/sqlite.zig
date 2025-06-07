const zqlite = @import("zqlite");
const std = @import("std");

pub const SQLite = struct {
    pool: *zqlite.Pool,
    pub fn init(allocator: std.mem.Allocator, env: std.process.EnvMap) !SQLite {
        const flags = zqlite.OpenFlags.Create | zqlite.OpenFlags.EXResCode;
        const file_path = env.get("DB_FILE") orelse "/tmp/sqlite.fav-ip-address.db";
        const path = try std.posix.toPosixPath(file_path);
        const pool = try zqlite.Pool.init(
            allocator,
            .{
                .path = &path,
                .flags = flags,
            },
        );
        return .{ .pool = pool };
    }
    pub fn deinit(self: *SQLite) void {
        self.pool.deinit();
    }
};
