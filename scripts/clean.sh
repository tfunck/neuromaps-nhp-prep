#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs"

# Find files with _den- in their names
find "$ROOT_FOLDER" -type f -name '*_den-*' | while read -r file; do
    basefile=$(basename "$file")
    dir=$(dirname "$file")

    # Remove _den-xxx only if it's followed by _hemi- or elsewhere in the name
    # This regex removes _den-xxx anywhere
    reverted=$(echo "$basefile" | sed -E 's/_den-[^_\.]+//g')

    # Construct new full path
    newfile="$dir/$reverted"

    if [[ "$file" != "$newfile" ]]; then
        echo "Reverting:"
        echo "  $file"
        echo "  $newfile"
        mv "$file" "$newfile"
    else
        echo "No revert needed for $file"
    fi
done
