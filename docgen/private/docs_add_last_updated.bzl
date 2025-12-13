"""Rules for adding last updated timestamps to documentation."""

load(":providers.bzl", "DocsProviderInfo")
load(":utils.bzl", "UNIQUE_FOLDER_NAME")

def _docs_add_last_updated_impl(ctx):
    is_windows = ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo])
    
    out_folder = ctx.actions.declare_directory(ctx.attr.out_dir or ctx.label.name)

    date_format = ctx.attr.last_updated_date_format
    if not date_format:
        date_format = "+%B %d, %Y at %I:%M %p"

    update_history_url = ctx.attr.update_history_url

    if is_windows:
        # Windows: Use PowerShell template
        # PowerShell date format is different from Unix date format
        # Convert Unix format to PowerShell format
        ps_date_format = date_format.replace("+%B %d, %Y at %I:%M %p", "MMMM dd, yyyy 'at' hh:mm tt")
        
        script = ctx.actions.declare_file(ctx.label.name + "_script.ps1")
        ctx.actions.expand_template(
            template = ctx.file._windows_script_template,
            output = script,
            substitutions = {
                "{out_dir}": out_folder.path,
                "{json_file}": ctx.file.last_updated_json.path,
                "{date_format}": ps_date_format,
                "{update_history_url}": update_history_url if update_history_url else "",
                "{unique_folder_name}": UNIQUE_FOLDER_NAME,
            },
        )

        # Create a .bat wrapper to invoke PowerShell
        bat_wrapper = ctx.actions.declare_file(ctx.label.name + "_script.bat")
        ctx.actions.write(
            output = bat_wrapper,
            content = "@echo off\n%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File \"%~dp0{ps1_name}\" %*\n".format(
                ps1_name = script.basename,
            ),
            is_executable = True,
        )

        ctx.actions.run(
            inputs = ctx.files.docs + [ctx.file.last_updated_json, script],
            outputs = [out_folder],
            executable = bat_wrapper,
            arguments = [":".join([f.path, f.short_path]) for f in ctx.files.docs],
            mnemonic = "DocsAddLastUpdated",
            progress_message = "Adding last updated timestamps for %s" % ctx.label.name,
        )
    else:
        # Unix: Use shell template with coreutils and jq
        coreutils_bin = ctx.toolchains["@bazel_lib//lib:coreutils_toolchain_type"].coreutils_info.bin
        jq_bin = ctx.toolchains["@jq.bzl//jq/toolchain:type"].jqinfo.bin

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
        "_windows_script_template": attr.label(
            default = "//docgen/private/sh:docs_add_last_updated.ps1.tpl",
            allow_single_file = True,
        ),
        "_windows_constraint": attr.label(
            default = "@platforms//os:windows",
        ),
    },
    toolchains = [
        "@bazel_lib//lib:coreutils_toolchain_type",
        "@jq.bzl//jq/toolchain:type",
    ],
)
