#!/bin/bash

HIRES=_hires
SIDE=lh
SIDE2=left

if ! [ -d NCBR_to_FSAVG ]; then
  mkdir NCBR_to_FSAVG
fi


# Invert map from MNI152 (hires) to FSAVG.

surface_map_invert.pl /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj \
                      MNI152-2022/${SIDE}.MNI152.sphere.obj \
                      /data/claude/bigbrain-landmarks/fsavg_to_MNI152/${SIDE}.fsavg_to_MNI152.sm \
                      /tmp/${SIDE}.MNI152_to_fsavg.sm

# Refine map for hires MNI152 sphere, lowres NCBR sphere. This is
# because the MNI152-to-FSAVG is hires-to-hires.
#   interpolate_surfmap output_sphere1 input_sphere1 output_sphere2 input_sphere2 in.sm out.sm
# We want NCBR in hires.

interpolate_surfmap NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                    NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                    MNI152-2022/${SIDE}.MNI152.sphere.obj \
                    MNI152-2022/${SIDE}.MNI152.sphere80k.obj \
                    NCBR_to_MNI152chimp/${SIDE}.NCBR_to_MNI152.sm \
                    /tmp/${SIDE}.NCBR_hires_to_MNI152_hires.sm

# Concatenate the transformations to have NCBR-to-FSAVG global map.

surface_map_concat.pl NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                      MNI152-2022/${SIDE}.MNI152.sphere.obj \
                      /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj \
                      /tmp/${SIDE}.NCBR_hires_to_MNI152_hires.sm \
                      /tmp/${SIDE}.MNI152_to_fsavg.sm \
                      NCBR_to_FSAVG/ncbr_to_fsavg_${SIDE2}.sm

rm -f /tmp/${SIDE}.MNI152_to_fsavg.sm
rm -f /tmp/${SIDE}.NCBR_hires_to_MNI152_hires.sm

# Compute inverse of global transformation.

surface_map_invert.pl NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                      /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj \
                      NCBR_to_FSAVG/ncbr_to_fsavg_${SIDE2}.sm \
                      NCBR_to_FSAVG/fsavg_to_ncbr_${SIDE2}.sm

# Apply global map to resample FSAVG surface in NCBR space.

super_sphere_resample_obj -clobber \
                          -source_sphere NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                          -target_sphere /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj \
                          FSAVG/${SIDE}.sphere.obj \
                          NCBR_to_FSAVG/ncbr_to_fsavg_${SIDE2}.sm \
                          NCBR_to_FSAVG/fsavg_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj

# Apply global map to resample FSAVG sphere in NCBR space. The
# pair of original/resampled surfaces defines the transformation
# for workbench tools.

super_sphere_resample_obj -clobber \
                          -source_sphere NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                          -target_sphere /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj \
                          /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj \
                          NCBR_to_FSAVG/ncbr_to_fsavg_${SIDE2}.sm \
                          NCBR_to_FSAVG/fsavg_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj

# Apply global map to resample labels from NCBR to FSAVG.
# labels_on_target  source_sphere  target_sphere  map.sm  output_on_source.txt

./interpolate_labels.pl ../ChimpBNA-main/NCBR_to_BNA/chimpanzee_bna_on_NCBR_${SIDE2}${HIRES}.txt \
                        /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj \
                        NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                        NCBR_to_FSAVG/fsavg_to_ncbr_${SIDE2}.sm \
                        NCBR_to_FSAVG/chimpanzee_bna_${SIDE2}_in_fsavg_space.txt

./interpolate_labels.pl NCBR/chimpanzee_juna_${SIDE2}_masked.txt \
                        /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj \
                        NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                        NCBR_to_FSAVG/fsavg_to_ncbr_${SIDE2}.sm \
                        NCBR_to_FSAVG/chimpanzee_juna_${SIDE2}_in_fsavg_space.txt

# Conversion to gii. 

obj2gii -${SIDE2} -white /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj NCBR_to_FSAVG/fsavg_sphere_${SIDE2}.surf.gii
obj2gii -${SIDE2} -white NCBR_to_FSAVG/fsavg_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj
txt2gii -${SIDE2} -label NCBR_to_FSAVG/chimpanzee_bna_${SIDE2}_in_fsavg_space.txt
txt2gii -${SIDE2} -label NCBR_to_FSAVG/chimpanzee_juna_${SIDE2}_in_fsavg_space.txt


# Map DK parcellation from FSAVG to NCBR-CHIMP.

./interpolate_labels.pl FSAVG/${SIDE}.DKTatlas40.label.txt NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj NCBR_to_FSAVG/ncbr_to_fsavg_${SIDE2}.sm NCBR/chimpanzee_desikan_killiany_${SIDE2}.txt

txt2gii -${SIDE2} -label NCBR/chimpanzee_desikan_killiany_${SIDE2}.txt


