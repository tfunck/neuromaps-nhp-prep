#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs/MEBRAINS"

find "$ROOT_FOLDER" -type f -name "*surf*.gii" | while read -r filepath; do
    filename=$(basename "$filepath")
    dir=$(dirname "$filepath")

    hemi=""
    if [[ "$filename" =~ _lh\. ]]; then
        hemi="L"
    elif [[ "$filename" =~ _rh\. ]]; then
        hemi="R"
    else
        echo "No hemisphere tag found in $filename, skipping."
        continue
    fi

    # Remove the hemisphere tag (_lh or _rh)
    newname=$(echo "$filename" | sed -E 's/_(lh|rh)//')

    # Insert hemi tag before .surf.gii
    base="${newname%.surf.gii}"
    new_filename="${base}_hemi-${hemi}_sphere.surf.gii"

    echo "Renaming:"
    echo "  $filepath"
    echo "-> $dir/$new_filename"

    mv "$filepath" "$dir/$new_filename"
done
