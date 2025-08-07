#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs/NMT2"

find "$ROOT_FOLDER" -type f -name "*.gii" | while read -r filepath; do
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

    # Remove _lh or _rh from filename
    newname=$(echo "$filename" | sed -E 's/_(lh|rh)//')

    # Insert hemi tag before .gii extension
    base="${newname%.gii}"
    new_filename="${base}_hemi-${hemi}_sphere.gii"

    echo "Renaming:"
    echo "  $filepath"
    echo "-> $dir/$new_filename"

    mv "$filepath" "$dir/$new_filename"
done
