load(":utils.bzl", "collect_inputs")

def _mkdocs_build_impl(ctx):
    mkdocs_bin = ctx.executable.mkdocs_executable

    docs_folder, config = collect_inputs(ctx, root = ctx.attr.root_nav_folder)

    inputs = [docs_folder, config]

    out = ctx.actions.declare_directory(ctx.label.name + "/" + ctx.attr.site_dir)

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = [out],
        tools = [mkdocs_bin],
        progress_message = "[mkdocs] Generating site",
        command = "{mkdocs} build $@".format(
            mkdocs = mkdocs_bin.path,
        ),
        arguments = [
            "-f",
            config.path,
            "--site-dir",
            out.basename,
        ],
        use_default_shell_env = ctx.attr.use_default_shell_env,
    )

    return [
        DefaultInfo(
            files = depset([out]),
        ),
    ]

mkdocs_build = rule(
    implementation = _mkdocs_build_impl,
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
        "site_dir": attr.string(
            doc = "The output directory for the site",
            default = "site",
        ),
        "root_nav_folder": attr.string(
            doc = "The root nav folder",
            default = "",
        ),
        "use_default_shell_env": attr.bool(
            doc = "Use the default shell environment",
            default = False,
        ),
    },
    toolchains = [
        "@bazel_lib//lib:copy_to_directory_toolchain_type",
    ],
)