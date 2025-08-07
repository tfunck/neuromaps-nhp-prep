#!/bin/bash

BASE="/Users/tamsin.rogers/Desktop/github/thomas/neuromaps-nhp-prep/share"

detect_hemisphere() {
  local filename="$1"
  local lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')

  local left=0
  local right=0

  if [[ "$lower" =~ (^|[^a-z])left([^a-z]|$) || "$lower" =~ (^|[^a-z])lh([^a-z]|$) || "$lower" =~ (^|[^a-z])l([^a-z]|$) ]]; then
    left=1
  fi
  if [[ "$lower" =~ (^|[^a-z])right([^a-z]|$) || "$lower" =~ (^|[^a-z])rh([^a-z]|$) || "$lower" =~ (^|[^a-z])r([^a-z]|$) ]]; then
    right=1
  fi

  if [[ $left -eq 1 && $right -eq 1 ]]; then
    echo "hemi-LR_sphere"
  elif [[ $left -eq 1 ]]; then
    echo "hemi-L_sphere"
  elif [[ $right -eq 1 ]]; then
    echo "hemi-R_sphere"
  else
    echo ""
  fi
}

check_for_stray_hemisphere_tags() {
  local fullpath="$1"
  local lower=$(echo "$fullpath" | tr '[:upper:]' '[:lower:]')

  # Remove valid hemisphere token(s)
  local lower_cleaned=$(echo "$lower" | sed -E 's/_hemi-(l|r|lr)_sphere//g')

  # Look for stray tokens: separated by any non-letter character or string boundaries
  if echo "$lower_cleaned" | grep -E -q '([^a-z]|^)left([^a-z]|$)|([^a-z]|^)right([^a-z]|$)|([^a-z]|^)lh([^a-z]|$)|([^a-z]|^)rh([^a-z]|$)|([^a-z])l([^a-z])|([^a-z])r([^a-z])'; then
    echo "⚠️  Stray hemisphere tag in: $fullpath"
  fi
}

find "$BASE" -type f -name '*surf*' | while read -r filepath; do
  filename=$(basename "$filepath")
  dirpath=$(dirname "$filepath")

  hemi_label=$(detect_hemisphere "$filename")

  if [[ -z "$hemi_label" ]]; then
    echo "No hemisphere tag found in: $filename — skipping."
    check_for_stray_hemisphere_tags "$filepath"
    continue
  fi

  if [[ "$filename" == *"$hemi_label"* ]]; then
    echo "File $filename already contains hemisphere label — skipping."
    check_for_stray_hemisphere_tags "$filepath"
    continue
  fi

  if [[ "$filename" =~ (den-[^_\.]+) ]]; then
    density_label="${BASH_REMATCH[1]}"
    new_filename="${filename/$density_label/${density_label}_${hemi_label}}"
  else
    echo "No density label found in: $filename — skipping."
    check_for_stray_hemisphere_tags "$filepath"
    continue
  fi

  old_path="$filepath"
  new_path="$dirpath/$new_filename"

  if [[ "$old_path" != "$new_path" ]]; then
    echo "Renaming:"
    echo "  $old_path"
    echo "-> $new_path"
    mv "$old_path" "$new_path"
    check_for_stray_hemisphere_tags "$new_path"
  else
    check_for_stray_hemisphere_tags "$filepath"
  fi
done
