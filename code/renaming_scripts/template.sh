#!/bin/bash

ROOT_FOLDER="/neuromaps-nhp-prep/share/Inputs"

find "$ROOT_FOLDER" -type f -name "*surf*" | while read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")
    subdir=$(basename "$dir")

    # Remove other instances of the subdir in the filename (case-insensitive)
    filename_cleaned=$(echo "$filename" | sed -E "s/${subdir}//Ig")

    # Ensure filename starts with tpl-
    if [[ "$filename_cleaned" != tpl-* ]]; then
        filename_cleaned="tpl-${filename_cleaned}"
    fi

    # Insert subdir after tpl- and before the rest, with trailing underscore
    filename_fixed=$(echo "$filename_cleaned" | sed -E "s/^tpl-/tpl-${subdir}_/")

    # If filename didn't change, skip
    if [[ "$filename" == "$filename_fixed" ]]; then
        continue
    fi

    # Build new full path
    newpath="${dir}/${filename_fixed}"

    echo "Renaming:"
    echo "  $filepath"
    echo "  -> $newpath"
    mv "$filepath" "$newpath"
done
