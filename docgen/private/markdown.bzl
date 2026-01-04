"""Internal markdown processing actions."""

load("@bazel_lib//lib:paths.bzl", "to_repository_relative_path")
load(":providers.bzl", "DocsLinkInfo", "MarkdownInfo")

def markdown_action(ctx):
    """Implementation function for markdown rule.

    Modifies markdown files with header links and custom content.

    Args:
        ctx: The rule context.

    Returns:
        A list of providers including DefaultInfo and MarkdownInfo.
    """

    coreutils_bin = ctx.toolchains["@bazel_lib//lib:coreutils_toolchain_type"].coreutils_info.bin

    files = []
    header = []

    # Build header links
    for key, value in ctx.attr.readme_header_links.items():
        if (DocsLinkInfo in key):
            link = ""
            if (key[DocsLinkInfo].entrypoint):
                link = key[DocsLinkInfo].entrypoint
            elif (key[DocsLinkInfo].url):
                link = key[DocsLinkInfo].url
            else:
                link = key.label.name

            if not link:
                fail("DocsLinkInfo {} has no link".format(key.label.name))

            header.append("[**{title}**]({link})".format(
                title = value if value and value != "" else key[DocsLinkInfo].title,
                link = link,
            ))

            for f in key[DocsLinkInfo].files:
                files.append(f)
        else:
            header.append("[**{title}**]({link})".format(
                title = value if value and value != "" else key.label.name,
                link = key.label.name,
            ))

    # Generate content
    md_header_line = " | ".join(header) + "\n" if len(header) > 0 else ""
    md_content = ctx.attr.readme_content or ""

    md_content = "\n".join([
        md_header_line,
        md_content,
    ]).strip()

    output_path = ctx.attr.output or ctx.file.file.short_path
    output_file = None
    entrypoint_file_path = None

    if (md_content != ""):
        if (ctx.attr.file):
            # Prepend content to existing file
            output_file = ctx.actions.declare_file(output_path)

            ctx.actions.run_shell(
                inputs = [ctx.file.file],
                outputs = [output_file],
                tools = [coreutils_bin],
                mnemonic = "MarkdownGen",
                command = "echo \"{content}\" | {coreutils} cat - \"{input}\" > \"{output}\"".format(
                    content = "{}".format(md_content),
                    coreutils = coreutils_bin.path,
                    input = ctx.file.file.path,
                    output = output_file.path,
                ),
            )

            entrypoint_file_path = to_repository_relative_path(output_file)
        else:
            # Create new markdown file
            output_file = ctx.actions.declare_file(output_path)
            entrypoint_file_path = to_repository_relative_path(output_file)

            ctx.actions.write(
                output = output_file,
                content = md_content,
                is_executable = False,
            )

        files.append(output_file)
    elif (ctx.file.file):
        # Use existing entrypoint without modification
        output_file = ctx.file.file
        files.append(ctx.file.file)
        entrypoint_file_path = to_repository_relative_path(output_file)

    return [
        DefaultInfo(
            files = depset([output_file] if output_file else []),
        ),
        MarkdownInfo(
            file = output_file,
            entrypoint = entrypoint_file_path,
            files = files,
        ),
    ]

markdown = rule(
    implementation = markdown_action,
    doc = """
    Modifies markdown files with header links and custom content generation.
    """,
    attrs = {
        "title": attr.string(
            doc = "The title of the markdown document",
        ),
        "file": attr.label(
            doc = "The markdown file to modify",
            allow_single_file = [".md"],
        ),
        "output": attr.string(
            doc = "The filename of the README.md file when creating new content",
        ),
        "readme_content": attr.string(
            doc = "The content of the README.md file",
            default = "",
        ),
        "readme_header_links": attr.label_keyed_string_dict(
            doc = "The links to add to the README.md file header",
            allow_files = True,
            providers = [DocsLinkInfo],
        ),
    },
    toolchains = [
        "@bazel_lib//lib:coreutils_toolchain_type",
    ],
)
