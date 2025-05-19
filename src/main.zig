const std = @import("std");
const httpz = @import("httpz");
const static = @import("app/static.zig");
const App = @import("app/server.zig").App;

const parseEnvInt = @import("./utils/env.zig").parseEnvInt;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var app: App = .{ .static = "./static" };
    const env = try std.process.getEnvMap(allocator);
    var server = try httpz.Server(*App).init(allocator, .{ .port = parseEnvInt(u16, env.get("PORT"), 3000) }, &app);

    defer {
        server.stop();
        server.deinit();
    }

    var router = try server.router(.{});
    router.get("/api/user/:id", getUser, .{});

    std.log.info("starting server on: {?s}", .{env.get("PORT")});
    try server.listen();
}

fn getUser(_: *App, req: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    try res.json(.{ .id = req.param("id"), .name = "Teg" }, .{});
}
