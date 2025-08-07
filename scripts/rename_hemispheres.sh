#!/usr/bin/env bash
set -euo pipefail

# Updated root folder path
BASE="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share"

cd "$BASE" || { echo "Cannot cd to $BASE"; exit 1; }

for dir in Inputs/* Outputs/*; do
  [ -d "$dir" ] || continue

  # Find files with "surf" anywhere in filename
  find "$dir" -type f -name "*surf*" -print0 | while IFS= read -r -d '' path; do
    filename=$(basename "$path")
    dirpath=$(dirname "$path")
    original_name="$filename"

    # Fix redundant _L_hemi-L, _R_hemi-R, _LR_hemi-LR suffixes
    if [[ "$filename" =~ _L_hemi-L_sphere ]]; then
      fixed_name="${filename/_L_hemi-L_sphere/_hemi-L_sphere}"
      echo "Fixing redundant L suffix: $filename → $fixed_name"
      mv -v "$path" "$dirpath/$fixed_name"
      continue
    elif [[ "$filename" =~ _R_hemi-R_sphere ]]; then
      fixed_name="${filename/_R_hemi-R_sphere/_hemi-R_sphere}"
      echo "Fixing redundant R suffix: $filename → $fixed_name"
      mv -v "$path" "$dirpath/$fixed_name"
      continue
    elif [[ "$filename" =~ _LR_hemi-LR_sphere ]]; then
      fixed_name="${filename/_LR_hemi-LR_sphere/_hemi-LR_sphere}"
      echo "Fixing redundant LR suffix: $filename → $fixed_name"
      mv -v "$path" "$dirpath/$fixed_name"
      continue
    fi

    # Normalize left/right to L/R
    norm_name="${filename//left/L}"
    norm_name="${norm_name//right/R}"

    # Determine hemisphere from normalized name
    hemi=""
    if [[ "$norm_name" == *LR* ]]; then
      hemi="LR"
    elif [[ "$norm_name" == *lh* && "$norm_name" == *rh* ]]; then
      hemi="LR"
    elif [[ "$norm_name" == *lh* || "$norm_name" == *L* ]]; then
      hemi="L"
    elif [[ "$norm_name" == *rh* || "$norm_name" == *R* ]]; then
      hemi="R"
    fi

    # Skip if no hemisphere detected
    [[ -z "$hemi" ]] && continue

    # Remove all instances of lh, rh, LR anywhere
    clean_name=$(echo "$norm_name" | sed -E 's/lh//g; s/rh//g; s/LR//g')

    # Remove stray L or R prefixes or dots anywhere except inside _hemi- pattern
    # Remove leading L. or R. if present
    clean_name=$(echo "$clean_name" | sed -E 's/^[LR]\.//')

    # Remove stray _L, -L, _R, -R, _LR, -LR before extension (only outside hemi suffix)
    clean_name=$(echo "$clean_name" | sed -E "s/[_-](${hemi})(\.[^.]+$)/\1\2/")

    # Remove any stray _L or _R or _LR *not* part of hemi suffix anywhere in the filename except suffix:
    # This step avoids duplicates of L or R lingering elsewhere:
    clean_name=$(echo "$clean_name" | sed -E "s/[_-](${hemi})([^hemi]|$)/\2/g")

    # Insert hemi suffix before extension
    final_name="${clean_name%.*}_hemi-${hemi}_sphere.${clean_name##*.}"

    # Skip if no change
    [[ "$filename" == "$final_name" ]] && continue

    echo "Renaming: $filename → $final_name"
    mv -v "$dirpath/$filename" "$dirpath/$final_name"
  done
done
