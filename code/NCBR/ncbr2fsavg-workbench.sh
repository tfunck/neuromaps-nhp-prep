#!/bin/bash

# SIDE=right
# SIDE1=R
# SIDE2=rh

SIDE=left
SIDE1=L
SIDE2=lh

surface_map_invert.pl NCBR/chimpanzee_white_sphere_${SIDE}_hires.obj \
                      FSAVG/tpl-fsaverage_den-164k_hemi-${SIDE1}_sphere.obj \
                      NCBR_to_FSAVG/ncbr_to_fsavg_${SIDE}.sm \
                      NCBR_to_FSAVG/fsavg_to_ncbr_${SIDE}.sm \

grep -v evaluations NCBR_to_FSAVG/fsavg_to_ncbr_${SIDE}.sm | grep -v triangles | grep -v elem_branch |grep -v interpolation > tmp_tmp.sm
mv tmp_tmp.sm NCBR_to_FSAVG/fsavg_to_ncbr_${SIDE}.sm

# Note: the transformation is named "source_to_target.sm" but the resampling
#       action is in the non-intuitive opposite direction -- the target is
#       resampled in the source space using the forward mapping.

super_sphere_resample_obj -clobber \
      -source_sphere NCBR/chimpanzee_white_sphere_${SIDE}_hires.obj \
      -target_sphere FSAVG/tpl-fsaverage_den-164k_hemi-${SIDE1}_sphere.obj \
      FSAVG/tpl-fsaverage_den-164k_hemi-${SIDE1}_sphere.obj \
      NCBR_to_FSAVG/ncbr_to_fsavg_${SIDE}.sm \
      NCBR_to_FSAVG/fsavg_sphere_in_ncbr_space_${SIDE}_hires_new.obj

super_sphere_resample_obj -clobber \
      -source_sphere FSAVG/tpl-fsaverage_den-164k_hemi-${SIDE1}_sphere.obj \
      -target_sphere NCBR/chimpanzee_white_sphere_${SIDE}_hires.obj \
      NCBR/chimpanzee_white_sphere_${SIDE}_hires.obj \
      NCBR_to_FSAVG/fsavg_to_ncbr_${SIDE}.sm \
      NCBR_to_FSAVG/ncbr_sphere_in_fsavg_space_${SIDE}_hires_new.obj

obj2gii -${SIDE} -mid NCBR_to_FSAVG/fsavg_sphere_in_ncbr_space_${SIDE}_hires_new.obj \
        NCBR_to_FSAVG/fsavg_sphere_in_ncbr_space_${SIDE}_hires_new.surf.gii

obj2gii -${SIDE} -mid NCBR_to_FSAVG/ncbr_sphere_in_fsavg_space_${SIDE}_hires_new.obj \
        NCBR_to_FSAVG/ncbr_sphere_in_fsavg_space_${SIDE}_hires_new.surf.gii

# Resample labels from NCBR space (chimp) to FSAVG space (human).

# How wb_command works:
#    - first sphere is the original sphere associated with the surface hosting the labels
#    - second sphere is the first sphere resampled in the space of the other surface
#      receiving the labels
#    - the new labels on the other surface

/home/users/clepage/workbench/bin_rh_linux64/wb_command \
           -label-resample NCBR/chimpanzee_desikan_killiany_${SIDE}.label.gii \
           NCBR/chimpanzee_white_sphere_right_hires.surf.gii \
           NCBR_to_FSAVG/ncbr_sphere_in_fsavg_space_${SIDE}_hires_new.surf.gii \
           'BARYCENTRIC' \
           dk_${SIDE}_on_fsavg.label.gii

gii2txt dk_${SIDE}_on_fsavg.label.gii dk_${SIDE}_on_fsavg.txt

# brain-view FSAVG/lh.white.obj dk_${SIDE}_on_fsavg.txt

# Resample labels from FSAVG space (human) to NCBR space (chimp).

/home/users/clepage/workbench/bin_rh_linux64/wb_command \
           -label-resample FSAVG/${SIDE2}.DKTatlas40.label.gii \
           FSAVG/tpl-fsaverage_den-164k_hemi-${SIDE1}_sphere.surf.gii \
           NCBR_to_FSAVG/fsavg_sphere_in_ncbr_space_${SIDE}_hires_new.surf.gii \
           'BARYCENTRIC' \
           dk_${SIDE}_on_ncbr.label.gii

gii2txt dk_${SIDE}_on_ncbr.label.gii dk_${SIDE}_on_ncbr.txt

# brain-view NCBR/chimpanzee_mid_${SIDE}_hires.obj dk_${SIDE}_on_ncbr.txt

