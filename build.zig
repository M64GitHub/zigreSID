// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = std.builtin.OptimizeMode.ReleaseFast;

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

    // Build SDL Executable
    const exe_sdl = b.addExecutable(.{
        .name = "zig_sid_demo_sdl",
        .root_source_file = b.path("src/main_sdlplayer.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sdl.linkLibrary(sid_lib);
    exe_sdl.linkSystemLibrary("stdc++");
    exe_sdl.linkSystemLibrary("SDL2");
    exe_sdl.addIncludePath(b.path("."));
    exe_sdl.addIncludePath(b.path("resid"));
    b.installArtifact(exe_sdl);

    // Build RenderAudio Executable
    const exe_renderaudio = b.addExecutable(.{
        .name = "zig_sid_demo_renderaudio",
        .root_source_file = b.path("src/main_renderaudio.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_renderaudio.linkLibrary(sid_lib);
    exe_renderaudio.linkSystemLibrary("stdc++");
    exe_renderaudio.linkSystemLibrary("SDL2");
    exe_renderaudio.addIncludePath(b.path("."));
    exe_renderaudio.addIncludePath(b.path("resid"));
    b.installArtifact(exe_renderaudio);

    // Build WavWriter Executable
    const exe_wavwriter = b.addExecutable(.{
        .name = "zig_sid_demo_wavwriter",
        .root_source_file = b.path("src/main_wavwriter.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_wavwriter.linkLibrary(sid_lib);
    exe_wavwriter.linkSystemLibrary("stdc++");
    exe_wavwriter.addIncludePath(b.path("."));
    exe_wavwriter.addIncludePath(b.path("resid"));
    b.installArtifact(exe_wavwriter);

    // Run steps for all
    const run_unthreaded = b.addRunArtifact(exe_unthreaded);
    const run_threaded = b.addRunArtifact(exe_threaded);
    const run_sdl = b.addRunArtifact(exe_sdl);
    const run_renderaudio = b.addRunArtifact(exe_renderaudio);
    const run_wavwriter = b.addRunArtifact(exe_wavwriter);

    if (b.args) |args| {
        run_unthreaded.addArgs(args);
        run_threaded.addArgs(args);
        run_sdl.addArgs(args);
        run_renderaudio.addArgs(args);
        run_wavwriter.addArgs(args);
    }

    const run_step_unthreaded = b.step("run-unthreaded", "Run the unthreaded SID demo");
    run_step_unthreaded.dependOn(&run_unthreaded.step);

    const run_step_threaded = b.step("run-threaded", "Run the threaded SID demo");
    run_step_threaded.dependOn(&run_threaded.step);

    const run_step_sdl = b.step("run-sdl", "Run the SDL SID demo");
    run_step_sdl.dependOn(&run_sdl.step);

    const run_step_renderaudio = b.step("run-renderaudio", "Run the RenderAudio() SID demo");
    run_step_renderaudio.dependOn(&run_renderaudio.step);

    const run_step_wavwriter = b.step("run-wavwriter", "Run the Wav-Writer SID demo");
    run_step_wavwriter.dependOn(&run_wavwriter.step);
}
