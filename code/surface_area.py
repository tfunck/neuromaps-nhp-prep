
import os
import re
from pathlib import Path
from niwrap import workbench as wb
import subprocess
import glob
import argparse


def compute_surface_area(input_gifti, output_metric):
    """
    Compute the surface area of a brain surface mesh using niwrap.

    """
    wb.surface_vertex_areas(surface=input_gifti, metric=output_metric)
    print(f"Surface area metric saved to {output_metric}")


def validate_output_file_data(output_metric):
    """
    Validate the output metric file by checking specific data fields.
    """
    try:
        # Basic file existence check
        if not os.path.exists(output_metric):
            print("✗ Output file does not exist")
            return False
            
        file_size = os.path.getsize(output_metric)
        if file_size == 0:
            print("✗ Output file is empty")
            return False
            
        print(f"✓ File exists with size: {file_size} bytes")
        
        # Get file information using subprocess to capture output
        result = subprocess.run(
            ['wb_command', '-file-information', output_metric],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            print("✗ Failed to get file information")
            return False
            
        output = result.stdout
        print("File information output captured")
        
        # Check for required fields
        required_fields = {
            'Type': 'Metric',
            'Maps to Surface': 'true',
            'Number of Maps': '1',
            'Map Name': 'vertex areas'
        }
        
        validation_results = {}
        
        for field, expected_value in required_fields.items():
            if field == 'Map Name':
                # Special case for map name - check in the table
                pattern = r'vertex areas'
                if re.search(pattern, output, re.IGNORECASE):
                    validation_results[field] = True
                    print(f"✓ {field}: Found 'vertex areas'")
                else:
                    validation_results[field] = False
                    print(f"✗ {field}: 'vertex areas' not found")
            else:
                # Check for field: value pattern
                pattern = f"{field}:\\s*{re.escape(expected_value)}"
                if re.search(pattern, output, re.IGNORECASE):
                    validation_results[field] = True
                    print(f"✓ {field}: {expected_value}")
                else:
                    validation_results[field] = False
                    print(f"✗ {field}: Expected '{expected_value}' not found")
        
        # Check for numeric data fields
        numeric_checks = {
            'Number of Vertices': r'Number of Vertices:\s*(\d+)',
            'Minimum': r'1\s+([\d.]+)',  # Map 1 minimum value
            'Maximum': r'1\s+[\d.]+\s+([\d.]+)',  # Map 1 maximum value
            'Mean': r'1\s+[\d.]+\s+[\d.]+\s+([\d.]+)',  # Map 1 mean value
        }
        
        for check_name, pattern in numeric_checks.items():
            match = re.search(pattern, output)
            if match:
                value = match.group(1)
                try:
                    float_value = float(value)
                    if float_value > 0:
                        validation_results[check_name] = True
                        print(f"✓ {check_name}: {value} (valid positive value)")
                    else:
                        validation_results[check_name] = False
                        print(f"✗ {check_name}: {value} (should be positive)")
                except ValueError:
                    validation_results[check_name] = False
                    print(f"✗ {check_name}: {value} (not a valid number)")
            else:
                validation_results[check_name] = False
                print(f"✗ {check_name}: Not found in output")
        
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

def test_output_file(output_metric, validate=True):
    """
    Test if the output metric file exists and has valid data fields.
    """
    # First run the niwrap file_information to ensure it works
    try:
        file_info = wb.file_information(output_metric)
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
def find_surface_files(input_dir, patterns=None):
    """
    Find surface files matching the specified patterns.
    """
    if patterns is None:
        patterns = ["*mid*.surf.gii", "*midthickness*.surf.gii"]
    
    # Convert to absolute path
    input_dir = os.path.abspath(input_dir)
    
    input_files = []
    for pattern in patterns:
        full_pattern = os.path.join(input_dir, "**", pattern)
        input_files.extend(glob.glob(full_pattern, recursive=True))
    
    # Remove duplicates
    return list(set(input_files))

def process_files(input_files, validate_output=False, dry_run=False):
    """
    Process all input files to compute surface areas.
    """
    successful = 0
    failed = 0
    
    for input_gifti in input_files:
        # Generate output filename
        output_metric = input_gifti.replace('.surf.gii', '.func.gii')
        
        print(f"\nProcessing: {os.path.basename(input_gifti)}")
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
        """
    )
    
    parser.add_argument(
        '-i', '--input-dir',
        type=str,
        default='../share/Inputs',
        help='Directory to search for input files (default: ../share/Inputs)'
    )
    
    parser.add_argument(
        '-p', '--patterns',
        nargs='+',
        default=['*mid*.surf.gii', '*midthickness*.surf.gii'],
        help='File patterns to match (default: *mid*.surf.gii *midthickness*.surf.gii)'
    )
    
    parser.add_argument(
        '--validate',
        action='store_true',
        help='Validate output files after processing'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what files would be processed without actually processing them'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output'
    )
    
    args = parser.parse_args()
    
    # Convert input directory to absolute path for consistency
    input_dir = os.path.abspath(args.input_dir)
    
    if args.verbose:
        print(f"Input directory: {input_dir}")
        print(f"Search patterns: {args.patterns}")
        print(f"Validate outputs: {args.validate}")
        print(f"Dry run: {args.dry_run}")
        print()
    
    # Check if input directory exists
    if not os.path.exists(input_dir):
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
            rel_path = os.path.relpath(input_file)
            print(f"  - {rel_path}")
        except ValueError:
            # Can't compute relative path (different drives on Windows)
            print(f"  - {input_file}")
    
    # Process files
    successful, failed = process_files(input_files, args.validate, args.dry_run)
    
    # Summary
    print(f"\n{'='*50}")
    print(f"Processing complete!")
    if not args.dry_run:
        print(f"Successful: {successful}")
        print(f"Failed: {failed}")
        print(f"Total: {len(input_files)}")
    
    return 0 if failed == 0 else 1

if __name__ == "__main__":
    exit(main())