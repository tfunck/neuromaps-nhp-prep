#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs/CIVETNMT"

find "$ROOT_FOLDER" -type f -name "*surf*.gii" | while read -r filepath; do
    filename=$(basename "$filepath")
    dir=$(dirname "$filepath")

    # Determine hemisphere letter
    hemi=""
    if [[ "$filename" =~ left|lh|_L[^a-zA-Z0-9]|_L\.|_L$ ]]; then
        hemi="L"
    elif [[ "$filename" =~ right|rh|_R[^a-zA-Z0-9]|_R\.|_R$ ]]; then
        hemi="R"
    else
        echo "No hemisphere tag found in $filename, skipping."
        continue
    fi

    # Remove all hemisphere tags from filename
    newname="$filename"
    newname=$(echo "$newname" | sed -E 's/(_|-)?(left|right|lh|rh)(_|-|\.|$)/\3/Ig')
    newname=$(echo "$newname" | sed -E 's/(_|-)?([LR])(_|-|\.|$)/\3/g')
    newname=$(echo "$newname" | sed -E 's/[_-]+(\.surf\.gii)/\1/')

    base="${newname%.surf.gii}"
    new_filename="${base}_hemi-${hemi}_sphere.surf.gii"

    echo "Renaming:"
    echo "  $filepath"
    echo "-> $dir/$new_filename"

    mv "$filepath" "$dir/$new_filename"
done
