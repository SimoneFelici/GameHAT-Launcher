const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "GameHAT_Launcher",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const known_folders = b.dependency("known_folders", .{
        .target = target,
        .optimize = optimize,
    }).module("known-folders");

    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

    exe.root_module.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);
    exe.root_module.addImport("known-folders", known_folders);

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // CROSS COMPILE
    const gamehat_sysroot = b.option(
        []const u8,
        "sysroot",
        "Sysroot path",
    ) orelse "/home/blue/sysroot-gamehat";

    const gamehat_target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .linux,
        .abi = .gnu,
    });

    const gamehat_exe = b.addExecutable(.{
        .name = "GameHAT_Launcher",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = gamehat_target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });

    const gamehat_raylib_dep = b.dependency("raylib_zig", .{
        .target = gamehat_target,
        .optimize = optimize,
        .linkage = .dynamic,
        .opengl_version = .gl_2_1,
    });

    const gamehat_raylib = gamehat_raylib_dep.module("raylib");
    const gamehat_raygui = gamehat_raylib_dep.module("raygui");
    const gamehat_raylib_artifact = gamehat_raylib_dep.artifact("raylib");

    const gamehat_lib_multiarch = b.pathJoin(&.{ gamehat_sysroot, "usr", "lib", "aarch64-linux-gnu" });
    const gamehat_lib_root = b.pathJoin(&.{ gamehat_sysroot, "usr", "lib" });
    const gamehat_include = b.pathJoin(&.{ gamehat_sysroot, "usr", "include" });

    gamehat_raylib_artifact.root_module.addLibraryPath(.{ .cwd_relative = gamehat_lib_multiarch });
    gamehat_raylib_artifact.root_module.addLibraryPath(.{ .cwd_relative = gamehat_lib_root });
    gamehat_raylib_artifact.root_module.addSystemIncludePath(.{ .cwd_relative = gamehat_include });

    gamehat_exe.root_module.addLibraryPath(.{ .cwd_relative = gamehat_lib_multiarch });
    gamehat_exe.root_module.addLibraryPath(.{ .cwd_relative = gamehat_lib_root });

    gamehat_exe.root_module.linkLibrary(gamehat_raylib_artifact);
    gamehat_exe.root_module.addImport("raylib", gamehat_raylib);
    gamehat_exe.root_module.addImport("raygui", gamehat_raygui);

    const install_gamehat = b.addInstallArtifact(gamehat_exe, .{
        .dest_dir = .{ .override = .{ .custom = "gamehat" } },
    });
    const install_gamehat_raylib = b.addInstallArtifact(gamehat_raylib_artifact, .{
        .dest_dir = .{ .override = .{ .custom = "gamehat" } },
    });
    const gamehat_step = b.step("gamehat", "GAME-HAT Cross-Compile");
    gamehat_step.dependOn(&install_gamehat.step);
    gamehat_step.dependOn(&install_gamehat_raylib.step);
}
