"""Rules for serving MkDocs documentation sites locally."""

load(":utils.bzl", "collect_inputs")

def _mkdocs_serve_impl(ctx):
    mkdocs_bin = ctx.executable.mkdocs_executable

    transitive_runfiles = []
    transitive_runfiles.append(ctx.attr.mkdocs_executable[DefaultInfo].default_runfiles)

    docs_folder, config = collect_inputs(ctx, root = ctx.attr.root_nav_folder)
    serve_sh = ctx.actions.declare_file(ctx.label.name + ".sh")

    inputs = [docs_folder, config]

    # Write the mkdocs.yml file
    ctx.actions.write(
        output = serve_sh,
        content = "\n".join([
            "#!/bin/bash",
            "set -e",
            "./{mkdocs} serve -f {config}".format(mkdocs = mkdocs_bin.short_path, config = config.short_path),
        ]),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.mkdocs_executable + inputs + ctx.attr.mkdocs_executable[DefaultInfo].files.to_list())
    runfiles = runfiles.merge_all(transitive_runfiles)

    return [
        DefaultInfo(
            executable = serve_sh,
            runfiles = runfiles.merge_all(transitive_runfiles),
        ),
    ]

mkdocs_serve = rule(
    doc = """Serve MkDocs documentation locally for development.

    This rule creates an executable that runs the MkDocs development server,
    allowing you to preview your documentation with live reload support.
    When used with ibazel, changes to source files will automatically rebuild
    and reload the documentation in your browser.

    Example:
        mkdocs_serve(
            name = "mkdocs.serve",
            config = ":mkdocs_config",
            docs = [":docs"],
        )

    Run with:
        bazel run //:mkdocs.serve
        # or for live reload:
        ibazel run //:mkdocs.serve

    The server will be available at http://localhost:8000 by default.
    """,
    implementation = _mkdocs_serve_impl,
    attrs = {
        "mkdocs_executable": attr.label(
            doc = "The mkdocs executable. Defaults to @mkdocs//:mkdocs from the docgen extension.",
            executable = True,
            cfg = "exec",
            mandatory = True,
        ),
        "docs": attr.label_list(
            doc = "The docs to include in the site",
            allow_files = True,
        ),
        "git_folder": attr.label(
            doc = "The git files to use to get last updated information",
            allow_single_file = True,
        ),
        "data": attr.label_list(
            doc = "The data files to include in the site",
            allow_files = True,
        ),
        "config": attr.label(
            doc = "The mkdocs.yml file",
            allow_single_file = [".yaml", ".yml"],
            mandatory = True,
        ),
        "docs_dir": attr.string(
            doc = "The directory containing the docs",
            default = "docs",
        ),
        "root_nav_folder": attr.string(
            doc = "The root nav folder",
            default = "",
        ),
    },
    toolchains = [
        "@bazel_lib//lib:copy_to_directory_toolchain_type",
        "@bazel_lib//lib:coreutils_toolchain_type",
        "@bazel_lib//lib:copy_directory_toolchain_type",
    ],
    executable = True,
)
