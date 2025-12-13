"""Core documentation processing rules."""

load("@bazel_lib//lib:utils.bzl", "file_exists")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load(":docs_action.bzl", "docs_action")
load(":utils.bzl", "UNIQUE_FOLDER_NAME")

def docs(
        name = "docs",
        entry = "README.md",
        srcs = [
            "README.md",
        ],
        data = [],
        deps = [],
        title = None,
        nav = {},
        out = None,
        readme_content = "",
        readme_header_links = {},
        **kwargs):
    out_folder = (out or name) + "/" + UNIQUE_FOLDER_NAME + "/" + native.package_name()

    valid_target = file_exists(entry) or entry.find(":") != -1

    docs_action(
        name = name,
        srcs = srcs + data,
        deps = deps,
        title = title,
        entrypoint = entry if valid_target else None,
        nav = nav,
        out = out_folder,
        readme_filename = entry if not valid_target else None,
        readme_content = readme_content,
        readme_header_links = readme_header_links,
        **kwargs
    )

    build_test(
        name = name + ".test",
        targets = [
            ":" + name,
        ],
    )
