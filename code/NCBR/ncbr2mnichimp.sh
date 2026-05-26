#!/bin/bash

############################################################
## Inflation to sphere                                    ##
############################################################

HIRES=_hires

if ! [ -f NCBR/chimpanzee_white_sphere_left${HIRES}.obj ]; then
  echo "Inflating chimpanzee_white_sphere_left${HIRES}.obj"
  inflate_to_sphere_implicit NCBR/chimpanzee_white_left${HIRES}.obj NCBR/chimpanzee_white_sphere_left${HIRES}.obj 500 1000
fi

if ! [ -f NCBR/chimpanzee_white_sphere_right${HIRES}.obj ]; then
  echo "Inflating chimpanzee_white_sphere_right${HIRES}.obj"
  inflate_to_sphere_implicit NCBR/chimpanzee_white_right${HIRES}.obj NCBR/chimpanzee_white_sphere_right${HIRES}.obj 500 1000
fi

if ! [ -f MNI152-2022/lh.MNI152.sphere.obj ]; then
  echo "Inflating lh.MNI152.sphere.obj"
  inflate_to_sphere_implicit MNI152-2022/lh.MNI152.white.obj MNI152-2022/lh.MNI152.sphere.obj 500 1000
fi                                       

if ! [ -f MNI152-2022/rh.MNI152.sphere.obj ]; then
  echo "Inflating rh.MNI152.sphere.obj"
  inflate_to_sphere_implicit MNI152-2022/rh.MNI152.white.obj MNI152-2022/rh.MNI152.sphere.obj 500 1000
fi                                       

if ! [ -f MNI152-2022/lh.MNI152.sphere80k.obj ]; then
  echo "Reducing lh.MNI152.sphere.obj to 80k"
  subdivide_polygons MNI152-2022/lh.MNI152.sphere.obj MNI152-2022/lh.MNI152.sphere80k.obj 81920
fi

if ! [ -f MNI152-2022/rh.MNI152.sphere80k.obj ]; then
  echo "Reducing rh.MNI152.sphere.obj to 80k"
  param2xfm -clob -scales -1 1 1 /tmp/flip.xfm
  transform_objects MNI152-2022/rh.MNI152.sphere.obj /tmp/flip.xfm MNI152-2022/rh.MNI152.sphere80k.obj
  subdivide_polygons MNI152-2022/rh.MNI152.sphere80k.obj MNI152-2022/rh.MNI152.sphere80k.obj 81920
  transform_objects MNI152-2022/rh.MNI152.sphere80k.obj /tmp/flip.xfm MNI152-2022/rh.MNI152.sphere80k.obj
  rm -f /tmp/flip.xfm
fi

############################################################
## Registration                                           ##
## This is the created NCBR in MNI152-2022 space          ##
## registered to the original NCBR average surface,       ##
## creating a mapping from MNI152-2022 space to NCBR      ##
## space. We must use the MNI152-2022 sphere, NOT the     ##
## sphere obtained by inflating the MNI152chimp surface.  ##
############################################################

if ! [ -d NCBR_to_MNI152chimp ]; then
  mkdir NCBR_to_MNI152chimp
fi

rm -f NCBR_to_MNI152chimp/lh.NCBR_to_MNI152.sm

# Note: CIVET/avg_white_*.obj is 80k but that's ok.

if ! [ -f NCBR_to_MNI152chimp/lh.NCBR_to_MNI152.sm ]; then
  echo "Registration NCBR (original) to NCBR average in MNI152-2022 left"
  ./supersurfreg_graham.pl -clobber \
    -source_sphere NCBR/chimpanzee_white_sphere_left${HIRES}.obj \
    -target_sphere MNI152-2022/lh.MNI152.sphere80k.obj \
    -mesh_smooth 0.90 \
    -neighbourhood_radius 2.3 \
    -min_control_mesh 320 \
    -max_control_mesh 81920 \
    -blur_coef 1.5 \
    NCBR/chimpanzee_white_left${HIRES}.obj \
    CIVET/avg_white_left_asym.obj \
    NCBR_to_MNI152chimp/lh.NCBR_to_MNI152.sm
fi

if [ -f NCBR_to_MNI152chimp/lh.NCBR_to_MNI152.sm ]; then
#   super_sphere_resample_obj -clobber -source_sphere NCBR/chimpanzee_white_sphere_left${HIRES}.obj \
#                             -target_sphere MNI152-2022/lh.MNI152.sphere80k.obj \
#                             MNI152-2022/lh.MNI152.white80k.obj \
#                             NCBR_to_MNI152chimp/lh.NCBR_to_MNI152.sm \
#                             NCBR_to_MNI152chimp/lh.MNI152-2022.white.likeNCBR.obj
# 
  surface_map_invert.pl NCBR/chimpanzee_white_sphere_left${HIRES}.obj \
                        MNI152-2022/lh.MNI152.sphere80k.obj \
                        NCBR_to_MNI152chimp/lh.NCBR_to_MNI152.sm \
                        NCBR_to_MNI152chimp/lh.MNI152_to_NCBR.sm \

#   super_sphere_resample_obj -clobber -source_sphere MNI152-2022/lh.MNI152.sphere80k.obj \
#                             -target_sphere NCBR/chimpanzee_white_sphere_left${HIRES}.obj \
#                             NCBR/chimpanzee_white_left${HIRES}.obj \
#                             NCBR_to_MNI152chimp/lh.MNI152_to_NCBR.sm \
#                             NCBR_to_MNI152chimp/lh.NCBR.white.likeMNI152-2022.obj
# 
fi

# The right side...

rm -f NCBR_to_MNI152chimp/rh.NCBR_to_MNI152.sm

if ! [ -f NCBR_to_MNI152chimp/rh.NCBR_to_MNI152.sm ]; then
  echo "Registration NCBR (original) to NCBR average in MNI152-2022 right"
  ./supersurfreg_graham.pl -clobber \
    -source_sphere NCBR/chimpanzee_white_sphere_right${HIRES}.obj \
    -target_sphere MNI152-2022/rh.MNI152.sphere80k.obj \
    -mesh_smooth 0.90 \
    -neighbourhood_radius 2.3 \
    -min_control_mesh 320 \
    -max_control_mesh 81920 \
    -blur_coef 1.5 \
    NCBR/chimpanzee_white_right${HIRES}.obj \
    CIVET/avg_white_right_asym.obj \
    NCBR_to_MNI152chimp/rh.NCBR_to_MNI152.sm
fi

if [ -f NCBR_to_MNI152chimp/rh.NCBR_to_MNI152.sm ]; then
#   super_sphere_resample_obj -clobber -source_sphere NCBR/chimpanzee_white_sphere_right${HIRES}.obj \
#                             -target_sphere MNI152-2022/rh.MNI152.sphere80k.obj \
#                             MNI152-2022/rh.MNI152.white80k.obj \
#                             NCBR_to_MNI152chimp/rh.NCBR_to_MNI152.sm \
#                             NCBR_to_MNI152chimp/rh.MNI152-2022.white.likeNCBR.obj
# 
  surface_map_invert.pl NCBR/chimpanzee_white_sphere_right${HIRES}.obj \
                        MNI152-2022/rh.MNI152.sphere80k.obj \
                        NCBR_to_MNI152chimp/rh.NCBR_to_MNI152.sm \
                        NCBR_to_MNI152chimp/rh.MNI152_to_NCBR.sm \

#   super_sphere_resample_obj -clobber -source_sphere MNI152-2022/rh.MNI152.sphere80k.obj \
#                             -target_sphere NCBR/chimpanzee_white_sphere_right.obj \
#                             NCBR/chimpanzee_white_right.obj \
#                             NCBR_to_MNI152chimp/rh.MNI152_to_NCBR.sm \
#                             NCBR_to_MNI152chimp/rh.NCBR.white.likeMNI152-2022.obj
fi


