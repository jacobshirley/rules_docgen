load("@bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory_bin_action")

UNIQUE_FOLDER_NAME = "_bazel_docs"

def collect_inputs(ctx, root = ""):
    docs_folder = ctx.actions.declare_directory(ctx.label.name + "/" + ctx.attr.docs_dir)

    copy_to_directory_bin = ctx.toolchains["@bazel_lib//lib:copy_to_directory_toolchain_type"].copy_to_directory_info.bin

    replace_prefixes = {
        "**/{}".format(UNIQUE_FOLDER_NAME): "",
    }

    if (root != ""):
        replace_prefixes["**/{}".format(root)] = ""

    # Copy docs
    copy_to_directory_bin_action(
        ctx = ctx,
        copy_to_directory_bin = copy_to_directory_bin,
        name = "_" + ctx.label.name + "_docs",
        files = ctx.files.docs + ctx.files.data,
        dst = docs_folder,
        replace_prefixes = replace_prefixes,
        include_external_repositories = ["*"],
        allow_overwrites = True,
    )

    config = ctx.actions.declare_file(ctx.label.name + "/" + ctx.file.config.basename)

    ctx.actions.symlink(
        output = config,
        target_file = ctx.file.config,
    )

    return [
        docs_folder,
        config,
    ]