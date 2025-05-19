const std = @import("std");

pub inline fn parseEnvInt(comptime T: type, buf: ?[]const u8, fallback: T) T {
    return if (buf) |b|
        std.fmt.parseInt(T, b, 0) catch fallback
    else
        fallback;
}
