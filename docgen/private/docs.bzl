load(":docs_action.bzl", "docs_action")
load("@bazel_lib//lib:utils.bzl", "file_exists")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load(":utils.bzl", "UNIQUE_FOLDER_NAME")

def docs(
        name = "docs",
        entry = "README.md",
        srcs = [
            "README.md",
        ],
        data = [],
        deps = [],
        tags = [],
        title = None,
        nav = {},
        out = None,
        readme_content = "",
        readme_header_links = {}):
    out_folder = (out or name) + "/" + UNIQUE_FOLDER_NAME + "/" + native.package_name()

    docs_action(
        name = name,
        srcs = srcs + data,
        deps = deps,
        title = title,
        entrypoint = entry if file_exists(entry) or entry.find(":") != -1 else None,
        nav = nav,
        out = out_folder,
        visibility = ["//visibility:public"],
        tags = ["docs"] + tags,
        readme_content = readme_content,
        readme_header_links = readme_header_links,
    )

    build_test(
        name = name + ".test",
        targets = [
            ":" + name,
        ],
    )

def docs_index(
        name = "docs",
        title = None,
        entry = None,
        nav = {},
        tags = []):
    docs_action(
        name = name,
        srcs = [],
        title = title,
        entrypoint = entry,
        nav = nav,
        visibility = ["//visibility:public"],
        tags = ["docs"] + tags,
    )

    build_test(
        name = name + ".test",
        targets = [
            ":" + name,
        ],
    )
