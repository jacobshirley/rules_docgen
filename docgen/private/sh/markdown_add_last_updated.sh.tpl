#!/bin/bash

function update_file {
    input_path="$1"
    output_path="$2"

    if [ ! -f "$input_path" ]; then
        return
    fi

    if [[ "$input_path" != *".md" ]]; then
        {coreutils} mkdir -p "{out_dir}/$(dirname "$output_path")"
        {coreutils} cp "$input_path" "{out_dir}/$output_path"
        {coreutils} chmod 644 "{out_dir}/$output_path"
        return
    fi

    {coreutils} mkdir -p "{out_dir}/$(dirname "$output_path")"
    {coreutils} cp "$input_path" "{out_dir}/$output_path"
    {coreutils} chmod 644 "{out_dir}/$output_path"

    # For JSON lookup, strip everything up to and including the unique folder name
    json_lookup_path=$(echo "$output_path" | sed 's|^.*{unique_folder_name}/||')
    last_update_raw=$({jq} -r --arg file "$json_lookup_path" '.[$file] // "Unknown"' "{json_file}")

    has_update="false"
    # Format the date if it's not "Unknown"
    if [ "$last_update_raw" != "Unknown" ]; then
        has_update="true"
        # Convert ISO 8601 to readable format
        last_update=$({coreutils} date -d "$last_update_raw" "{date_format}" 2>/dev/null || echo "$last_update_raw")
    else
        last_update=$({coreutils} date "{date_format}")
    fi

    # Add last updated information to the footer
    footer_line="\n---"

    # If update history URL is provided, add it to the footer
    update_history_url="{update_history_url}"
    if [ -n "$update_history_url" ] && [ "$has_update" = "true" ]; then
        footer_line+="\nLast updated: [$last_update]({update_history_url}/$output_path)"
    else
        footer_line+="\nLast updated: $last_update"
    fi

    printf "%b\n" "$footer_line" >> "{out_dir}/$output_path"
}

for arg in "$@"; do
    # Split argument by colon to get long_path:short_path
    IFS=':' read -r long_path short_path <<< "$arg"

    if [ -d "$long_path" ]; then
        find -L "$long_path" -type f -print0 | while IFS= read -r -d '' f; do
            # Calculate relative path from the directory
            rel_path="${f#$long_path/}"
            out_path="$rel_path"

            echo $out_path

            update_file "$f" "$out_path"
        done
    elif [ -f "$long_path" ]; then
        if [ -n "$short_path" ]; then
            update_file "$long_path" "$short_path"
        else
            # Extract just the filename from long_path
            filename=$(basename "$long_path")
            update_file "$long_path" "$filename"
        fi
    fi
done
