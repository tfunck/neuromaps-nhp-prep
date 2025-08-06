#!/usr/bin/env bash
set -euo pipefail

# Change this path to the local root of the repo
BASE="neuromaps-nhp-prep/share"

cd "$BASE" || { echo "Cannot cd to $BASE"; exit 1; }

for dir in Inputs/* Outputs/*; do
  [ -d "$dir" ] || continue

  find "$dir" -depth -print0 | while IFS= read -r -d '' path; do
    # Only rename files (or directories) whose name contains left or right:
    name=$(basename "$path")
    dirpart=$(dirname "$path")
    newname="${name//left/L}"
    newname="${newname//right/R}"

    # Skip when unchanged
    if [[ "$newname" != "$name" ]]; then
      mv -v "$path" "$dirpart/$newname"
    fi
  done
done
