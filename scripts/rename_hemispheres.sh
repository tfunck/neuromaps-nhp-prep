#!/usr/bin/env bash
set -euo pipefail

# Path to repo root
BASE="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share"

cd "$BASE" || { echo "Cannot cd to $BASE"; exit 1; }

for dir in Inputs/* Outputs/*; do
  [ -d "$dir" ] || continue

  find "$dir" -type f -name "*.surf.gii" -print0 | while IFS= read -r -d '' path; do
    filename=$(basename "$path")
    dirpath=$(dirname "$path")

    # -------------------------------------------------------------
    # Special fix for files like *_L_hemi-L_sphere.surf.gii or *_R_hemi-R_sphere.surf.gii
    if [[ "$filename" =~ _L_hemi-L_sphere\.surf\.gii$ ]]; then
      fixed_name="${filename/_L_hemi-L_sphere.surf.gii/_hemi-L_sphere.surf.gii}"
      echo "Fixing redundant L in: $filename → $fixed_name"
      mv -v "$path" "$dirpath/$fixed_name"
      continue
    elif [[ "$filename" =~ _R_hemi-R_sphere\.surf\.gii$ ]]; then
      fixed_name="${filename/_R_hemi-R_sphere.surf.gii/_hemi-R_sphere.surf.gii}"
      echo "Fixing redundant R in: $filename → $fixed_name"
      mv -v "$path" "$dirpath/$fixed_name"
      continue
    fi
    # -------------------------------------------------------------

    # Step 1: Normalize 'left' → 'L' and 'right' → 'R'
    norm_name="${filename//left/L}"
    norm_name="${norm_name//right/R}"

    # Skip if already normalized
    if [[ "$norm_name" == *"_hemi-L_sphere.surf.gii" || "$norm_name" == *"_hemi-R_sphere.surf.gii" ]]; then
      continue
    fi

    # Determine hemisphere
    hemi=""
    if [[ "$norm_name" == *"L"* ]]; then
      hemi="L"
    elif [[ "$norm_name" == *"R"* ]]; then
      hemi="R"
    else
      continue  # skip files with no hemisphere
    fi

    # Remove trailing _L or -L or _R or -R before extension
    clean_name=$(echo "$norm_name" | sed -E "s/[_-]${hemi}(\.surf\.gii)/\1/")

    # Insert _hemi-X_sphere before extension
    final_name="${clean_name/.surf.gii/_hemi-${hemi}_sphere.surf.gii}"

    # Rename if changed
    if [[ "$filename" != "$final_name" ]]; then
      echo "Renaming: $filename → $final_name"
      mv -v "$path" "$dirpath/$final_name"
    fi
  done
done
