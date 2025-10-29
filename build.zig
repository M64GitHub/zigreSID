const std = @import("std");

const resid_include_path = "resid-cpp/";
const usr_include_path = "/usr/include/";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = std.builtin.OptimizeMode.ReleaseFast;

    // -- dependencies
    const dep_zig64 = b.dependency("zig64", .{});
    const mod_zig64 = dep_zig64.module("zig64");

    const dep_flagz = b.dependency("flagz", .{});
    const mod_flagz = dep_flagz.module("flagz");

    // build reSID C++ shared library and C wrapper
    const resid_lib_mod = b.addModule("resid_lib", .{
        .target = target,
        .optimize = optimize,
    });

    resid_lib_mod.addIncludePath(.{ .cwd_relative = usr_include_path });
    resid_lib_mod.addIncludePath(.{ .cwd_relative = resid_include_path });

    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/envelope.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/extfilt.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/filter.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/pot.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/sid.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/version.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/voice.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave6581_PS_.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave6581_PST.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave6581_P_T.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave6581__ST.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave8580_PS_.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave8580_PST.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave8580_P_T.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave8580__ST.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid/wave.cc"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid.cpp"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid-dmpplayer.cpp"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );
    resid_lib_mod.addCSourceFile(
        .{
            .file = b.path("resid-cpp/resid-c-wrapper.cpp"),
            .flags = &.{ "-x", "c++", "-DVERSION=\"m64-000\"", "-Ofast" },
        },
    );

    const resid_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "sid",
        .root_module = resid_lib_mod,
    });
    resid_lib.linkLibC();
    resid_lib.linkLibCpp();
    b.installArtifact(resid_lib);

    // -- sub modules

    // original resid cpp, cpp- and c-wrapper
    const mod_resid_cpp = b.addModule("resid_cpp", .{
        .root_source_file = b.path("src/resid-cpp.zig"),
    });
    mod_resid_cpp.linkLibrary(resid_lib);

    const install_headers = b.addInstallDirectory(.{
        .source_dir = b.path("resid-cpp"),
        .install_dir = .header,
        .install_subdir = "resid-cpp",
    });
    b.getInstallStep().dependOn(&install_headers.step);
    // Source path for local build
    mod_resid_cpp.addIncludePath(b.path("resid-cpp"));
    // Installed path for dependents
    mod_resid_cpp.addIncludePath(.{
        .cwd_relative = b.getInstallPath(.header, "resid-cpp"),
    });

    // residsdl
    const mod_resid_sdl = b.addModule("resid_sdl", .{
        .root_source_file = b.path("src/resid-sdl.zig"),
    });
    mod_resid_sdl.addIncludePath(.{ .cwd_relative = resid_include_path });
    mod_resid_sdl.addIncludePath(.{ .cwd_relative = usr_include_path });
    mod_resid_sdl.addImport("resid_cpp", mod_resid_cpp);

    // wavwriter
    const mod_wavwriter = b.addModule("wavwriter", .{
        .root_source_file = b.path("src/wavwriter.zig"),
    });

    // wavloader
    const mod_wavloader = b.addModule("wavloader", .{
        .root_source_file = b.path("src/wavloader.zig"),
    });

    // resid_mixer
    const mod_resid_mixer = b.addModule("resid_mixer", .{
        .root_source_file = b.path("src/resid-mixer.zig"),
    });
    mod_resid_mixer.addImport("resid_cpp", mod_resid_cpp);
    mod_resid_mixer.addIncludePath(.{ .cwd_relative = usr_include_path });

    // sidfile
    const mod_sidfile = b.addModule("sidfile", .{
        .root_source_file = b.path("src/sidfile.zig"),
    });

    // sidplayer
    const mod_sidplayer = b.addModule("sidplayer", .{
        .root_source_file = b.path("src/sidplayer.zig"),
        .imports = &.{
            .{ .name = "sidfile", .module = mod_sidfile },
            .{ .name = "zig64", .module = mod_zig64 },
        },
    });

    // --

    // Create the main `resid` module (which includes everything)
    const mod_resid = b.addModule("resid", .{
        .root_source_file = b.path("src/resid.zig"),
    });
    mod_resid.addImport("sidfile", mod_sidfile);
    mod_resid.addImport("wavwriter", mod_wavwriter);
    mod_resid.addImport("wavloader", mod_wavloader);
    mod_resid.addImport("resid_cpp", mod_resid_cpp);
    mod_resid.addImport("resid_sdl", mod_resid_sdl);
    mod_resid.addImport("resid_mixer", mod_resid_mixer);
    mod_resid.addImport("sidplayer", mod_sidplayer);
    mod_resid.addImport("zig64", mod_zig64);
    mod_resid.addIncludePath(b.path("resid-cpp")); // Source path for local build
    mod_resid.addIncludePath(.{
        .cwd_relative = b.getInstallPath(.header, "resid-cpp"),
    }); // Installed path for dependents
    mod_resid.linkLibrary(resid_lib);

    // --

    // Build all executables (unchanged until here)
    const exe_dumpplayer_mod = b.addModule("exe_dumpplayer", .{
        .root_source_file = b.path("src/examples/sid-dump-player.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_dumpplayer_mod.addIncludePath(.{ .cwd_relative = usr_include_path });
    exe_dumpplayer_mod.addImport("resid", mod_resid);
    exe_dumpplayer_mod.linkSystemLibrary("SDL2", .{});

    const exe_dumpplayer = b.addExecutable(.{
        .name = "dump-player",
        .root_module = exe_dumpplayer_mod,
    });
    b.installArtifact(exe_dumpplayer);

    const exe_threaded_mod = b.addModule("exe_threaded", .{
        .root_source_file = b.path("src/examples/sid-dump-player-threaded.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_threaded_mod.addIncludePath(.{ .cwd_relative = usr_include_path });
    exe_threaded_mod.addImport("resid", mod_resid);
    exe_threaded_mod.linkSystemLibrary("SDL2", .{});

    const exe_threaded = b.addExecutable(.{
        .name = "dump-player-threaded",
        .root_module = exe_threaded_mod,
    });
    b.installArtifact(exe_threaded);

    const exe_sdl_mod = b.addModule("exe_sdl", .{
        .root_source_file = b.path("src/examples/sdl-sid-dump-player.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sdl_mod.addIncludePath(.{ .cwd_relative = usr_include_path });
    exe_sdl_mod.addImport("resid", mod_resid);
    exe_sdl_mod.linkSystemLibrary("SDL2", .{});

    const exe_sdl = b.addExecutable(.{
        .name = "sdl-dump-player",
        .root_module = exe_sdl_mod,
    });
    b.installArtifact(exe_sdl);

    const exe_renderaudio_mod = b.addModule("exe_renderaudio", .{
        .root_source_file = b.path("src/examples/render-audio-example.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_renderaudio_mod.addIncludePath(.{ .cwd_relative = usr_include_path });
    exe_renderaudio_mod.addImport("resid", mod_resid);
    exe_renderaudio_mod.addImport("flagz", mod_flagz);
    exe_renderaudio_mod.linkSystemLibrary("SDL2", .{});

    const exe_renderaudio = b.addExecutable(.{
        .name = "sid-render-audio",
        .root_module = exe_renderaudio_mod,
    });
    b.installArtifact(exe_renderaudio);

    const exe_wavwriter_mod = b.addModule("exe_wavwriter", .{
        .root_source_file = b.path("src/examples/wav-writer-example.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_wavwriter_mod.addImport("resid", mod_resid);

    const exe_wavwriter = b.addExecutable(.{
        .name = "siddump-wav-writer",
        .root_module = exe_wavwriter_mod,
    });
    b.installArtifact(exe_wavwriter);

    const exe_sidfile_mod = b.addModule("exe_sidfile", .{
        .root_source_file = b.path("src/examples/sidfile-dump.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sidfile_mod.addImport("resid", mod_resid);

    const exe_sidfile = b.addExecutable(.{
        .name = "sid-dump",
        .root_module = exe_sidfile_mod,
    });
    b.installArtifact(exe_sidfile);

    const exe_sidplayer_mod = b.addModule("exe_sidplayer", .{
        .root_source_file = b.path("src/examples/sid-player.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_sidplayer_mod.addImport("resid", mod_resid);
    exe_sidplayer_mod.linkSystemLibrary("SDL2", .{});

    const exe_sidplayer = b.addExecutable(.{
        .name = "zigreSID-play-sidfile",
        .root_module = exe_sidplayer_mod,
    });
    exe_sidplayer.linkLibC();
    b.installArtifact(exe_sidplayer);

    // Note: dump-player-threaded-mix example is not built by default
    // It requires movy dependency for keyboard input
    // When using zigreSID in your game (which has movy), you can build it by
    // adding movy to this build.zig.zon or using the example source directly

    // Ensure all artifacts depend on the headers being installed
    const install_step = b.getInstallStep();
    install_step.dependOn(&b.addInstallArtifact(exe_dumpplayer, .{}).step);
    install_step.dependOn(&b.addInstallArtifact(exe_threaded, .{}).step);
    install_step.dependOn(&b.addInstallArtifact(exe_sdl, .{}).step);
    install_step.dependOn(&b.addInstallArtifact(exe_renderaudio, .{}).step);
    install_step.dependOn(&b.addInstallArtifact(exe_wavwriter, .{}).step);
    install_step.dependOn(&b.addInstallArtifact(exe_sidfile, .{}).step);
    install_step.dependOn(&b.addInstallArtifact(exe_sidplayer, .{}).step);

    // Run steps
    const run_dumpplayer = b.addRunArtifact(exe_dumpplayer);
    const run_threaded = b.addRunArtifact(exe_threaded);
    const run_sdl = b.addRunArtifact(exe_sdl);
    const run_renderaudio = b.addRunArtifact(exe_renderaudio);
    const run_wavwriter = b.addRunArtifact(exe_wavwriter);
    const run_sidfile = b.addRunArtifact(exe_sidfile);
    const run_sidplayer = b.addRunArtifact(exe_sidplayer);

    if (b.args) |args| {
        run_dumpplayer.addArgs(args);
        run_threaded.addArgs(args);
        run_sdl.addArgs(args);
        run_renderaudio.addArgs(args);
        run_wavwriter.addArgs(args);
        run_sidfile.addArgs(args);
        run_sidplayer.addArgs(args);
    }

    const run_step_dumpplayer = b.step(
        "run-dump-play",
        "Run the unthreaded dump player",
    );
    run_step_dumpplayer.dependOn(&run_dumpplayer.step);

    const run_step_threaded = b.step(
        "run-dump-play-threaded",
        "Run the threaded dump player",
    );
    run_step_threaded.dependOn(&run_threaded.step);

    const run_step_sdl = b.step(
        "run-sdl-player",
        "Run the SDL dump player",
    );
    run_step_sdl.dependOn(&run_sdl.step);

    const run_step_renderaudio = b.step(
        "run-render-audio",
        "Run the RenderAudio() demo",
    );
    run_step_renderaudio.dependOn(&run_renderaudio.step);

    const run_step_wavwriter = b.step(
        "run-wav-writer",
        "Run the Wav-Writer demo",
    );
    run_step_wavwriter.dependOn(&run_wavwriter.step);

    const run_step_sidfile = b.step(
        "run-sidfile",
        "Run the .sid file player test",
    );
    run_step_sidfile.dependOn(&run_sidfile.step);

    const run_step_sidplayer = b.step(
        "run-sid-player",
        "Run the real-time .SID file player",
    );
    run_step_sidplayer.dependOn(&run_sidplayer.step);
}
