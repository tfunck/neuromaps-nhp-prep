#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs"
CSV_FILE="input_vertices.csv"

# Function to convert vertex count to density string, e.g. 41000 -> 41k
vertex_to_density() {
    local vertices=$1
    if (( vertices >= 1000 )); then
        echo "$((vertices / 1000))k"
    else
        echo "${vertices}"
    fi
}

# Read the CSV file, skip header
tail -n +2 "$CSV_FILE" | while IFS=, read -r subdir filename vertexcount; do
    # Get the density tag string
    density=$(vertex_to_density "$vertexcount")

    # Construct full folder path
    folder_path="${ROOT_FOLDER}/${subdir}"

    # We want to find the file inside folder_path matching filename or similar but:
    # Filename in CSV may not exactly match the file name on disk, so instead we will
    # try to find any file in folder_path containing "surf" and base name matching filename (without extension)
    # Actually simpler: find files containing "surf" in folder_path, then check if the filename base matches csv filename base
    # But CSV might have different naming, so let's just find all files with surf in the full folder_path/subdir and update all.

    # Let's find all files with "surf" in their name inside this subdir
    find "$folder_path" -type f -name '*surf*' | while read -r file; do
        basefile=$(basename "$file")

        # Remove any existing density tags den-* in filename
        # Use regex to remove den-[^_]* or den-[^\.]* pattern

        # For safety, remove all "den-XXX" tags anywhere in the filename before the extension
        newbase=$(echo "$basefile" | sed -E 's/_?den-[^_\.]+//g')

        # Insert new density tag before the first _left/_right/_L/_R or before ".surf"
        # We'll try to put _den-{density} before .surf

        # If filename contains .surf, insert before .surf
        if [[ "$newbase" =~ \.surf ]]; then
            newname=$(echo "$newbase" | sed -E "s/\.surf/_den-${density}.surf/")
        else
            # just append _den-{density} before extension
            newname=$(echo "$newbase" | sed -E "s/(\.[^.]+)$/_den-${density}\1/")
        fi

        # Construct full new path
        newfile="$(dirname "$file")/$newname"

        # Rename the file if newname is different
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
