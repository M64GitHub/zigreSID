// build.zig
const std = @import("std");
const resid_include_path = "resid-cpp/";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    // const optimize = b.standardOptimizeOption(.{});
    const optimize = std.builtin.OptimizeMode.ReleaseFast;

    // Build reSID C++ shared library and C wrapper
    const resid_lib = b.addSharedLibrary(.{
        .name = "sid",
        .target = target,
        .optimize = optimize,
    });

    resid_lib.addIncludePath(.{ .cwd_relative = "/usr/include/" });
    resid_lib.addIncludePath(.{ .cwd_relative = "resid-cpp/" });

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

    // Build Unthreaded Executable
    const exe_unthreaded = b.addExecutable(.{
        .name = "zigReSID-dump-play",
        .root_source_file = b.path("src/main_dump-play.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_unthreaded.addIncludePath(.{ .cwd_relative = resid_include_path });
    exe_unthreaded.linkLibrary(resid_lib);
    exe_unthreaded.linkSystemLibrary("SDL2");
    b.installArtifact(exe_unthreaded);

    // Build Threaded Executable
    const exe_threaded = b.addExecutable(.{
        .name = "zigReSID-dump-play-threaded",
        .root_source_file = b.path("src/main_dump-play-threaded.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_threaded.addIncludePath(.{ .cwd_relative = resid_include_path });
    exe_threaded.linkLibrary(resid_lib);
    exe_threaded.linkSystemLibrary("SDL2");
    b.installArtifact(exe_threaded);

    // Build SDL Executable
    const exe_sdl = b.addExecutable(.{
        .name = "zigReSID-sdl-player",
        .root_source_file = b.path("src/main_sdl-player.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sdl.addIncludePath(.{ .cwd_relative = resid_include_path });
    exe_sdl.linkLibrary(resid_lib);
    exe_sdl.linkSystemLibrary("SDL2");
    b.installArtifact(exe_sdl);

    // Build RenderAudio Executable
    const exe_renderaudio = b.addExecutable(.{
        .name = "zigReSID-render-audio",
        .root_source_file = b.path("src/main_render-audio.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_renderaudio.addIncludePath(.{ .cwd_relative = resid_include_path });
    exe_renderaudio.linkLibrary(resid_lib);
    exe_renderaudio.linkSystemLibrary("SDL2");
    b.installArtifact(exe_renderaudio);

    // Build WavWriter Executable
    const exe_wavwriter = b.addExecutable(.{
        .name = "zigReSID-wav-writer",
        .root_source_file = b.path("src/main_wav-writer.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_wavwriter.addIncludePath(.{ .cwd_relative = resid_include_path });
    exe_wavwriter.linkLibrary(resid_lib);
    b.installArtifact(exe_wavwriter);

    // Build 6510 Emulator Test Executable
    const exe_6510_cputest = b.addExecutable(.{
        .name = "zigReSID-6510-cpu-test",
        .root_source_file = b.path("src/main_6510-cpu-test.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe_6510_cputest);

    // Build .sid-file Test Executable
    const exe_sidfile = b.addExecutable(.{
        .name = "zigReSID-play-sidfile",
        .root_source_file = b.path("src/main_sidfile.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sidfile.addIncludePath(.{ .cwd_relative = resid_include_path });
    exe_sidfile.linkLibrary(resid_lib);
    exe_sidfile.linkSystemLibrary("SDL2");
    b.installArtifact(exe_sidfile);

    // Run steps for all
    const run_unthreaded = b.addRunArtifact(exe_unthreaded);
    const run_threaded = b.addRunArtifact(exe_threaded);
    const run_sdl = b.addRunArtifact(exe_sdl);
    const run_renderaudio = b.addRunArtifact(exe_renderaudio);
    const run_wavwriter = b.addRunArtifact(exe_wavwriter);

    const run_6510_cputest = b.addRunArtifact(exe_6510_cputest);
    const run_sidfile = b.addRunArtifact(exe_sidfile);

    if (b.args) |args| {
        run_unthreaded.addArgs(args);
        run_threaded.addArgs(args);
        run_sdl.addArgs(args);
        run_renderaudio.addArgs(args);
        run_wavwriter.addArgs(args);
        run_6510_cputest.addArgs(args);
        run_sidfile.addArgs(args);
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

    const run_step_6510_cputest = b.step("run-6510-cpu-test", "Run the 6510 cpu test");
    run_step_6510_cputest.dependOn(&run_6510_cputest.step);

    const run_step_sidfile = b.step("run-sidfile", "Run the .sid file player test");
    run_step_sidfile.dependOn(&run_sidfile.step);
}
