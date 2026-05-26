#!/bin/bash

HIRES=_hires
SIDE=rh
SIDE2=right

# Map DK parcellation from FSAVG to NCBR-CHIMP.

./interpolate_labels.pl FSAVG/${SIDE}.DKTatlas40.label.txt NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj /data/claude/bigbrain-landmarks/fsavg/${SIDE}.fsavg.sphere.obj NCBR_to_FSAVG/ncbr_to_fsavg_${SIDE2}.sm NCBR/chimpanzee_desikan_killiany_${SIDE2}.txt

txt2gii -${SIDE2} -label NCBR/chimpanzee_desikan_killiany_${SIDE2}.txt


