const pg = @import("pg");
const std = @import("std");
const db = @import("database/database.zig");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    var pool = try db.init(env, allocator);
    defer pool.deinit();

    var result = try pool.query("select id, name from users where power > $1", .{9000});
    defer result.deinit();
}

const Ctx = struct { pool: pg.Pool };
