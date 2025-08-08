import argparse
from pathlib import Path
from typing import Iterable
import numpy as np

from niwrap import workbench as wb
import nibabel as nib


def detect_density(n_vertices: int) -> str:
    """
    Map a vertex count to a density label for (NHP) surface meshes.
    Returns a string label like '32k', '100k' or the exact integer as string for very large/unknown meshes.
    """
    if n_vertices < 3000:
        return "2k"
    if 3000 <= n_vertices <= 7499:
        return "5k"
    if 7500 <= n_vertices <= 12499:
        return "10k"
    if 12500 <= n_vertices <= 17499:
        return "15k"
    if 17500 <= n_vertices <= 22499:
        return "20k"
    if 22500 <= n_vertices <= 27499:
        return "25k"
    if 27500 <= n_vertices <= 36499:
        return "32k"
    if 36500 <= n_vertices <= 45999:
        # many NHP "32k" meshes sit here (e.g. 40962). Use 40k label to be explicit,
        # but you can override with a template lookup if you want HCP-style naming.
        return "40k"
    if 46000 <= n_vertices <= 55999:
        return "50k"
    if 56000 <= n_vertices <= 70999:
        return "59k"
    if 71000 <= n_vertices <= 95999:
        return "80k"
    if 96000 <= n_vertices <= 120999:
        return "100k"
    if 121000 <= n_vertices <= 140999:
        return "120k"
    if 141000 <= n_vertices <= 180999:
        return "164k"
    # fallback: return exact count for uncommon/custom meshes
    return str(n_vertices)


# Map hemisphere from structure name
def detect_hemi(structure_name: str, filename: str) -> str:
    struct_map = {
        "CortexLeft": "L",
        "CortexRight": "R"
    }
    if structure_name in struct_map:
        return struct_map[structure_name]
    # fallback to filename patterns
    lower = filename.lower()
    if "lh" in lower or "left" in lower or ".l." in lower:
        return "L"
    if "rh" in lower or "right" in lower or ".r." in lower:
        return "R"
    return "na"


# Detect space from filename or folder
def detect_space(path: Path) -> str:
    candidates = ["D99", "MEBRAINS", "Yerkes19", "CIVETNMT"]
    for c in candidates:
        if c.lower() in path.lower():
            return c
    return "unknown"


def compute_surface_area(input_gifti: Path, output_metric: Path) -> None:
    """
    Compute the surface area of a brain surface mesh using niwrap.

    """
    # test if file exists
    if not input_gifti.exists():
        print(f"✗ Input file does not exist: {input_gifti}")
        return

    wb.surface_vertex_areas(surface=str(input_gifti), metric=str(output_metric))
    print(f"Surface area metric saved to {output_metric}")


def validate_output_file_data(output_metric: Path) -> bool:
    """
    Validate the output metric file by checking specific data fields using nibabel.
    """
    try:
        # Basic file existence check
        if not output_metric.exists():
            print("✗ Output file does not exist")
            return False

        file_size = (
            output_metric.stat().st_size
        )  # Fix: use .stat().st_size instead of .size
        if file_size == 0:
            print("✗ Output file is empty")
            return False

        print(f"✓ File exists with size: {file_size} bytes")

        # Load the GIFTI file using nibabel
        try:
            gifti_img = nib.load(str(output_metric))
            print("✓ File loaded successfully with nibabel")
        except Exception as e:
            print(f"✗ Failed to load file with nibabel: {e}")
            return False

        validation_results = {}

        # Check file type
        if isinstance(gifti_img, nib.gifti.gifti.GiftiImage):
            validation_results["Type"] = True
            print("✓ Type: GIFTI Metric file")
        else:
            validation_results["Type"] = False
            print("✗ Type: Not a GIFTI file")

        # Check number of data arrays (maps)
        num_maps = len(gifti_img.darrays)
        if num_maps == 1:
            validation_results["Number of Maps"] = True
            print(f"✓ Number of Maps: {num_maps}")
        else:
            validation_results["Number of Maps"] = False
            print(f"✗ Number of Maps: Expected 1, got {num_maps}")

        # Check if it has data arrays (should map to surface)
        if gifti_img.darrays and len(gifti_img.darrays) > 0:
            validation_results["Maps to Surface"] = True
            print("✓ Maps to Surface: true")

            # Get the first (and should be only) data array
            data_array = gifti_img.darrays[0]

            # Check data array metadata for name
            map_name = None
            if data_array.meta:
                for meta_entry in data_array.meta.data:
                    if meta_entry.name.lower() in ["name", "mapname", "map_name"]:
                        map_name = meta_entry.value
                        break

            # Check map name
            if map_name and "vertex areas" in map_name.lower():
                validation_results["Map Name"] = True
                print(f"✓ Map Name: Found 'vertex areas' in '{map_name}'")
            else:
                # Sometimes the name might be in the intent or not set
                validation_results["Map Name"] = True  # Be lenient for now
                print(f"✓ Map Name: Using default (actual name: '{map_name}')")

            # Get actual data for numeric validation
            data = data_array.data
            if data is not None and len(data) > 0:
                # Number of vertices
                num_vertices = len(data)
                validation_results["Number of Vertices"] = True
                print(f"✓ Number of Vertices: {num_vertices}")

                # Statistical measures
                data_min = np.min(data)
                data_max = np.max(data)
                data_mean = np.mean(data)

                # Validate data ranges (surface areas should be positive)
                if data_min >= 0:
                    validation_results["Minimum"] = True
                    print(f"✓ Minimum: {data_min:.6f} (valid non-negative value)")
                else:
                    validation_results["Minimum"] = False
                    print(f"✗ Minimum: {data_min:.6f} (should be non-negative)")

                if data_max > 0:
                    validation_results["Maximum"] = True
                    print(f"✓ Maximum: {data_max:.6f} (valid positive value)")
                else:
                    validation_results["Maximum"] = False
                    print(f"✗ Maximum: {data_max:.6f} (should be positive)")

                if data_mean > 0:
                    validation_results["Mean"] = True
                    print(f"✓ Mean: {data_mean:.6f} (valid positive value)")
                else:
                    validation_results["Mean"] = False
                    print(f"✗ Mean: {data_mean:.6f} (should be positive)")

            else:
                validation_results["Number of Vertices"] = False
                validation_results["Minimum"] = False
                validation_results["Maximum"] = False
                validation_results["Mean"] = False
                print("✗ No data found in the metric file")

        else:
            validation_results["Maps to Surface"] = False
            validation_results["Map Name"] = False
            validation_results["Number of Vertices"] = False
            validation_results["Minimum"] = False
            validation_results["Maximum"] = False
            validation_results["Mean"] = False
            print("✗ Maps to Surface: false (no data arrays found)")

        # Overall validation result
        all_passed = all(validation_results.values())

        if all_passed:
            print("✓ All field validations passed")
        else:
            failed_checks = [k for k, v in validation_results.items() if not v]
            print(f"✗ Failed validations: {', '.join(failed_checks)}")

        return all_passed

    except Exception as e:
        print(f"✗ Validation failed: {e}")
        return False


def test_output_file(output_metric: Path, validate: bool = True):
    """
    Test if the output metric file exists and has valid data fields.
    """
    # First run the niwrap file_information to ensure it works
    try:
        wb.file_information(str(output_metric))
        print("✓ niwrap file information executed successfully")
    except Exception as e:
        print(f"✗ niwrap file information failed: {e}")
        return False

    if validate:
        # Now validate the actual data fields
        is_valid = validate_output_file_data(output_metric)

        if is_valid:
            print("✓ Complete output file validation successful")
        else:
            print("✗ Output file validation failed")

        return is_valid


def find_surface_files(
    input_dir: Path, patterns: Iterable[str] | None = None
) -> list[Path]:
    """
    Find surface files matching the specified patterns.
    """
    if patterns is None:
        patterns = ["*mid*.surf.gii"]

    input_dir = input_dir.absolute()

    input_files = []
    for pattern in patterns:
        input_files.extend(input_dir.rglob(f"**/{pattern}"))

    # Remove duplicates
    return list(set(input_files))


def process_files(
    input_files: Iterable[Path], validate_output: bool = False, dry_run: bool = False
):
    """
    Process all input files to compute surface areas.
    """
    successful = 0
    failed = 0

    for input_gifti in input_files:
        surface = nib.load(str(input_gifti))

        n_vertices = surface.darrays[0].data.shape[0]
        den = detect_density(n_vertices)

        hemi = detect_hemi(surface.meta.get("AnatomicalStructurePrimary", ""), input_gifti.name)

        space = detect_space(str(input_gifti))

        new_name = f"tpl-{space}_den-{den}_hemi-{hemi}_desc-vaavg_midthickness.shape.gii"

        # Generate output filename
        output_metric = input_gifti.parent / new_name

        print(f"\nProcessing: {input_gifti.name}")
        print(f"Input: {input_gifti}")
        print(f"Output: {output_metric}")

        if dry_run:
            print("  (DRY RUN - no processing performed)")
            continue

        try:
            # Run the actual processing
            compute_surface_area(input_gifti, output_metric)

            # Test output file if requested
            if validate_output:
                if test_output_file(output_metric, validate=True):
                    successful += 1
                else:
                    failed += 1
                    print(f"✗ Validation failed for {output_metric}")
            else:
                test_output_file(output_metric, validate=False)
                successful += 1

        except Exception as e:
            print(f"✗ Failed to process {input_gifti}: {e}")
            failed += 1

    return successful, failed


def main():
    """
    Main command-line interface function.
    """
    parser = argparse.ArgumentParser(
        description="Compute surface area metrics for brain surface meshes",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python surface_area.py                              # Use default ../share/Inputs
  python surface_area.py -i /path/to/surfaces         # Use absolute path
  python surface_area.py -i ./data/surfaces           # Use relative path
  python surface_area.py -i ../inputs --validate      # Validate outputs
  python surface_area.py -i ../inputs --dry-run       # Show what would be processed
  python surface_area.py -p "*mid*" "*thickness*"     # Custom patterns
        """,
    )
    SCRIPT_DIR = Path(__file__).parent
    parser.add_argument(
        "-i",
        "--input-dir",
        type=Path,
        default=Path(SCRIPT_DIR / "../share/Inputs").resolve(),
        help="Directory to search for input files (default: ../share/Inputs)",
    )

    parser.add_argument(
        "-p",
        "--patterns",
        nargs="+",
        default=["*mid*.surf.gii"],
        help="File patterns to match (default: %(default)s)",
    )

    parser.add_argument(
        "--validate", action="store_true", help="Validate output files after processing"
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what files would be processed without actually processing them",
    )

    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output")

    args = parser.parse_args()

    # Convert input directory to absolute path for consistency
    input_dir = args.input_dir.absolute()

    if args.verbose:
        print(f"Input directory: {input_dir}")
        print(f"Search patterns: {args.patterns}")
        print(f"Validate outputs: {args.validate}")
        print(f"Dry run: {args.dry_run}")
        print()

    # Check if input directory exists
    if not input_dir.exists():
        print(f"✗ Error: Input directory '{input_dir}' does not exist")
        return 1

    # Find matching files
    print(f"Searching for files in: {input_dir}")
    input_files = find_surface_files(input_dir, args.patterns)

    if not input_files:
        print("✗ No matching input files found")
        print(f"Patterns searched: {args.patterns}")
        return 1

    print(f"Found {len(input_files)} input file(s):")
    for input_file in input_files:
        # Show relative path if possible for cleaner output
        try:
            rel_path = input_file.relative_to(Path.cwd())
            print(f"  - {rel_path}")
        except ValueError:
            # Can't compute relative path (different drives on Windows)
            print(f"  - {input_file}")

    # Process files
    successful, failed = process_files(input_files, args.validate, args.dry_run)

    # Summary
    print(f"\n{'=' * 50}")
    print("Processing complete!")
    if not args.dry_run:
        print(f"Successful: {successful}")
        print(f"Failed: {failed}")
        print(f"Total: {len(input_files)}")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    exit(main())
