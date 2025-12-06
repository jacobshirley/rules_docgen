#!/bin/bash
# This script generates a JSON mapping of files with their last updated timestamps from git history.

if [ -z "$1" ]; then
	echo "Usage: $0 <filter-extension>"
	echo "Extension can be 'md' for Markdown files."
	exit 1
fi

# Get all modifications with dates, keep only the latest for each .md file (case-insensitive)
git log --name-status --pretty=format:"DATE:%cI" --all |
	awk -v ext="$1" '
BEGIN { 
    FS = "\t"
    current_date = ""
}
/^DATE:/ { 
    current_date = substr($0, 6)  # Remove "DATE:" prefix
    next
}
/^[AMD]/ {
    file = $2
    if (tolower(file) ~ ("\\." ext "$") && current_date != "" && !(file in files)) {
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
}'