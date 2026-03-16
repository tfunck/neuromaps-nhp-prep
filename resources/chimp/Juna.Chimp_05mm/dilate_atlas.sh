#!/bin/bash

# Remove non-cortical labels.

minccalc -quiet -clob -unsigned -byte -expr \
         'if( (A[0]>96.5&&A[0]<100.5)||(A[0]>102.5)||(A[0]>66.5&&A[0]<70.5)){0}else{A[0]}' \
         Davi130_05mm_painted_CL.mnc /tmp/mm.mnc
mincreshape -quiet -clob -image_range 0 255 -valid_range 0 255 /tmp/mm.mnc \
         Davi130_05mm_cortical.mnc
rm -f /tmp/mm.mnc

cp Davi130_05mm_cortical.mnc toto.mnc

# Dilate labels by N layers into background.

for iter in {1..5}; do
  for label in {{1..66},{71..96},{101..102}}; do
    echo $label
    dilate_volume toto.mnc toto.mnc $label 6 1 toto.mnc -0.5 0.5
  done
done

mincreshape -quiet -clob -image_range 0 255 -valid_range 0 255 toto.mnc \
            Davi130_05mm_cortical.mnc
rm -f toto.mnc

