// build.zig
const std = @import("std");
const resid_include_path = "resid-cpp/";
const usr_include_path = "/usr/include/";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = std.builtin.OptimizeMode.ReleaseFast;

    // Build reSID C++ shared library and C wrapper
    const resid_lib = b.addSharedLibrary(.{
        .name = "sid",
        .target = target,
        .optimize = optimize,
    });

    resid_lib.addIncludePath(.{ .cwd_relative = usr_include_path });
    resid_lib.addIncludePath(.{ .cwd_relative = resid_include_path });
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

    // modules
    const mod_resid = b.addModule("resid", .{ .root_source_file = .{
        .cwd_relative = "src/resid.zig",
    } });
    mod_resid.addIncludePath(.{ .cwd_relative = resid_include_path });
    mod_resid.linkLibrary(resid_lib);

    const mod_residsdl = b.addModule("residsdl", .{ .root_source_file = .{
        .cwd_relative = "src/residsdl.zig",
    } });
    mod_residsdl.addIncludePath(.{ .cwd_relative = resid_include_path });
    mod_residsdl.addIncludePath(.{ .cwd_relative = usr_include_path });
    mod_residsdl.addImport("resid", mod_resid);
    mod_residsdl.linkLibrary(resid_lib);

    const mod_6510 = b.addModule("6510", .{ .root_source_file = .{
        .cwd_relative = "src/6510/6510.zig",
    } });

    const mod_sidfile = b.addModule("sidfile", .{ .root_source_file = .{
        .cwd_relative = "src/sidfile.zig",
    } });

    const mod_wavwriter = b.addModule("wavwriter", .{ .root_source_file = .{
        .cwd_relative = "src/wavwriter.zig",
    } });

    // Build Unthreaded Executable
    const exe_unthreaded = b.addExecutable(.{
        .name = "zigreSID-dump-play",
        .root_source_file = b.path("src/examples/sid-dump-player.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_unthreaded.addIncludePath(.{ .cwd_relative = usr_include_path });
    exe_unthreaded.root_module.addImport("resid", mod_resid);
    exe_unthreaded.linkSystemLibrary("SDL2");
    b.installArtifact(exe_unthreaded);

    // Build Threaded Executable
    const exe_threaded = b.addExecutable(.{
        .name = "zigreSID-dump-play-threaded",
        .root_source_file = b.path("src/examples/sid-dump-player-threaded.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_threaded.addIncludePath(.{ .cwd_relative = usr_include_path });
    exe_threaded.root_module.addImport("resid", mod_resid);
    exe_threaded.linkSystemLibrary("SDL2");
    b.installArtifact(exe_threaded);

    // Build SDL Executable
    const exe_sdl = b.addExecutable(.{
        .name = "zigreSID-sdl-player",
        .root_source_file = b.path("src/examples/sdl-sid-dump-player.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sdl.addIncludePath(.{ .cwd_relative = usr_include_path });
    exe_sdl.linkSystemLibrary("SDL2");
    exe_sdl.root_module.addImport("residsdl", mod_residsdl);
    b.installArtifact(exe_sdl);

    // Build RenderAudio Executable
    const exe_renderaudio = b.addExecutable(.{
        .name = "zigreSID-render-audio",
        .root_source_file = b.path("src/examples/render-audio-example.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_renderaudio.addIncludePath(.{ .cwd_relative = usr_include_path });
    exe_renderaudio.root_module.addImport("resid", mod_resid);
    exe_renderaudio.linkSystemLibrary("SDL2");
    b.installArtifact(exe_renderaudio);

    // Build WavWriter Executable
    const exe_wavwriter = b.addExecutable(.{
        .name = "zigreSID-wav-writer",
        .root_source_file = b.path("src/examples/wav-writer-example.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_wavwriter.root_module.addImport("resid", mod_resid);
    exe_wavwriter.root_module.addImport("wavwriter", mod_wavwriter);
    b.installArtifact(exe_wavwriter);

    // Build .sid-file Test Executable
    const exe_sidfile = b.addExecutable(.{
        .name = "zigreSID-play-sidfile",
        .root_source_file = b.path("src/examples/sidfile-dump.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sidfile.root_module.addImport("resid", mod_resid);
    exe_sidfile.root_module.addImport("6510", mod_6510);
    exe_sidfile.root_module.addImport("sidfile", mod_sidfile);
    b.installArtifact(exe_sidfile);

    // Run steps for all
    const run_unthreaded = b.addRunArtifact(exe_unthreaded);
    const run_threaded = b.addRunArtifact(exe_threaded);
    const run_sdl = b.addRunArtifact(exe_sdl);
    const run_renderaudio = b.addRunArtifact(exe_renderaudio);
    const run_wavwriter = b.addRunArtifact(exe_wavwriter);

    const run_sidfile = b.addRunArtifact(exe_sidfile);

    if (b.args) |args| {
        run_unthreaded.addArgs(args);
        run_threaded.addArgs(args);
        run_sdl.addArgs(args);
        run_renderaudio.addArgs(args);
        run_wavwriter.addArgs(args);
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

    const run_step_sidfile = b.step("run-sidfile", "Run the .sid file player test");
    run_step_sidfile.dependOn(&run_sidfile.step);
}
