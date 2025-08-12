import argparse
import nibabel as nib

def main():
    parser = argparse.ArgumentParser(
        description="Calculate the number of vertices in a GIFTI (.gii) file."
    )
    parser.add_argument(
        "gii_file",
        help="Path to the GIFTI (.gii) file"
    )

    args = parser.parse_args()

    gii = nib.load(args.gii_file)
    arrays = gii.get_arrays_from_intent('NIFTI_INTENT_POINTSET')

    if not arrays:
        raise ValueError("No array found in the GIFTI file.")

    pointset_array = arrays[0]
    vertices = pointset_array.data.shape[0]

    # Round to nearest thousand
    vertices_k = round(vertices / 1000)

    print(f"{vertices_k}k")
    # print(f"{vertices}")

if __name__ == "__main__":
    main()
