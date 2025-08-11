#!/bin/bash

ROOT_FOLDER="/neuromaps-nhp-prep/share/Inputs/Yerkes19"

find "$ROOT_FOLDER" -type f -name "*surf*.gii" | while read -r filepath; do
    filename=$(basename "$filepath")
    dir=$(dirname "$filepath")

    hemi=""
    # Look for .L. or .R. in filename (single hemisphere tag)
    if [[ "$filename" =~ \.L\. ]]; then
        hemi="L"
    elif [[ "$filename" =~ \.R\. ]]; then
        hemi="R"
    else
        echo "No single hemisphere tag found in $filename, skipping."
        continue
    fi

    # Remove the .L. or .R. from the filename (only single dot, not double or LR)
    newname=$(echo "$filename" | sed -E 's/\.([LR])\././')

    # Insert hemi tag before .surf.gii, without _sphere
    base="${newname%.surf.gii}"
    new_filename="${base}_hemi-${hemi}.surf.gii"

    echo "Renaming:"
    echo "  $filepath"
    echo "-> $dir/$new_filename"

    mv "$filepath" "$dir/$new_filename"
done
