#!/bin/bash

ROOT_FOLDER="/neuromaps-nhp-prep/share/Inputs"
CSV_FILE="input_vertices.csv"

# Skip header and read each line
tail -n +2 "$CSV_FILE" | while IFS=',' read -r SUBDIR FILENAME VERTEX_COUNT; do
    # Construct full path to the file
    DIR_PATH="$ROOT_FOLDER/$SUBDIR"
    FILE_PATH="$DIR_PATH/$FILENAME"

    # Check if the file exists
    if [[ -f "$FILE_PATH" ]]; then
        # Build new filename with density prefix
        NEW_FILENAME="den-${VERTEX_COUNT}_$FILENAME"
        NEW_PATH="$DIR_PATH/$NEW_FILENAME"

        # Rename the file
        mv "$FILE_PATH" "$NEW_PATH"
        echo "Renamed: $FILE_PATH -> $NEW_PATH"
    else
        echo "File not found: $FILE_PATH"
    fi
done
