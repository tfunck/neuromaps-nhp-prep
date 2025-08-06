
# Create symmetric version of the D99 atlas
if [[ ! -f "data/d99/volumes/D99_atlas_v2.0_sym.nii.gz" ]] ; then

    python3 fliplr.py  "data/d99/volumes/D99_atlas_v2.0_right.nii.gz" "data/d99/volumes/D99_atlas_v2.0_sym.nii.gz"
fi
