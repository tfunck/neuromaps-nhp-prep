
##############
## MEBRAINS ##
##############
dir="data/mebrains/surfaces/"; 

mid_left_surf="${dir}/lh.MEBRAINS.mid.surf.gii"
mid_right_surf="${dir}/rh.MEBRAINS.mid.surf.gii"

pial_left_surf="${dir}/lh.MEBRAINS.pial.surf.gii"
pial_right_surf="${dir}/rh.MEBRAINS.pial.surf.gii"

wm_left_surf="${dir}/lh.MEBRAINS.smoothwm.surf.gii"
wm_right_surf="${dir}/rh.MEBRAINS.smoothwm.surf.gii"

inflated_left_surf="${dir}/lh.MEBRAINS.inflated.surf.gii"
inflated_right_surf="${dir}/rh.MEBRAINS.inflated.surf.gii"

sphere_left_surf="${dir}/lh.MEBRAINS.sphere.surf.gii"
sphere_right_surf="${dir}/rh.MEBRAINS.sphere.surf.gii"

if [[ ! -f $sphere_left_surf ]]; then
	wb_command -surface-average $mid_left_surf  -surf $pial_left_surf -surf $wm_left_surf
	mris_inflate -n 100  $mid_left_surf $inflated_left_surf
	mris_sphere -q  $inflated_left_surf $sphere_left_surf
fi 

if [[ ! -f $sphere_right_surf ]]; then
	wb_command -surface-average $mid_right_surf  -surf $pial_right_surf -surf $wm_right_surf
	mris_inflate -n 100  $mid_right_surf $inflated_right_surf
	mris_sphere -q  $inflated_right_surf $sphere_right_surf
fi

##############
### NMT2.0 ###
##############
dir="data/nmt2.0/surfaces/";

mid_left_surf="${dir}/NMT_v2.0_sym_lh.mid_surface.rsl.gii"
mid_right_surf="${dir}/NMT_v2.0_sym_rh.mid_surface.rsl.gii"

inflated_left_surf="${dir}/NMT_v2.0_sym_lh.inflated_surface.rsl.gii"
inflated_right_surf="${dir}/NMT_v2.0_sym_rh.inflated_surface.rsl.gii"

sphere_left_surf="${dir}/NMT_v2.0_sym_lh.sphere_surface.rsl.gii"
sphere_right_surf="${dir}/NMT_v2.0_sym_rh.sphere_surface.rsl.gii"


if [[ ! -f  $sphere_left_surf ]]; then
	mris_inflate -n 100 ${mid_left_surf} $inflated_left_surf 
	mris_sphere -q  ${inflated_left_surf} $sphere_left_surf 
fi 

if [[ ! -f $sphere_right_surf ]]; then
	mris_inflate -n 100 ${mid_right_surf} $inflated_right_surf 
	mris_sphere -q  ${inflated_right_surf} $sphere_right_surf 
	mv /tmp/tmp.surf.gii $sphere_right_surf 
fi


###########
### D99 ###
###########
atlas="data/d99/volumes/D99_atlas_v2.0_sym.nii.gz"

d99_atlas_surf_left="data/d99/annotations/D99_atlas_v2.0_left.func.gii"
d99_atlas_surf_right="data/d99/annotations/D99_atlas_v2.0_right.func.gii"

d99_surf_left="data/d99/surfaces/D99_L_AVG_T1_v2.L.MID.167625.surf.gii"
d99_surf_right="data/d99/surfaces/D99_L_AVG_T1_v2.R.MID.167625.surf.gii"

if [[ ! -f $d99_atlas_surf_left ]]; then
	echo "Mapping D99 atlas to left hemisphere"
	wb_command -volume-to-surface-mapping $atlas $d99_surf_left $d99_atlas_surf_left -trilinear
fi

if [[ ! -f $d99_atlas_surf_right ]]; then
	wb_command -volume-to-surface-mapping $atlas $d99_surf_right $d99_atlas_surf_right -trilinear
fi

echo wb_view $d99_surf_left $d99_atlas_surf_left



