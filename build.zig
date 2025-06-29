const std = @import("std");
const patch = @import("patch");
const PatchStep = patch.PatchStep;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const native_target = b.resolveTargetQuery(.{});
    const optimize = b.standardOptimizeOption(.{});

    const reactos_dep = b.dependency("reactos", .{});

    const comsupp_patch = PatchStep.create(b, .{
        .root_directory = reactos_dep.path("sdk/lib/comsupp"),
        .target = native_target,
        .optimize = optimize,
        .strip = 4,
    });
    comsupp_patch.addPatch(b.path("patch/0001-remove-comdef.patch"));
    const comsupp_dir = comsupp_patch.getDirectory();

    const comsupp = b.addStaticLibrary(.{
        .name = "comsupp",
        .target = target,
        .optimize = optimize,
    });
    comsupp.addCSourceFiles(.{
        .root = comsupp_dir,
        .files = &.{"comsupp.cpp"},
        .flags = &.{"-DWIN_LEAN_AND_MEAN"},
    });
    comsupp.linkLibCpp();
    b.installArtifact(comsupp);
}
