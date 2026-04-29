## ######### 
## MBM_Marmoset_v5.0_build20230117
## ######### 
This is the fifth version of the Marmoset Brain Mapping Project. 
If you have any question or meet with any issues, please contact cirongliu@gmail.com 


## Files  


    -Template_sym_*.nii.gz -- Multi-modal MRI templates,copy from MBM_Marmoset_v2.1


    -atlas_*.nii.gz : atlas file of different atlases
    -atlas_Marmoset_CERB_13lobule.nii.gz : the anatomical parcellation (13 cerebeller regions) 
    -atlas_Marmoset_CERB_17lobule.nii.gz : the anatomical parcellation (17 cerebeller regions) 
    -atlas_Marmoset_CERB_13lobule.shape.gii : parcellation map (13 cerebeller regions) projected to the Freesurfer surfaces by ConnectomeWorkbench command
    -atlas_Marmoset_CERB_17lobule.shape.gii : parcellation map (17 cerebeller regions) projected to the Freesurfer surfaces by ConnectomeWorkbench command
    -atlas_Marmoset_CERB_nuclei.nii.gz :  the anatomical parcellation of cerebellar nuclei (fastigial nucleus, interpositus nucleus and dentate nucleus) 
    -atlas_Marmoset_CERB_nuclei_tracking.nii.gz : the tracking-based parcellation of nuclei (label 1-8 represent lobules I-VI, VII-VIII  IX-X, FL-PFL, Cop, Par, Sim, CrusI-II, respectively)

    
    -sub_all_gradient*.nii.gz : intra-cerebellar functional gradients based on the awake resting-state fMRI data of the 39 marmosets
    -sub_all_5k_8k_gradient*.nii.gz : cerebello-cerebral functional gradients volume based on the awake resting-state fMRI data of the 39 marmosets
    -sub_all_gradient*.func.gii : intra-cerebellar functional gradients mapped on surface 
    -sub_all_5k_8k_gradient*.func.gii : cerebello-cerebral functional gradients mapped on surface 
    -sub_all_gradient*masked.func.gii : functional gradient maps without cerebellar peduncles
    -sub_all_ct-nuclei_gradient_*.nii.gz : cerebral-nuclei functional gradients based on the awake resting-state fMRI data of the 39 marmosets
    -nuclei1-3_map_gradient.nii.gz : the tracking-based cerebello-cerebral functional gradient-1 mapping of nuclei

    -mask_Marmoset_CERB.nii.gz : cerebellum mask
    -mask_Marmoset_CERB_L.nii.gz : left cerebellum mask
    -mask_Marmoset_CERB_R.nii.gz : right cerebellum mask
    -mask_Marmoset_CERB_wm.nii.gz : cerebellar white matter mask
    -mask_Marmoset_CERB_gm.nii.gz : cerebellar gray matter mask
    

    -surfFS.CERB.flatmap.surf.gii : flat maps
    -surfFS.CERB.pial_inflate.surf.gii : inflated pial surface
    -surfFS.CERB.orig.surf.gii: white matter surface
    -surfFS.CERB.pial.surf.gii : pial surface
    -surfFS.CERB.pial_sphere.surf.gii : sphere surface generated from the inflated pial surface
    -surfFS.CERB.curv.shape.gii : cortical curvature  estimated by the Freesurfer
    -surfFS.CERB.curv.pial.shape.gii : pial curv estimated by the Freesurfer
    -surfFS.CERB.thickness.shape.gii : cortical thickness estimated by the Freesurfer
    
    -MBM_V5_Cerebellum.scene : an example scene file of ConnectomeWorkbench to display all surfFS surfaces 
    
## Label
    
	#label of atlas_Marmoset_CERB_17lobule*:

	label:[
	{index: 0, background },
	{index: 1, I : Lingula I },
	{index: 2, II : Central lobule II },
	{index: 3, III : Culmen III },
	{index: 4, IV : Declive IV },
	{index: 5, V : Lobule V },
	{index: 6, VI : Folium VI },
	{index: 7, VII : Tuber VII },
	{index: 8, VIII : Pyramid VIII },
	{index: 9, IX : Uvula IX },
	{index: 10, X : Nodulus X },
	{index: 11, Fl : Flocculus },
	{index: 12, COP : Copula },
	{index: 13, PAR : Paramedian lobule },
	{index: 14, SIM : Simplex lobule },
	{index: 15, Crus I : Crus I },
	{index: 16, Crus II : Crus II },
	{index: 17, PFl : Paraflocculus }
	]

			
	#label of atlas_Marmoset_CERB_13lobule*:

	label:[
	{index: 0, background },
	{index: 1, I-IV : Lingula I and Central lobule II and Culmen III and Declive IV },
	{index: 5, V : Lobule V },
	{index: 6, VI : Folium VI },
	{index: 7, VII : Tuber VII },
	{index: 8, VIII : Pyramid VIII },
	{index: 9, IX-X : Uvula IX and Nodulus X },
	{index: 11, Fl : Flocculus },
	{index: 12, COP : Copula },
	{index: 13, PAR : Paramedian lobule },
	{index: 14, SIM : Simplex lobule },
	{index: 15, Crus I : Crus I },
	{index: 16, Crus II : Crus II },
	{index: 17, PFl : Paraflocculus }
	]

    # label of atlas_Marmoset_CERB_nuclei.nii.gz

    label:[
	{index: 0, background },
	{index: 18, FN : Fastigial nucleus  },
	{index: 19, IN : Interpositus nucleus },
	{index: 20, DN : Dentate nucleus }
	]
