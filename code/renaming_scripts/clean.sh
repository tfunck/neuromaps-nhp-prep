#!/bin/bash

BASE_DIR="/neuromaps-nhp-prep/share/Inputs"

find "$BASE_DIR" -type f -name "*surf*" | while read -r filepath; do
  dir=$(dirname "$filepath")
  base=$(basename "$filepath")

  # Protect den-XXXk patterns by replacing with placeholder
  protected=$(echo "$base" | sed -E 's/(den-[0-9]+k)/__DEN_PLACEHOLDER__\1__DEN_PLACEHOLDER__/g')

  # Remove all other {number}k preceded by '.' or '_'
  cleaned=$(echo "$protected" | sed -E 's/([._])[0-9]+k/\1/g')

  # Restore the protected den-XXXk patterns
  restored=$(echo "$cleaned" | sed -E 's/__DEN_PLACEHOLDER__(den-[0-9]+k)__DEN_PLACEHOLDER__/\1/g')

  # Clean up any doubled dots or underscores that may result
  final=$(echo "$restored" | sed -E 's/[_\.]{2,}/./g; s/^\.//')

  # Rename only if changed
  if [[ "$base" != "$final" ]]; then
    mv -v "$filepath" "$dir/$final"
  fi
done
