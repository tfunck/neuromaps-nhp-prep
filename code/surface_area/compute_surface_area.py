import argparse
from pathlib import Path
from typing import Iterable

from niwrap import workbench as wb
from styxdocker import DockerRunner

from validate_surface_files import validate_output_file_data
from utils import find_surface_files, get_map_info

my_runner = DockerRunner()
my_runner.data_dir = Path(__file__).parent / "../../share/Inputs"


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


def process_files(
    input_files: Iterable[Path], validate_output: bool = False, dry_run: bool = False
):
    """
    Process all input files to compute surface areas.
    """
    successful = 0
    failed = 0

    for input_gifti in input_files:
        map_info = get_map_info(input_gifti)

        new_name = f"tpl-{map_info['Space']}_den-{map_info['Density']}_hemi-{map_info['Hemi']}_desc-vaavg_midthickness.shape.gii"

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
                if validate_output_file_data(output_metric):
                    successful += 1
                else:
                    failed += 1
                    print(f"✗ Validation failed for {output_metric}")
            else:
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
        default=Path(SCRIPT_DIR / "../../share/Inputs").resolve(),
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
