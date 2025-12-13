"""Core documentation index processing rules."""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load(":docs_action.bzl", "docs_action")

def docs_index(
        name = "docs",
        title = None,
        entry = None,
        nav = {},
        **kwargs):
    docs_action(
        name = name,
        srcs = [],
        title = title,
        entrypoint = entry,
        nav = nav,
        **kwargs
    )

    build_test(
        name = name + ".test",
        targets = [
            ":" + name,
        ],
    )
