import sys
import nibabel as nib

if len(sys.argv) < 2:
    print("Usage: python vertices.py <path_to_gii_file>")
    sys.exit(1)

input_file = sys.argv[1]

gii = nib.load(input_file)
arrays = gii.get_arrays_from_intent('NIFTI_INTENT_POINTSET')

if not arrays:
    # No pointset array found, print 0 or some error code
    print("0")
    sys.exit(0)

pointset_array = arrays[0]
vertices = pointset_array.data.shape[0]

# Round to nearest thousand
vertices_k = round(vertices / 1000)

print(f"{vertices_k}k")
#print(f"{vertices}")
