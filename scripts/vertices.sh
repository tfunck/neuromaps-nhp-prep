#!/bin/bash

# Root folder to search
ROOT_FOLDER="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share/Inputs"

# Output CSV file
OUTPUT_CSV="vertices.csv"

# Write CSV header
echo "Subdirectory,Filename,VertexCount" > "$OUTPUT_CSV"

# Find all .gii files with "surf" in the name in subdirectories
find "$ROOT_FOLDER" -type f -name "*surf*.gii" | while IFS= read -r filepath; do
    # Get subdirectory relative to ROOT_FOLDER
    subdir=$(dirname "$filepath" | sed "s|$ROOT_FOLDER/||")
    
    # Get filename
    filename=$(basename "$filepath")
    
    # Run the Python script to get vertex count
    vertex_count=$(python3 vertices.py "$filepath")
    
    # Append to CSV without quotes
    echo "$subdir,$filename,$vertex_count" >> "$OUTPUT_CSV"
done
