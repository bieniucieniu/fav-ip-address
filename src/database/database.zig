const pg = @import("pg");
const std = @import("std");

const parseEnvInt = @import("./utils/env.zig").parseEnvInt;

pub const DBError = error{
    MissingDbUsername,
};
pub fn init(env: std.process.EnvMap, allocator: std.mem.Allocator) !*pg.Pool {
    return try pg.Pool.init(allocator, .{ .size = 5, .connect = .{
        .port = parseEnvInt(u16, env.get("PG_PORT"), 5432),
        .host = env.get("PG_HOST") orelse "127.0.0.1",
    }, .auth = .{
        .username = env.get("PG_USERNAME") orelse return DBError.MissingDbUsername,
        .database = env.get("PG_DATABASE"),
        .password = env.get("PG_PASSWORD"),
        .timeout = parseEnvInt(u32, env.get("PG_TIMEOUT"), 10_000),
    } });
}
