// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Step 1: Create shared library from C++ SID code and wrapper
    const sid_lib = b.addSharedLibrary(.{
        .name = "sid",
        .target = target,
        .optimize = optimize,
    });
    sid_lib.linkLibCpp();
    sid_lib.addIncludePath(b.path("."));
    sid_lib.addCSourceFiles(.{
        .files = &.{
            "resid/envelope.cc",
            "resid/extfilt.cc",
            "resid/filter.cc",
            "resid/pot.cc",
            "resid/sid.cc",
            "resid/version.cc",
            "resid/voice.cc",
            "resid/wave6581_PS_.cc",
            "resid/wave6581_PST.cc",
            "resid/wave6581_P_T.cc",
            "resid/wave6581__ST.cc",
            "resid/wave8580_PS_.cc",
            "resid/wave8580_PST.cc",
            "resid/wave8580_P_T.cc",
            "resid/wave8580__ST.cc",
            "resid/wave.cc",
            "resid.cpp",
            "resid-dmpplayer.cpp",
            "resid_wrapper.cpp",
        },
        .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
    });

    sid_lib.addIncludePath(.{ .cwd_relative = "/usr/include/" });

    // Step 2: Build the Zig executable and link with SID library
    const exe = b.addExecutable(.{
        .name = "zig_sid_demo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(sid_lib);
    exe.linkSystemLibrary("stdc++");
    exe.linkSystemLibrary("SDL2");
    exe.addIncludePath(b.path("."));

    b.installArtifact(exe);

    // Step 3: Run step
    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the Zig SID demo");
    run_step.dependOn(&run_cmd.step);
}
