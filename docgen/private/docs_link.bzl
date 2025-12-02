load(":providers.bzl", "DocsLinkInfo")

def _docs_link_impl(ctx):
    return [
        DefaultInfo(
            files = depset(ctx.files.data),
        ),
        DocsLinkInfo(
            title = ctx.attr.title,
            url = ctx.attr.url,
            entrypoint = ctx.attr.entrypoint if ctx.attr.entrypoint != "" else None,
            files = ctx.files.data,
        ),
    ]

docs_link = rule(
    implementation = _docs_link_impl,
    attrs = {
        "title": attr.string(
            doc = "The title of the navigation element",
        ),
        "url": attr.string(
            doc = "The URL of the navigation element",
        ),
        "entrypoint": attr.string(
            doc = "The entrypoint file for the documentation",
            default = "",
        ),
        "data": attr.label_list(
            doc = "The data files that are part of the documentation",
        ),
    },
    toolchains = [
        "@bazel_lib//lib:copy_to_directory_toolchain_type",
    ],
)