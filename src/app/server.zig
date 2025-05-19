const std = @import("std");
const httpz = @import("httpz");
const static = @import("./static.zig");

pub const App = struct {
    static: ?[]const u8 = null,
    pub fn notFound(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
        if (req.method == .GET) {
            if (app.static) |base| blk: {
                const path: []u8 = static.serveFile(req, res, base) catch break :blk;
                std.log.info("static: {s}", .{path});
                return;
            }
        }
        try res.json(.{ .path = req.url.path, .param = req.url.query }, .{});
    }
    pub fn uncaughtError(_: *App, req: *httpz.Request, res: *httpz.Response, err: anyerror) void {
        std.log.info("500 {} {s} {}", .{ req.method, req.url.path, err });
        res.status = 500;
        res.json(.{ .err = err }, .{}) catch {
            std.log.info("500 {} {s} {}", .{ req.method, req.url.path, err });
            res.body = "unknow";
        };
    }
    fn init() void {}
};
