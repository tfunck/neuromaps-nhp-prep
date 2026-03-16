#!/bin/bash

############################################################
## Inflation to sphere                                    ##
############################################################

INPUT=/home/clepage/scratch/NCBR/CHIMP-to-HUMAN
HIRES=_hires

if ! [ -f ${INPUT}/NCBR/chimpanzee_mid_sphere_left${HIRES}.obj ]; then
  echo "Inflating chimpanzee_mid_sphere_left${HIRES}.obj"
  inflate_to_sphere_implicit ${INPUT}/NCBR/chimpanzee_mid_left${HIRES}.obj ${INPUT}/NCBR/chimpanzee_mid_sphere_left${HIRES}.obj 500 1000
fi

if ! [ -f ${INPUT}/NCBR/chimpanzee_mid_sphere_right${HIRES}.obj ]; then
  echo "Inflating chimpanzee_mid_sphere_right${HIRES}.obj"
  inflate_to_sphere_implicit ${INPUT}/NCBR/chimpanzee_mid_right${HIRES}.obj ${INPUT}/NCBR/chimpanzee_mid_sphere_right${HIRES}.obj 500 1000
fi

if ! [ -f ChimpYerkes29_v1.2.L.sphere.32k_fs_LR.obj ]; then
  echo "Inflating ChimpYerkes29_v1.2.L.sphere.32k_fs_LR.obj"
  inflate_to_sphere_implicit ChimpYerkes29_v1.2.L.midthickness.32k_fs_LR.obj \
    ChimpYerkes29_v1.2.L.sphere.32k_fs_LR.obj 500 1000
fi

if ! [ -f ChimpYerkes29_v1.2.R.sphere.32k_fs_LR.obj ]; then
  echo "Inflating ChimpYerkes29_v1.2.R.sphere.32k_fs_LR.obj"
  inflate_to_sphere_implicit ChimpYerkes29_v1.2.R.midthickness.32k_fs_LR.obj \
    ChimpYerkes29_v1.2.R.sphere.32k_fs_LR.obj 500 1000
fi

############################################################
## Registration                                           ##
############################################################

# PART 1: NCBR to BNA

if ! [ -d NCBR_to_BNA ]; then
  mkdir NCBR_to_BNA
fi

# rm -f NCBR_to_BNA/lh.NCBR_to_BNA.sm

if ! [ -f NCBR_to_BNA/lh.NCBR_to_BNA.sm ]; then
  echo "Registration NCBR to BNA left"
  ${INPUT}/supersurfreg_graham.pl -clobber \
    -source_sphere ${INPUT}/NCBR/chimpanzee_mid_sphere_left${HIRES}.obj \
    -target_sphere ChimpYerkes29_v1.2.L.sphere.32k_fs_LR.obj \
    -mesh_smooth 0.90 \
    -neighbourhood_radius 2.3 \
    -min_control_mesh 320 \
    -max_control_mesh 81920 \
    -blur_coef 1.5 \
    ${INPUT}/NCBR/chimpanzee_mid_left${HIRES}.obj \
    ChimpYerkes29_v1.2.L.midthickness.32k_fs_LR.obj \
    NCBR_to_BNA/lh.NCBR_to_BNA.sm
fi

if [ -f NCBR_to_BNA/lh.NCBR_to_BNA.sm ]; then
  super_sphere_resample_obj -clobber -source_sphere ${INPUT}/NCBR/chimpanzee_mid_sphere_left${HIRES}.obj \
                            -target_sphere ChimpYerkes29_v1.2.L.sphere.32k_fs_LR.obj \
                            ChimpYerkes29_v1.2.L.midthickness.32k_fs_LR.obj \
                            NCBR_to_BNA/lh.NCBR_to_BNA.sm \
                            NCBR_to_BNA/lh.Yerkes29.mid.likeNCBR.obj

  ${INPUT}/interpolate_labels.pl ChimpBNA.L.32k_fs_LR.label.txt \
             ${INPUT}/NCBR/chimpanzee_mid_sphere_left${HIRES}.obj \
             ChimpYerkes29_v1.2.L.midthickness.32k_fs_LR.obj \
             NCBR_to_BNA/lh.NCBR_to_BNA.sm \
             NCBR_to_BNA/chimpanzee_bna_on_NCBR_left${HIRES}.txt

fi


# rm -f NCBR_to_BNA/rh.NCBR_to_BNA.sm

if ! [ -f NCBR_to_BNA/rh.NCBR_to_BNA.sm ]; then
  echo "Registration NCBR to BNA right"
  ${INPUT}/supersurfreg_graham.pl -clobber \
    -source_sphere ${INPUT}/NCBR/chimpanzee_mid_sphere_right${HIRES}.obj \
    -target_sphere ChimpYerkes29_v1.2.R.sphere.32k_fs_LR.obj \
    -mesh_smooth 0.90 \
    -neighbourhood_radius 2.3 \
    -min_control_mesh 320 \
    -max_control_mesh 81920 \
    -blur_coef 1.5 \
    ${INPUT}/NCBR/chimpanzee_mid_right${HIRES}.obj \
    ChimpYerkes29_v1.2.R.midthickness.32k_fs_LR.obj \
    NCBR_to_BNA/rh.NCBR_to_BNA.sm
fi

if [ -f NCBR_to_BNA/rh.NCBR_to_BNA.sm ]; then
  super_sphere_resample_obj -clobber -source_sphere ${INPUT}/NCBR/chimpanzee_mid_sphere_right${HIRES}.obj \
                            -target_sphere ChimpYerkes29_v1.2.R.sphere.32k_fs_LR.obj \
                            ChimpYerkes29_v1.2.R.midthickness.32k_fs_LR.obj \
                            NCBR_to_BNA/rh.NCBR_to_BNA.sm \
                            NCBR_to_BNA/rh.Yerkes29.mid.likeNCBR.obj

  ${INPUT}/interpolate_labels.pl ChimpBNA.R.32k_fs_LR.label.txt \
             ${INPUT}/NCBR/chimpanzee_mid_sphere_right${HIRES}.obj \
             ChimpYerkes29_v1.2.R.midthickness.32k_fs_LR.obj \
             NCBR_to_BNA/rh.NCBR_to_BNA.sm \
             NCBR_to_BNA/chimpanzee_bna_on_NCBR_right${HIRES}.txt

fi

# Apply global map to resample Yerkes29 sphere in NCBR space. The
# pair of original/resampled surfaces defines the transformation
# for workbench tools. Also define the sphere for the inverse
# transformation.

SIDE=L
SIDE2=left
SIDE3=lh
super_sphere_resample_obj -clobber \
                          -source_sphere NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                          -target_sphere ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
                          ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
                          NCBR_to_BNA/${SIDE3}.NCBR_to_BNA.sm \
                          NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj
obj2gii -left -mid NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj \
                   NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.surf.gii

# Invert map from NCBR (hires) to Yerkes29.

surface_map_invert.pl sphere NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                      sphere ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
                      NCBR_to_BNA/${SIDE3}.NCBR_to_BNA.sm \
                      NCBR_to_BNA/${SIDE3}.BNA_to_NCBRA.sm
super_sphere_resample_obj -clobber \
                          -source_sphere ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
                          -target_sphere NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                          NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
                          NCBR_to_BNA/${SIDE3}.BNA_to_NCBR.sm \
                          NCBR_to_BNA/ncbr_sphere_in_yerkes29_space_${SIDE2}${HIRES}.obj
obj2gii -left -mid NCBR_to_BNA/ncbr_sphere_in_yerkes29_space_${SIDE2}${HIRES}.obj \
                   NCBR_to_BNA/ncbr_sphere_in_yerkes29_space_${SIDE2}${HIRES}.surf.gii



# SIDE=R
# SIDE2=right
# SIDE3=rh
# super_sphere_resample_obj -clobber \
#                           -source_sphere NCBR/chimpanzee_white_sphere_${SIDE2}${HIRES}.obj \
#                           -target_sphere ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
#                           ChimpYerkes29_v1.2.${SIDE}.sphere.32k_fs_LR.obj \
#                           NCBR_to_BNA/${SIDE3}.NCBR_to_BNA.sm \
#                           NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj
# obj2gii -left -mid NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.obj \
#                    NCBR_to_BNA/yerkes29_sphere_in_ncbr_space_${SIDE2}${HIRES}.surf.gii




