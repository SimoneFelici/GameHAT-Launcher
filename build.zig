const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const host_raylib = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const exe = addLauncher(b, target, optimize, host_raylib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // CROSS COMPILE
    const sysroot = b.option([]const u8, "sysroot", "Sysroot path") orelse
        "/home/blue/sysroot-gamehat";

    const gh_target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .linux,
        .abi = .gnu,
    });

    const gh_raylib = b.dependency("raylib_zig", .{
        .target = gh_target,
        .optimize = optimize,
        .linkage = .dynamic,
        .linux_display_backend = .Wayland,
        .opengl_version = .gles_2,
    });

    const gh_exe = addLauncher(b, gh_target, optimize, gh_raylib);
    const gh_artifact = gh_raylib.artifact("raylib");

    const lib_multiarch = b.pathJoin(&.{ sysroot, "usr", "lib", "aarch64-linux-gnu" });
    const lib_root = b.pathJoin(&.{ sysroot, "usr", "lib" });
    const include = b.pathJoin(&.{ sysroot, "usr", "include" });

    for ([_]*std.Build.Module{ gh_exe.root_module, gh_artifact.root_module }) |mod| {
        mod.addLibraryPath(.{ .cwd_relative = lib_multiarch });
        mod.addLibraryPath(.{ .cwd_relative = lib_root });
    }
    gh_artifact.root_module.addSystemIncludePath(.{ .cwd_relative = include });

    const gh_step = b.step("gamehat", "GAME-HAT Cross-Compile");
    gh_step.dependOn(&b.addInstallArtifact(gh_exe, .{
        .dest_dir = .{ .override = .{ .custom = "gamehat" } },
        .h_dir = .disabled,
    }).step);
    gh_step.dependOn(&b.addInstallArtifact(gh_artifact, .{
        .dest_dir = .{ .override = .{ .custom = "gamehat" } },
        .h_dir = .disabled,
    }).step);
}

fn addLauncher(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    raylib_dep: *std.Build.Dependency,
) *std.Build.Step.Compile {
    const known_folders = b.dependency("known_folders", .{
        .target = target,
        .optimize = optimize,
    }).module("known-folders");

    const exe = b.addExecutable(.{
        .name = "GameHAT_Launcher",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.root_module.linkLibrary(raylib_dep.artifact("raylib"));
    exe.root_module.addImport("raylib", raylib_dep.module("raylib"));
    exe.root_module.addImport("raygui", raylib_dep.module("raygui"));
    exe.root_module.addImport("known-folders", known_folders);

    return exe;
}
