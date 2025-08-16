import csv
import os
from pathlib import Path

ROOT_FOLDER = Path("/Users/tamsin.rogers/Desktop/github/neuromaps-nhp-prep/share/Inputs")
CSV_FILE = Path("input_vertices.csv")

with open(CSV_FILE, newline="") as csvfile:
    reader = csv.reader(csvfile)
    next(reader)  # skip header

    for row in reader:
        if len(row) < 3:
            continue

        subdir, filename, vertex_count = [col.strip() for col in row]

        dir_path = ROOT_FOLDER / subdir
        file_path = dir_path / filename

        if file_path.is_file():
            new_filename = f"den-{vertex_count}_{filename}"
            new_path = dir_path / new_filename

            os.rename(file_path, new_path)
            print(f"Renamed: {file_path} -> {new_path}")
        else:
            print(f"File not found: {file_path}")
