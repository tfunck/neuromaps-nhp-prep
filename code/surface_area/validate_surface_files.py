
from pathlib import Path
from utils import detect_density
import nibabel as nib
import numpy as np

def validate_output_file_data(output_metric: Path) -> bool:
    """
    Validate the output metric file by checking specific data fields using nibabel.
    """
    try:
        if not output_metric.exists():
            print("✗ Output file does not exist")
            return False

        try:
            gifti_img = nib.load(str(output_metric))
            print("✓ File loaded successfully with nibabel")
        except Exception as e:
            print(f"✗ Failed to load file with nibabel: {e}")
            return False

        validation_results = {}

        if isinstance(gifti_img, nib.gifti.gifti.GiftiImage):
            validation_results["Type"] = True
            print("✓ Type: GIFTI Metric file")
        else:
            validation_results["Type"] = False
            print("✗ Type: Not a GIFTI file")

        num_maps = len(gifti_img.darrays)
        if num_maps == 1:
            validation_results["Number of Maps"] = True
            print(f"✓ Number of Maps: {num_maps}")
        else:
            validation_results["Number of Maps"] = False
            print(f"✗ Number of Maps: Expected 1, got {num_maps}")


        if gifti_img.darrays and len(gifti_img.darrays) > 0:

            data_array = gifti_img.darrays[0]

            # Get actual data for numeric validation
            data = data_array.data
            if data is not None and len(data) > 0:
                # Number of vertices
                num_vertices = data.shape[0]
                density = detect_density(num_vertices)
                if density in str(output_metric):
                    validation_results["Number of Vertices"] = True
                print(f"✓ Number of Vertices: {num_vertices}")
                print(f"✓ Density: {density}")

                # Statistical measures
                data_min = np.min(data)
                data_max = np.max(data)
                data_mean = np.mean(data)

                # Validate data ranges (surface areas should be positive)
                if data_min >= 0:
                    validation_results["Minimum"] = True
                    print(f"✓ Minimum: {data_min:.6f} (valid non-negative surface area)")
                else:
                    validation_results["Minimum"] = False
                    print(f"✗ Minimum: {data_min:.6f} (surface area can't be negative)")

                if data_max > 0:
                    validation_results["Maximum"] = True
                    print(f"✓ Maximum: {data_max:.6f} (valid positive surface area)")
                else:
                    validation_results["Maximum"] = False
                    print(f"✗ Maximum: {data_max:.6f} (surface area can't be positive)")

                if data_mean > 0:
                    validation_results["Mean"] = True
                    print(f"✓ Mean: {data_mean:.6f} (valid positive surface area)")
                else:
                    validation_results["Mean"] = False
                    print(f"✗ Mean: {data_mean:.6f} (surface area can't be negative)")

            else:
                validation_results["Number of Vertices"] = False
                validation_results["Minimum"] = False
                validation_results["Maximum"] = False
                validation_results["Mean"] = False
                print("✗ No data found in the metric file")

        else:
            validation_results["Number of Vertices"] = False
            validation_results["Minimum"] = False
            validation_results["Maximum"] = False
            validation_results["Mean"] = False

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
