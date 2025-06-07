const std = @import("std");
const httpz = @import("httpz");
const static = @import("app/static.zig");
const App = @import("app/server.zig").App;

const parseEnvInt = @import("./utils/env.zig").parseEnvInt;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const env = try std.process.getEnvMap(allocator);
    var instance: App = try .init(allocator, .{ .static = "./static", .env = env });
    defer instance.deinit();
    var server = try httpz.Server(*App).init(allocator, .{ .port = parseEnvInt(u16, env.get("PORT"), 3000) }, &instance);

    defer {
        server.stop();
        server.deinit();
    }

    var router = try server.router(.{});
    router.get("/api/user/:username", struct {
        fn handler(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
            const username = req.param("username") orelse unreachable;
            res.status = 200;
            try getRepos(req.arena, app, username, res.writer());
        }
    }.handler, .{});

    std.log.info("starting server on: {s}", .{env.get("PORT") orelse "3000"});
    try server.listen();
}

fn getRepos(a: std.mem.Allocator, app: *App, username: []const u8) ![]const u8 {
    const path = try std.fmt.allocPrint(a, "http://127.0.0.1:8000/{s}/get", .{username});
    const uri = std.Uri.parse(path) catch unreachable;
    const buf = try a.alloc(u8, 4096);
    defer a.free(buf);
    var req = try app.client.open(.GET, uri, .{ .server_header_buffer = buf });
    defer req.deinit();
    try req.send();
    try req.wait();
    const content_length = try getContentLength(req);
    const buffer = try a.alloc(u8, content_length);
    errdefer a.free(buffer);
    _ = try req.readAll(buffer);
    return buffer;
}

const GetContentLengthErr = error{InvalidContentLength};
fn getContentLength(req: std.http.Client.Request) !u64 {
    return switch (req.transfer_encoding) {
        .content_length => |len| len,
        else => return GetContentLengthErr.InvalidContentLength,
    };
}
