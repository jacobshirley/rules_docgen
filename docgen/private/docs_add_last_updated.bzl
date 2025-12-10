load(":providers.bzl", "DocsProviderInfo")
load(":utils.bzl", "UNIQUE_FOLDER_NAME")

def _docs_add_last_updated_impl(ctx):
    out_folder = ctx.actions.declare_directory(ctx.attr.out_dir or ctx.label.name)

    coreutils_bin = ctx.toolchains["@bazel_lib//lib:coreutils_toolchain_type"].coreutils_info.bin
    jq_bin = ctx.toolchains["@jq.bzl//jq/toolchain:type"].jqinfo.bin

    date_format = ctx.attr.last_updated_date_format
    if not date_format:
        date_format = "+%B %d, %Y at %I:%M %p"

    update_history_url = ctx.attr.update_history_url

    # TODO: add jq as a toolchain

    # Expand the template script
    script = ctx.actions.declare_file(ctx.label.name + "_script.sh")
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = script,
        substitutions = {
            "{out_dir}": out_folder.path,
            "{json_file}": ctx.file.last_updated_json.path,
            "{date_format}": date_format,
            "{update_history_url}": update_history_url if update_history_url else "",
            "{unique_folder_name}": UNIQUE_FOLDER_NAME,
            "{coreutils}": coreutils_bin.path,
            "{jq}": jq_bin.path,
        },
    )

    ctx.actions.run_shell(
        inputs = ctx.files.docs + [ctx.file.last_updated_json, script],
        outputs = [out_folder],
        tools = [coreutils_bin, jq_bin],
        mnemonic = "DocsAddLastUpdated",
        command = "{script} \"$@\"".format(script = script.path),
        arguments = [":".join([f.path, f.short_path]) for f in ctx.files.docs],
    )

    files = depset([out_folder])

    return [
        DefaultInfo(
            files = files,
        ),
        DocsProviderInfo(
            title = ctx.attr.docs[DocsProviderInfo].title,
            files = files,
            entrypoint = ctx.attr.docs[DocsProviderInfo].entrypoint,
            nav = ctx.attr.docs[DocsProviderInfo].nav if DocsProviderInfo in ctx.attr.docs else [],
        ),
    ]

docs_add_last_updated = rule(
    implementation = _docs_add_last_updated_impl,
    attrs = {
        "last_updated_json": attr.label(
            doc = "JSON file with a key->value mapping of file paths to last updated timestamps",
            allow_single_file = True,
            mandatory = True,
        ),
        "docs": attr.label(
            doc = "The docs to add last updated information to",
            mandatory = True,
            providers = [DocsProviderInfo],
        ),
        "out_dir": attr.string(
            doc = "The output directory for the docs with last updated information",
            default = "",
        ),
        "last_updated_date_format": attr.string(
            doc = "The date format to use for last updated timestamps",
            default = "+%B %d, %Y at %I:%M %p",
        ),
        "update_history_url": attr.string(
            doc = "The URL to the update history",
        ),
        "_script_template": attr.label(
            default = "//docgen/private/sh:docs_add_last_updated.sh.tpl",
            allow_single_file = True,
        ),
    },
    toolchains = [
        "@bazel_lib//lib:coreutils_toolchain_type",
        "@jq.bzl//jq/toolchain:type",
    ],
)
