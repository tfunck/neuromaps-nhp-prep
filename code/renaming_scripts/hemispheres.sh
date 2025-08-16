#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/neuromaps-nhp-prep/share/Inputs"
OUTPUT_CSV="input_hemispheres.csv"

# Write CSV header
echo "Subdirectory,Filename,Hemisphere" > "$OUTPUT_CSV"

# Find all files containing "surf" in filename under ROOT_FOLDER
find "$ROOT_FOLDER" -type f -name "*surf*" | while read -r filepath; do
    echo "Processing file: $filepath"
    filename=$(basename "$filepath")
    subdir=$(dirname "$filepath" | sed "s|$ROOT_FOLDER/||")
    hemisphere=$(python3 hemispheres.py "$filepath")
    echo "$subdir,$filename,$hemisphere" >> "$OUTPUT_CSV"
done
