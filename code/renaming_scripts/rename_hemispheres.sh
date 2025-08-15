#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/neuromaps-nhp-prep/share/Inputs"
CSV_FILE="input_hemispheres.csv"

tail -n +2 "$CSV_FILE" | while IFS=, read -r subdir filename hemisphere; do
    # Trim spaces
    filename=$(echo "$filename" | xargs)
    hemisphere=$(echo "$hemisphere" | xargs)

    # Detect hemisphere from filename
    if [[ "$filename" =~ hemi-L ]]; then
        file_hemi="hemi-L"
    elif [[ "$filename" =~ hemi-R ]]; then
        file_hemi="hemi-R"
    else
        echo "Skipping $filename (no hemisphere in filename)"
        continue
    fi

    # If mismatch, rename the file
    if [[ "$file_hemi" != "$hemisphere" ]]; then
        old_path="$ROOT_FOLDER/$subdir/$filename"
        new_filename=$(echo "$filename" | sed -E "s/$file_hemi/$hemisphere/")
        new_path="$ROOT_FOLDER/$subdir/$new_filename"

        if [[ -f "$old_path" ]]; then
            echo "Renaming: $old_path -> $new_path"
            mv "$old_path" "$new_path"
        else
            echo "WARNING: File not found: $old_path"
        fi
    fi
done
