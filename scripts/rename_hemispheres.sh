#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs/Yerkes19"

find "$ROOT_FOLDER" -type f -name "*surf*.gii" | while read -r filepath; do
    filename=$(basename "$filepath")
    dir=$(dirname "$filepath")

    hemi=""
    # Look for single .L. or .R. preceded by underscore (to avoid LR)
    if [[ "$filename" =~ _\.L\. ]]; then
        hemi="L"
    elif [[ "$filename" =~ _\.R\. ]]; then
        hemi="R"
    else
        echo "No single hemisphere tag found in $filename, skipping."
        continue
    fi

    # Remove the _.L. or _.R. from the filename
    newname=$(echo "$filename" | sed -E 's/_\.(L|R)\././')

    # Insert hemi tag before .surf.gii
    base="${newname%.surf.gii}"
    new_filename="${base}_hemi-${hemi}_sphere.surf.gii"

    echo "Renaming:"
    echo "  $filepath"
    echo "-> $dir/$new_filename"

    mv "$filepath" "$dir/$new_filename"
done
