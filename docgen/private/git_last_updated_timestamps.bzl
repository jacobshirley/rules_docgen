"""Rules for extracting last updated timestamps from git history."""

def _git_last_updated_timestamps_impl(ctx):
    out = ctx.actions.declare_file(ctx.attr.out)
    script = ctx.executable._script

    # Build arguments
    args = ctx.actions.args()
    args.add("--filter-extensions")
    args.add(",".join(ctx.attr.filter_extensions))
    args.add("--output")
    args.add(out.path)
    args.add("--git-dir")
    args.add(ctx.attr.git_dir)

    ctx.actions.run(
        inputs = ctx.files.srcs,
        outputs = [out],
        executable = script,
        arguments = [args],
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
        "_script": attr.label(
            default = "//docgen/private/sh:git-last-updated-timestamps.sh",
            executable = True,
            cfg = "exec",
            allow_single_file = True,
        ),
    },
)
