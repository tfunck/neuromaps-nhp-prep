#!/bin/bash

BASE="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs/NMT2"

find "$BASE" -type f -name "*.surf.surf.gii" | while read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")

    # Remove the duplicated '.surf.surf' to a single '.surf'
    newname="${filename/.surf.surf/.surf}"

    # If there are duplicated extensions like '.gii.gii', replace with one '.gii'
    newname="${newname//.gii.gii/.gii}"

    if [[ "$filename" != "$newname" ]]; then
        echo "Cleaning:"
        echo "  $filepath"
        echo "  -> $dir/$newname"
        mv "$filepath" "$dir/$newname"
    fi
done
