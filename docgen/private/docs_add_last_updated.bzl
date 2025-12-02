load(":providers.bzl", "DocsProviderInfo")

def _docs_add_last_updated_impl(ctx):
    out_folder = ctx.actions.declare_directory(ctx.label.name)

    coreutils_bin = ctx.toolchains["@bazel_lib//lib:coreutils_toolchain_type"].coreutils_info.bin

    # Create a shell action to find all markdown files and write their paths to stdout

    date_format = ctx.attr.last_updated_date_format
    if not date_format:
        date_format = "+%B %d, %Y at %I:%M %p"

    update_history_url = ctx.attr.update_history_url

    # TODO: use coreutils for mkdir etc
    # TODO: add jq as a toolchain

    ctx.actions.run_shell(
        inputs = ctx.files.docs + [ctx.file.last_updated_json],
        outputs = [out_folder],
        tools = [coreutils_bin],
        mnemonic = "DocsAddLastUpdated",
        command = """
        function update_file {{
            f="$1"

            if [ ! -f "$f" ]; then
                return
            fi

            if [[ "$f" != *".md" ]]; then
                {coreutils} mkdir -p "{folder}/$(dirname "$f")"
                {coreutils} cp "$f" "{folder}/$f"
                {coreutils} chmod 644 "{folder}/$f"
                return
            fi

            {coreutils} mkdir -p "{folder}/$(dirname "$f")"

            # Use cp -L to dereference symlinks and copy actual file content
            {coreutils} cp "$f" "{folder}/$f"
            {coreutils} chmod 644 "{folder}/$f"

            rel_path=$(echo "$f" | sed 's|^.*/_bazel_docs/||')
            last_update_raw=$(jq -r --arg file "$rel_path" '.[$file] // "Unknown"' "{json_file}")

            has_update="false"
            # Format the date if it's not "Unknown"
            if [ "$last_update_raw" != "Unknown" ]; then
                has_update="true"
                # Convert ISO 8601 to readable format
                last_update=$(date -d "$last_update_raw" "{date_format}" 2>/dev/null || echo "$last_update_raw")
            else
                last_update=$(date "{date_format}")
            fi

            # Add last updated information to the footer
            footer_line="---\n"

            # If update history URL is provided, add it to the footer
            update_history_url="{update_history_url}"
            if [ -n "$update_history_url" ] && [ "$has_update" = "true" ]; then
                footer_line+="Last updated: [$last_update]({update_history_url}/$rel_path)\n"
            else
                footer_line+="Last updated: $last_update\n"
            fi

            echo "\n\n$footer_line" >> "{folder}/$f"
        }}

        for file in "$@"; do
            if [ -d "$file" ]; then   
                find -L "$file" -type f -print0 | while IFS= read -r -d '' f; do
                    update_file "$f"
                done
            elif [ -f "$file" ]; then
                update_file "$file"
            fi
        done
        """.format(
            folder = out_folder.path,
            out_dir = out_folder.path,
            json_file = ctx.file.last_updated_json.path,
            date_format = date_format,
            update_history_url = update_history_url if update_history_url else "",
            coreutils = coreutils_bin.path,
        ),
        arguments = [f.path for f in ctx.files.docs],
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
        "last_updated_date_format": attr.string(
            doc = "The date format to use for last updated timestamps",
            default = "+%B %d, %Y at %I:%M %p",
        ),
        "update_history_url": attr.string(
            doc = "The URL to the update history",
        ),
    },
    toolchains = [
        "@bazel_lib//lib:coreutils_toolchain_type",
        "@bazel_lib//lib:copy_to_directory_toolchain_type",
    ],
)