// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    // const optimize = b.standardOptimizeOption(.{});
    const optimize = std.builtin.OptimizeMode.ReleaseFast;

    // Create reSID C++ shared library and C wrapper
    const resid_lib = b.addSharedLibrary(.{
        .name = "sid",
        .target = target,
        .optimize = optimize,
    });
    resid_lib.linkLibCpp();
    resid_lib.addCSourceFiles(.{
        .files = &.{
            "resid-cpp/resid/envelope.cc",
            "resid-cpp/resid/extfilt.cc",
            "resid-cpp/resid/filter.cc",
            "resid-cpp/resid/pot.cc",
            "resid-cpp/resid/sid.cc",
            "resid-cpp/resid/version.cc",
            "resid-cpp/resid/voice.cc",
            "resid-cpp/resid/wave6581_PS_.cc",
            "resid-cpp/resid/wave6581_PST.cc",
            "resid-cpp/resid/wave6581_P_T.cc",
            "resid-cpp/resid/wave6581__ST.cc",
            "resid-cpp/resid/wave8580_PS_.cc",
            "resid-cpp/resid/wave8580_PST.cc",
            "resid-cpp/resid/wave8580_P_T.cc",
            "resid-cpp/resid/wave8580__ST.cc",
            "resid-cpp/resid/wave.cc",
            "resid-cpp/resid.cpp",
            "resid-cpp/resid-dmpplayer.cpp",
            "resid-cpp/resid-c-wrapper.cpp",
        },
        .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
    });

    resid_lib.addIncludePath(.{ .cwd_relative = "/usr/include/" });

    // Build Unthreaded Executable
    const exe_unthreaded = b.addExecutable(.{
        .name = "zigReSID-dump-play",
        .root_source_file = b.path("src/main_dump-play.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_unthreaded.linkLibrary(resid_lib);
    exe_unthreaded.linkSystemLibrary("stdc++");
    exe_unthreaded.linkSystemLibrary("SDL2");
    exe_unthreaded.addIncludePath(b.path("resid-cpp"));
    b.installArtifact(exe_unthreaded);

    // Build Threaded Executable
    const exe_threaded = b.addExecutable(.{
        .name = "zigReSID-dump-play-threaded",
        .root_source_file = b.path("src/main_dump-play-threaded.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_threaded.linkLibrary(resid_lib);
    exe_threaded.linkSystemLibrary("stdc++");
    exe_threaded.linkSystemLibrary("SDL2");
    exe_threaded.addIncludePath(b.path("resid-cpp"));
    b.installArtifact(exe_threaded);

    // Build SDL Executable
    const exe_sdl = b.addExecutable(.{
        .name = "zigReSID-sdl-player",
        .root_source_file = b.path("src/main_sdl-player.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sdl.linkLibrary(resid_lib);
    exe_sdl.linkSystemLibrary("stdc++");
    exe_sdl.linkSystemLibrary("SDL2");
    exe_sdl.addIncludePath(b.path("resid-cpp"));
    b.installArtifact(exe_sdl);

    // Build RenderAudio Executable
    const exe_renderaudio = b.addExecutable(.{
        .name = "zigReSID-render-audio",
        .root_source_file = b.path("src/main_render-audio.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_renderaudio.linkLibrary(resid_lib);
    exe_renderaudio.linkSystemLibrary("stdc++");
    exe_renderaudio.linkSystemLibrary("SDL2");
    exe_renderaudio.addIncludePath(b.path("resid-cpp"));
    b.installArtifact(exe_renderaudio);

    // Build WavWriter Executable
    const exe_wavwriter = b.addExecutable(.{
        .name = "zigReSID-wav-writer",
        .root_source_file = b.path("src/main_wav-writer.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_wavwriter.linkLibrary(resid_lib);
    exe_wavwriter.linkSystemLibrary("stdc++");
    exe_wavwriter.addIncludePath(b.path("resid-cpp"));
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

    const run_step_unthreaded = b.step("run-dump-play", "Run the unthreaded dump player");
    run_step_unthreaded.dependOn(&run_unthreaded.step);

    const run_step_threaded = b.step("run-dump-play-threaded", "Run the threaded dump player");
    run_step_threaded.dependOn(&run_threaded.step);

    const run_step_sdl = b.step("run-sdl-player", "Run the SDL dump player");
    run_step_sdl.dependOn(&run_sdl.step);

    const run_step_renderaudio = b.step("run-render-audio", "Run the RenderAudio() demo");
    run_step_renderaudio.dependOn(&run_renderaudio.step);

    const run_step_wavwriter = b.step("run-wav-writer", "Run the Wav-Writer demo");
    run_step_wavwriter.dependOn(&run_wavwriter.step);
}
