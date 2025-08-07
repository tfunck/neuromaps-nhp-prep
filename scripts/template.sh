#!/bin/bash

BASE="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs"

# Step 1: Cleanup existing bad filenames starting with 'tpl-.'
find "$BASE" -type f -name "tpl-.*" | while read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")

    # Only fix if filename starts exactly with 'tpl-.'
    if [[ "$filename" == tpl-.* ]]; then
        fixed_name="${filename/tpl-./tpl-}"
        fixed_path="$dir/$fixed_name"

        if [[ "$filepath" != "$fixed_path" ]]; then
            echo "Fixing filename:"
            echo "  $filepath"
            echo "  -> $fixed_path"
            mv "$filepath" "$fixed_path"
        fi
    fi
done

# Step 2: Rename files without 'tpl-' prefix, prepend 'tpl-' and strip leading dot from filename
find "$BASE" -type f -name "*surf*" | while read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")

    # Skip files already starting with 'tpl-'
    if [[ "$filename" == tpl-* ]]; then
        echo "Skipping already renamed: $filename"
        continue
    fi

    # Remove leading dot if present to avoid tpl-.filename
    filename_no_dot="${filename#.}"

    new_filepath="$dir/tpl-$filename_no_dot"

    echo "Renaming:"
    echo "  $filepath"
    echo "  -> $new_filepath"
    mv "$filepath" "$new_filepath"
done
