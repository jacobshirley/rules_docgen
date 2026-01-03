#!/bin/bash
# This script generates a JSON mapping of files with their last updated timestamps from git history.

# Default values
FILTER_EXTENSIONS=""
OUTPUT_FILE=""
GIT_DIR=""
# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		--filter-extensions)
			FILTER_EXTENSIONS="$2"
			shift 2
			;;
		--output)
			OUTPUT_FILE="$2"
			shift 2
			;;
        --git-dir)
            GIT_DIR="$2"
            export GIT_DIR
            shift 2
            ;;
		*)
			echo "Unknown option: $1"
			echo "Usage: $0 --filter-extensions <extensions> [--output <file>]"
			echo "Example: $0 --filter-extensions md,txt --output timestamps.json"
			exit 1
			;;
	esac
done

# Validate required arguments
if [ -z "$FILTER_EXTENSIONS" ]; then
	echo "Usage: $0 --filter-extensions <extensions> [--output <file>]"
	echo "Extensions can be comma-separated (e.g., 'md', 'md,txt', 'js,ts,tsx')."
	echo "Example: $0 --filter-extensions md,txt --output timestamps.json"
	exit 1
fi

# Resolve git directory by following symlinks inside $GIT_DIR if necessary
if [ -d "$GIT_DIR" ]; then
	# The $GIT_DIR directory contains symlinks to the real git directory
	# Follow one of the symlinks (HEAD) to find the actual location
	if [ -L "$GIT_DIR/HEAD" ]; then
		# Get the target of the symlink and extract the directory
		HEAD_TARGET=$(readlink "$GIT_DIR/HEAD")
		REAL_GIT_DIR=$(dirname "$HEAD_TARGET")
		if [ -n "$REAL_GIT_DIR" ] && [ -f "$REAL_GIT_DIR/HEAD" ]; then
			export GIT_DIR="$REAL_GIT_DIR"
		fi
	fi
fi

# Get all modifications with dates, keep only the latest for each file (case-insensitive)
temp_file=$(mktemp)
current_date=""

# Convert extensions to a pattern for case matching
IFS=',' read -ra EXT_ARRAY <<< "$FILTER_EXTENSIONS"

# Process git log output line by line using process substitution to avoid subshell
while IFS=$'\t' read -r status file; do
    if [[ "$status" =~ ^DATE: ]]; then
        current_date="${status#DATE:}"
        # Normalize timezone format: replace +00:00 with Z for consistency across platforms
        current_date="${current_date/+00:00/Z}"
    elif [[ "$status" =~ ^[AMD] ]] && [ -n "$current_date" ] && [ -n "$file" ]; then
        # Check if file matches any of the extensions (case-insensitive)
        file_lower=$(echo "$file" | tr '[:upper:]' '[:lower:]')
        match=false
        for ext in "${EXT_ARRAY[@]}"; do
            if [[ "$file_lower" == *".$ext" ]]; then
                match=true
                break
            fi
        done

        # Only add if it matches extension and we haven't seen this file yet
        if [ "$match" = true ]; then
            # Check if we've already seen this file
            if ! grep -Fq "$file" "$temp_file"; then
                echo "$file|$current_date" >> "$temp_file"
            fi
        fi
    fi
done < <(git log --name-status --pretty=format:"DATE:%cI" --all)

# Generate JSON output from temp file
result_json="{"
first_entry=true

while IFS='|' read -r file timestamp; do
    if [ -n "$file" ] && [ -n "$timestamp" ]; then
        if [ "$first_entry" = false ]; then
            result_json+=","
        fi
        result_json+=$(printf '\n  "%s": "%s"' "$file" "$timestamp")
        first_entry=false
    fi
done < "$temp_file"

if [ "$first_entry" = false ]; then
    result_json+=$'\n'
fi
result_json+="}"

# Clean up temp file
rm -f "$temp_file"

# Output result to file or stdout
if [ -n "$OUTPUT_FILE" ]; then
	echo "$result_json" > "$OUTPUT_FILE"
	echo "Timestamps written to $OUTPUT_FILE" >&2
else
	echo "$result_json"
fi
