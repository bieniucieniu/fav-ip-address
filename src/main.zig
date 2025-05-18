const std = @import("std");
const httpz = @import("httpz");
const static = @import("http/static.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var app: App = .{
        .allocator = allocator,
        .static = "./static",
    };
    var server = try httpz.Server(*App).init(allocator, .{ .port = 3000 }, &app);

    defer {
        server.stop();
        server.deinit();
    }

    var router = try server.router(.{});
    router.get("/api/user/:id", getUser, .{});

    try server.listen();
}

const App = struct {
    static: ?[]const u8 = null,
    allocator: std.mem.Allocator,
    pub fn notFound(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
        var path: ?[]u8 = null;
        if (req.method == .GET) {
            if (app.static) |base| blk: {
                path = static.serveFile(req, res, base) catch break :blk;
                return;
            }
        }
        try res.json(.{ .path = req.url.path, .param = req.url.query, .static = path }, .{});
    }
    pub fn uncaughtError(_: *App, req: *httpz.Request, res: *httpz.Response, err: anyerror) void {
        std.log.info("500 {} {s} {}", .{ req.method, req.url.path, err });
        res.status = 500;
        res.json(.{ .err = err }, .{}) catch {
            std.log.info("500 {} {s} {}", .{ req.method, req.url.path, err });
            res.body = "unknow";
        };
    }
};

fn getUser(_: *App, req: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    try res.json(.{ .id = req.param("id"), .name = "Teg" }, .{});
}
