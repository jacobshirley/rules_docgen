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
RESULT=$(git log --name-status --pretty=format:"DATE:%cI" --all |
	awk -v exts="$FILTER_EXTENSIONS" '
BEGIN {
    FS = "\t"
    current_date = ""
    # Split extensions by comma and build regex pattern
    split(exts, ext_array, ",")
    pattern = ""
    for (i in ext_array) {
        if (pattern != "") pattern = pattern "|"
        pattern = pattern "\\." ext_array[i] "$"
    }
}
/^DATE:/ {
    current_date = substr($0, 6)  # Remove "DATE:" prefix
    # Normalize timezone format: replace +00:00 with Z for consistency across platforms
    gsub(/\+00:00$/, "Z", current_date)
    next
}
/^[AMD]/ {
    file = $2
    if (tolower(file) ~ pattern && current_date != "" && !(file in files)) {
        files[file] = current_date
    }
}
END {
    print "{"
    count = 0
    for (file in files) {
        count++
    }
    i = 0
    for (file in files) {
        i++
        printf "  \"%s\": \"%s\"", file, files[file]
        if (i < count) {
            printf ","
        }
        printf "\n"
    }
    print "}"
}')

# Output result to file or stdout
if [ -n "$OUTPUT_FILE" ]; then
	echo "$RESULT" > "$OUTPUT_FILE"
	echo "Timestamps written to $OUTPUT_FILE" >&2
else
	echo "$RESULT"
fi
