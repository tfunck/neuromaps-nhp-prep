#!/bin/bash

BASE="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs"

# Find all files starting with 'tpl-' and rename them to remove the prefix
find "$BASE" -type f -name "tpl-*" | while read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")

    # Only act on files that start with 'tpl-'
    if [[ "$filename" == tpl-* ]]; then
        # Remove the 'tpl-' prefix
        new_filename="${filename#tpl-}"
        new_filepath="$dir/$new_filename"

        echo "Renaming:"
        echo "  $filepath"
        echo "  -> $new_filepath"
        mv "$filepath" "$new_filepath"
    fi
done
