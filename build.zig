const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const httpz = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("httpz", httpz.module("httpz"));
    const zqlite = b.dependency("zqlite", .{
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addCSourceFile(.{
        .file = b.path("lib/sqlite3.c"),
        .flags = &[_][]const u8{
            "-DSQLITE_DQS=0",
            "-DSQLITE_DEFAULT_WAL_SYNCHRONOUS=1",
            "-DSQLITE_USE_ALLOCA=1",
            "-DSQLITE_THREADSAFE=1",
            "-DSQLITE_TEMP_STORE=3",
            "-DSQLITE_ENABLE_API_ARMOR=1",
            "-DSQLITE_ENABLE_UNLOCK_NOTIFY",
            "-DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1",
            "-DSQLITE_DEFAULT_FILE_PERMISSIONS=0600",
            "-DSQLITE_OMIT_DECLTYPE=1",
            "-DSQLITE_OMIT_DEPRECATED=1",
            "-DSQLITE_OMIT_LOAD_EXTENSION=1",
            "-DSQLITE_OMIT_PROGRESS_CALLBACK=1",
            "-DSQLITE_OMIT_SHARED_CACHE",
            "-DSQLITE_OMIT_TRACE=1",
            "-DSQLITE_OMIT_UTF16=1",
            "-DHAVE_USLEEP=0",
        },
    });
    exe_mod.addImport("zqlite", zqlite.module("zqlite"));

    const exe = b.addExecutable(.{
        .name = "fav-id-address",
        .root_module = exe_mod,
    });

    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // const frontend_cwd: std.Build.LazyPath = .{ .cwd_relative = "./frontend/" };
    // const run_install_forntend = b.addSystemCommand(&.{ "bun", "run", "build" });
    // run_install_forntend.setCwd(frontend_cwd);
    // const run_build_forntend = b.addSystemCommand(&.{ "bun", "run", "build" });
    // run_build_forntend.setCwd(frontend_cwd);
    // run_build_forntend.step.dependOn(&run_build_forntend.step);
    //
    const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_build_forntend.step);
    // run_step.dependOn(&run_build_forntend.step);
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
