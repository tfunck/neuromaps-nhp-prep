import os
import re
from pathlib import Path

ROOT_FOLDER = "/Users/tamsin.rogers/Desktop/github/neuromaps-nhp-prep/share/Inputs"

for filepath in Path(ROOT_FOLDER).rglob("*surf*"):
    if not filepath.is_file():
        continue

    dirpath = filepath.parent
    filename = filepath.name
    subdir = dirpath.name

    # Remove other instances of the subdir in the filename (case-insensitive)
    filename_cleaned = re.sub(subdir, "", filename, flags=re.IGNORECASE)

    # Ensure filename starts with tpl-
    if not filename_cleaned.startswith("tpl-"):
        filename_cleaned = f"tpl-{filename_cleaned}"

    # Insert subdir after tpl-
    filename_fixed = re.sub(r"^tpl-", f"tpl-{subdir}_", filename_cleaned)

    # If filename didn't change, warn and skip
    if filename == filename_fixed:
        print(f"⚠️  Warning: No change for file — {filepath}")
        continue

    # Build new full path
    newpath = dirpath / filename_fixed

    print("Renaming:")
    print(f"  {filepath}")
    print(f"  -> {newpath}")

    os.rename(filepath, newpath)
