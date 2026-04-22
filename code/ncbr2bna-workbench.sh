#!/bin/bash

############################################################
## Inflation to sphere                                    ##
############################################################

HIRES=_hires

# SIDE=L
# SIDE2=left
# SIDE3=lh

# repeat with right side
SIDE=R
SIDE2=right
SIDE3=rh

# Apply global map to resample Yerkes29 sphere in NCBR space. The
# pair of original/resampled surfaces defines the transformation
# for workbench tools.

super_sphere_resample_obj -clobber \
                          -source_sphere ../NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                          -target_sphere ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
                          ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
                          NCBR_to_BNA/${SIDE3}.NCBR_to_BNA.sm \
                          NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj
obj2gii -${SIDE2} -mid NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj \
                   NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.surf.gii


# Invert map from NCBR (hires) to Yerkes29.

surface_map_invert.pl ../NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                      ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
                      NCBR_to_BNA/${SIDE3}.NCBR_to_BNA.sm \
                      NCBR_to_BNA/${SIDE3}.BNA_to_NCBR.sm

# get rid of annoying verbose statements in .sm

grep -v evaluations NCBR_to_BNA/${SIDE3}.BNA_to_NCBR.sm | grep -v triangles | grep -v elem_branch |grep -v interpolation > tmp_tmp.sm
mv tmp_tmp.sm NCBR_to_BNA/${SIDE3}.BNA_to_NCBR.sm

super_sphere_resample_obj -clobber \
                          -source_sphere ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
                          -target_sphere ../NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                          ../NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                          NCBR_to_BNA/${SIDE3}.BNA_to_NCBR.sm \
                          NCBR_to_BNA/ncbr_sphere_in_yerkes29_space_${SIDE2}${HIRES}.obj
obj2gii -${SIDE2} -mid NCBR_to_BNA/ncbr_sphere_in_yerkes29_space_${SIDE2}${HIRES}.obj \
                   NCBR_to_BNA/ncbr_sphere_in_yerkes29_space_${SIDE2}${HIRES}.surf.gii

# --------------------------------------------------------------------------------------

# Verification of resampling labels using wb_command.

# labels on NCBR chimp to yerkes29 chimp

/home/users/clepage/workbench/bin_rh_linux64/wb_command \
           -label-resample ../NCBR/chimpanzee_desikan_killiany_${SIDE2}.label.gii \
           ../NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.surf.gii \
           NCBR_to_BNA/ncbr_sphere_in_yerkes29_space_${SIDE2}${HIRES}.surf.gii \
           'BARYCENTRIC' \
           dk_${SIDE2}_on_yerkes29.label.gii

gii2txt dk_${SIDE2}_on_yerkes29.label.gii dk_${SIDE2}_on_yerkes29.txt

# BNA labels on yerkes29 chimp to NCBR chimp

/home/users/clepage/workbench/bin_rh_linux64/wb_command \
           -label-resample ChimpBNA.${SIDE1}.32k_fs_LR.label.gii \
           ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.surf.gii \
           NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.surf.gii \
           'BARYCENTRIC' \
           bna_${SIDE2}_on_ncbr.label.gii

gii2txt bna_${SIDE2}_on_ncbr.label.gii bna_${SIDE2}_on_ncbr.txt




