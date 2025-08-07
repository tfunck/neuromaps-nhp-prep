#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Outputs"
CSV_FILE="output_vertices.csv"

# Skip header line in CSV and read each line
tail -n +2 "$CSV_FILE" | while IFS=, read -r subdir filename vertex_count; do
    # Construct full path to the original file
    original_path="$ROOT_FOLDER/$subdir/$filename"

    # Check file exists
    if [[ ! -f "$original_path" ]]; then
        echo "File not found: $original_path"
        continue
    fi

    # Extract parts of filename based on underscores
    # Example: macaque_mid_mc_L.surf.gii
    # Goal: macaque_mid_mc_den-41k_L.surf.gii

    # Separate extension(s)
    base_name="${filename%.*}"         # Remove extension -> macaque_mid_mc_L.surf
    extension="${filename##*.}"        # Get last extension -> gii

    # Handle cases with multiple extensions like .surf.gii
    if [[ "$base_name" == *.* ]]; then
        second_ext="${base_name##*.}"          # e.g. surf
        base_name="${base_name%.*}"            # e.g. macaque_mid_mc_L
        extension="$second_ext.$extension"     # e.g. surf.gii
    fi

    # Split base_name by underscores into an array
    IFS='_' read -r -a parts <<< "$base_name"

    # Insert den-<vertex_count> before the last part
    last_index=$((${#parts[@]} - 1))
    new_filename=""

    for i in "${!parts[@]}"; do
        if [[ $i -eq $last_index ]]; then
            new_filename+="den-$vertex_count"_"${parts[$i]}"
        else
            new_filename+="${parts[$i]}_"
        fi
    done

    # Append the extension
    new_filename+=".$extension"

    # Full new path
    new_path="$ROOT_FOLDER/$subdir/$new_filename"

    # Rename the file
    echo "Renaming:"
    echo "  $original_path"
    echo "  -> $new_path"
    mv "$original_path" "$new_path"

done
