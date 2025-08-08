#!/bin/bash

ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs"
OUTPUT_CSV="input_vertices.csv"

# Write CSV header
echo "Subdirectory,Filename,VertexCount" > "$OUTPUT_CSV"

# Find all files containing "surface" in filename under ROOT_FOLDER
find "$ROOT_FOLDER" -type f -name "*surf*" | while read -r filepath; do
    echo "Processing file: $filepath"
    filename=$(basename "$filepath")
    subdir=$(dirname "$filepath" | sed "s|$ROOT_FOLDER/||")
    vertex_count=$(python3 vertices.py "$filepath")
    echo "$subdir,$filename,$vertex_count" >> "$OUTPUT_CSV"
done
