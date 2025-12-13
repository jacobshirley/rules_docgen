"""Rules for extracting last updated timestamps from git history."""

def _git_last_updated_timestamps_impl(ctx):
    is_windows = ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo])

    out = ctx.actions.declare_file(ctx.attr.out)

    # Build arguments for the script
    filter_exts = ",".join(ctx.attr.filter_extensions)

    args = ctx.actions.args()
    args.add("--filter-extensions")
    args.add(filter_exts)
    args.add("--output")
    args.add(out.path)
    args.add("--git-dir")
    args.add(ctx.attr.git_dir)

    if is_windows:
        script = ctx.executable._windows_script

        ctx.actions.run(
            inputs = ctx.files.srcs,
            outputs = [out],
            executable = script,
            arguments = [args],
            use_default_shell_env = True,
            mnemonic = "GitLastUpdatedTimestamps",
            progress_message = "Extracting git timestamps for %s" % ctx.label.name,
        )
    else:
        # On Unix, run the script directly
        script = ctx.executable._sh_script

        ctx.actions.run(
            inputs = ctx.files.srcs,
            outputs = [out],
            executable = script,
            arguments = [args],
            use_default_shell_env = True,
            mnemonic = "GitLastUpdatedTimestamps",
            progress_message = "Extracting git timestamps for %s" % ctx.label.name,
        )

    return [DefaultInfo(files = depset([out]))]

git_last_updated_timestamps = rule(
    implementation = _git_last_updated_timestamps_impl,
    attrs = {
        "git_dir": attr.string(
            doc = "Path to the .git directory",
            default = ".git",
        ),
        "srcs": attr.label_list(
            doc = "Source files to track (git directory contents)",
            allow_files = True,
        ),
        "out": attr.string(
            doc = "Output JSON file name",
            default = "git-timestamps.json",
        ),
        "filter_extensions": attr.string_list(
            doc = "List of file extensions to filter",
            default = ["md", "rst", "txt"],
        ),
        "_sh_script": attr.label(
            default = "//docgen/private/sh:git-last-updated-timestamps.sh",
            cfg = "exec",
            executable = True,
            doc = "The shell script to extract git last updated timestamps",
            allow_single_file = True,
        ),
        "_windows_script": attr.label(
            default = "//docgen/private/sh:git-last-updated-timestamps.bat",
            cfg = "exec",
            executable = True,
            doc = "The windows script to extract git last updated timestamps",
            allow_single_file = True,
        ),
        "_windows_constraint": attr.label(
            default = "@platforms//os:windows",
        ),
    },
)
