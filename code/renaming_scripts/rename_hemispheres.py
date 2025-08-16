import csv
import os
from pathlib import Path

ROOT_FOLDER = Path("/Users/tamsin.rogers/Desktop/github/neuromaps-nhp-prep/share/Inputs")
CSV_FILE = Path("input_hemispheres.csv")

with open(CSV_FILE, newline="") as csvfile:
    reader = csv.reader(csvfile)
    next(reader)  # skip header

    for row in reader:
        if len(row) < 3:
            continue

        subdir, filename, hemisphere = [col.strip() for col in row]

        # Detect hemisphere from filename
        if "hemi-L" in filename:
            file_hemi = "hemi-L"
        elif "hemi-R" in filename:
            file_hemi = "hemi-R"
        else:
            print(f"Skipping {filename} (no hemisphere in filename)")
            continue

        # If mismatch, rename the file
        if file_hemi != hemisphere:
            old_path = ROOT_FOLDER / subdir / filename
            new_filename = filename.replace(file_hemi, hemisphere)
            new_path = ROOT_FOLDER / subdir / new_filename

            if old_path.is_file():
                print(f"Renaming: {old_path} -> {new_path}")
                os.rename(old_path, new_path)
            else:
                print(f"WARNING: File not found: {old_path}")
