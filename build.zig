// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create reSID C++ shared library and C wrapper
    const sid_lib = b.addSharedLibrary(.{
        .name = "sid",
        .target = target,
        .optimize = optimize,
    });
    sid_lib.linkLibCpp();
    sid_lib.addIncludePath(b.path("."));
    sid_lib.addCSourceFiles(.{
        .files = &.{
            "resid/resid/envelope.cc",
            "resid/resid/extfilt.cc",
            "resid/resid/filter.cc",
            "resid/resid/pot.cc",
            "resid/resid/sid.cc",
            "resid/resid/version.cc",
            "resid/resid/voice.cc",
            "resid/resid/wave6581_PS_.cc",
            "resid/resid/wave6581_PST.cc",
            "resid/resid/wave6581_P_T.cc",
            "resid/resid/wave6581__ST.cc",
            "resid/resid/wave8580_PS_.cc",
            "resid/resid/wave8580_PST.cc",
            "resid/resid/wave8580_P_T.cc",
            "resid/resid/wave8580__ST.cc",
            "resid/resid/wave.cc",
            "resid/resid.cpp",
            "resid/resid-dmpplayer.cpp",
            "resid/resid-c-wrapper.cpp",
        },
        .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
    });

    sid_lib.addIncludePath(.{ .cwd_relative = "/usr/include/" });

    // Build Unthreaded Executable
    const exe_unthreaded = b.addExecutable(.{
        .name = "zig_sid_demo_unthreaded",
        .root_source_file = b.path("src/main_unthreaded.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_unthreaded.linkLibrary(sid_lib);
    exe_unthreaded.linkSystemLibrary("stdc++");
    exe_unthreaded.linkSystemLibrary("SDL2");
    exe_unthreaded.addIncludePath(b.path("."));
    exe_unthreaded.addIncludePath(b.path("resid"));
    b.installArtifact(exe_unthreaded);

    // Build Threaded Executable
    const exe_threaded = b.addExecutable(.{
        .name = "zig_sid_demo_threaded",
        .root_source_file = b.path("src/main_threaded.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_threaded.linkLibrary(sid_lib);
    exe_threaded.linkSystemLibrary("stdc++");
    exe_threaded.linkSystemLibrary("SDL2");
    exe_threaded.addIncludePath(b.path("."));
    exe_threaded.addIncludePath(b.path("resid"));
    b.installArtifact(exe_threaded);

    // Run steps for both
    const run_unthreaded = b.addRunArtifact(exe_unthreaded);
    const run_threaded = b.addRunArtifact(exe_threaded);

    if (b.args) |args| {
        run_unthreaded.addArgs(args);
        run_threaded.addArgs(args);
    }

    const run_step_unthreaded = b.step("run-unthreaded", "Run the unthreaded SID demo");
    run_step_unthreaded.dependOn(&run_unthreaded.step);

    const run_step_threaded = b.step("run-threaded", "Run the threaded SID demo");
    run_step_threaded.dependOn(&run_threaded.step);
}
