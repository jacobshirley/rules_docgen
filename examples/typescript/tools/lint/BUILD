load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

native_binary(
    name = "vale",
    src = select(
        {
            "@bazel_tools//src/conditions:linux_x86_64": "@vale_Linux_64-bit//:vale",
            "@bazel_tools//src/conditions:linux_aarch64": "@vale_Linux_arm64//:vale",
            "@bazel_tools//src/conditions:darwin_x86_64": "@vale_macOS_64-bit//:vale",
            "@bazel_tools//src/conditions:darwin_arm64": "@vale_macOS_arm64//:vale",
            "@bazel_tools//src/conditions:windows_x64": "@vale_Windows_64-bit//:vale.exe",
        },
    ),
    out = "vale",
)
