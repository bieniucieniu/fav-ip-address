const std = @import("std");
const httpz = @import("httpz");

pub fn serveFile(req: *httpz.Request, res: *httpz.Response, base: []const u8) ![]u8 {
    var path = try std.fs.path.join(res.arena, &.{ base, req.url.path });
    var file = try std.fs.cwd().openFile(path, .{});
    const meta = try file.metadata();
    if (meta.kind() == .directory) {
        file.close();
        path = try std.fs.path.join(res.arena, &.{ path, "index.html" });
        file = try std.fs.cwd().openFile(path, .{});
    }

    defer file.close();

    var reader = file.reader();
    var writer = res.writer();
    res.content_type = httpz.ContentType.forFile(path);
    const buffer = try res.arena.alloc(u8, 1024);

    while (reader.read(buffer)) |n| {
        if (n == 0) break;
        _ = try writer.write(buffer[0..n]);
    } else |err| return err;

    return path;
}
