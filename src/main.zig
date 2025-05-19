const std = @import("std");
const httpz = @import("httpz");
const static = @import("app/static.zig");
const App = @import("app/server.zig").App;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var app: App = .{ .static = "./static" };
    var server = try httpz.Server(*App).init(allocator, .{ .port = 3000 }, &app);

    defer {
        server.stop();
        server.deinit();
    }

    var router = try server.router(.{});
    router.get("/api/user/:id", getUser, .{});

    try server.listen();
}

fn getUser(_: *App, req: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    try res.json(.{ .id = req.param("id"), .name = "Teg" }, .{});
}
