"""Core documentation processing rules."""

load("@bazel_lib//lib:utils.bzl", "file_exists")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load(":docs_action.bzl", "docs_action")
load(":markdown_action.bzl", "markdown_action")

def docs(
        name = "docs",
        entrypoint = "README.md",
        srcs = [],
        data = [],
        deps = [],
        title = None,
        nav = {},
        out = None,
        readme_content = "",
        readme_header_links = {},
        test = True,
        **kwargs):
    """Generate documentation from markdown files.

    This macro creates a documentation target that processes markdown files and generates
    a navigation structure. It can either use an existing entry file or generate one from
    provided content.

    Args:
        name: Name of the documentation target. Defaults to "docs".
        entrypoint: The entry point markdown file for the documentation. If the file doesn't exist,
            it will be generated with content from readme_content. Defaults to "README.md".
        srcs: List of source markdown files to include in the documentation. Defaults to ["README.md"].
        data: Additional data files to include (images, assets, etc.).
        deps: Documentation dependencies - other docs/docs_index/docs_link targets.
        title: Title of the documentation section. If not provided, defaults to the package name.
        nav: Navigation structure dictionary. Keys can be:
            - "path/to/file.md": "Display Name" for markdown files
            - ":link_target": "Display Name" for docs_link targets
            - ":docs_target": "Display Name" for other docs targets
            - ":index_target": "" for docs_index targets (empty string uses index's title)
        out: Output directory for generated documentation. If not specified, uses the target name.
        readme_content: Content for the generated entry file if it doesn't exist as a file.
        readme_header_links: Dictionary of links to add to the README header. Format same as nav.
        test: Whether to create a build_test target for this documentation target. Defaults to True.
        **kwargs: Additional arguments passed to the underlying docs_action rule.
    """
    valid_target = (file_exists(entrypoint) or entrypoint.find(":") != -1) if entrypoint else False

    entrypoint_target = entrypoint if valid_target else None
    if (readme_content != "" or len(readme_header_links) > 0):
        markdown_action(
            name = name + "__md",
            file = entrypoint_target,
            output = entrypoint,
            readme_content = readme_content,
            readme_header_links = readme_header_links,
        )

        entrypoint_target = ":" + name + "__md"

    docs_action(
        name = name,
        srcs = srcs + data,
        deps = deps,
        title = title,
        entrypoint = entrypoint_target,
        nav = nav,
        out = out,
        **kwargs
    )

    if test:
        build_test(
            name = name + ".test",
            targets = [
                ":" + name,
            ],
        )
