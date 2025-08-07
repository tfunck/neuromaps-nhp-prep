#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs"
CSV_FILE="input_vertices.csv"

vertex_to_density() {
    local vertices=$1
    if (( vertices >= 1000 )); then
        echo "$((vertices / 1000))k"
    else
        echo "${vertices}"
    fi
}

tail -n +2 "$CSV_FILE" | while IFS=, read -r subdir filename vertexcount; do
    density=$(vertex_to_density "$vertexcount")
    folder_path="${ROOT_FOLDER}/${subdir}"

    find "$folder_path" -type f -name '*surf*' | while read -r file; do
        basefile=$(basename "$file")
        dir=$(dirname "$file")

        # Remove all _den-xxx tags anywhere
        cleaned="$basefile"
        while [[ "$cleaned" =~ _den-[^_\.]+ ]]; do
            cleaned="${cleaned/_den-[^_\.]*/}"
        done

        # Insert _den-{density}_ before the hemi tag if present
        if [[ "$cleaned" =~ (_hemi-[^_]+) ]]; then
            hemi_part="${BASH_REMATCH[1]}"
            # Remove the hemi part from cleaned to insert density before it
            prefix="${cleaned%$hemi_part}"
            suffix="${cleaned##*$hemi_part}"
            newname="${prefix}_den-${density}${hemi_part}${suffix}"
        else
            # No hemi tag, just append at the end before extension
            if [[ "$cleaned" == *.* ]]; then
                newname="${cleaned%.*}_den-${density}.${cleaned##*.}"
            else
                newname="${cleaned}_den-${density}"
            fi
        fi

        newfile="$dir/$newname"

        if [[ "$file" != "$newfile" ]]; then
            echo "Renaming:"
            echo "  $file"
            echo "  $newfile"
            mv "$file" "$newfile"
        else
            echo "No rename needed for $file"
        fi
    done
done
