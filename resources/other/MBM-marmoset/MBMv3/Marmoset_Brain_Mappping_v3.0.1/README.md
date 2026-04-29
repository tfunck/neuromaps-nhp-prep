## ######### 
## MBM_Marmoset_v3.0.1
## Build 20201214
## ######### 
This is the third version of the Marmoset Brain Mapping Project. 
If you have any question or meet with any issues, please contact cirongliu@gmail.com 

## Citation

1) If you used only the template of the V3, Please cite:

Liu C, Yen CC, Szczupak D, Tian X, Glen D, Silva AC. Marmoset Brain Mapping V3: Population multi-modal standard volumetric and surface-based templates. Neuroimage. 2020 Dec 8:117620. doi: 10.1016/j.neuroimage.2020.117620.

2) If you used both the template and the (V1) atlases of the V3, Please cite both:

Liu C, Yen CC, Szczupak D, Tian X, Glen D, Silva AC. Marmoset Brain Mapping V3: Population multi-modal standard volumetric and surface-based templates. Neuroimage. 2020 Dec 8:117620. doi: 10.1016/j.neuroimage.2020.117620.
Liu C, Ye FQ, Yen CC, Newman JD, Glen D, Leopold DA, Silva AC. A digital 3D atlas of the marmoset brain based on multi-modal MRI. Neuroimage. 2018 Apr 1;169:106-116. doi: 10.1016/j.neuroimage.2017.12.004. Epub 2017 Dec 5. PMID: 29208569; PMCID: PMC5856608.


## Summary
The standard anatomical brain template provides a common space and coordinate system for visualizing and analyzing neuroimaging data from large cohorts of subjects. Previous templates and atlases for the common marmoset brain were either based on data from a single individual or lacked essential functionalities for neuroimaging analysis. Here, we present new population-based in-vivo standard templates and tools derived from multi-modal data of 27 marmosets, including multiple types of T1w and T2w contrast images, DTI contrasts, and large field-of-view MRI and CT images. We performed multi-atlas labeling of anatomical structures on the new templates and constructed highly accurate tissue-type segmentation maps to facilitate volumetric studies. We built fully featured brain surfaces and cortical flat maps to facilitate 3D visualization and surface-based analyses, which are compatible with most surface analyzing tools, including FreeSurfer, AFNI/SUMA, and the Connectome Workbench. Analysis of the MRI and CT datasets revealed significant variations in brain shapes, sizes, and regional volumes of brain structures, highlighting substantial individual variabilities in the marmoset population. Thus, our population-based template and associated tools provide a versatile analysis platform and standard coordinate system for a wide range of MRI and connectome studies of common marmosets. These new template tools comprise version 3 of our Marmoset Brain Mapping Project and are publicly available via marmosetbrainmapping.org.

## Files  
    -atlas_labels.xlsx : an excel file to lookup the full name of the atlas labels
    -atlas_*.nii.gz : atlas file of different atlases
    -atlas_MBM_cortex_vL.nii.gz : the location-based parcellation (13 cortical regions) from MBM_v1 atlas (Liu, et al 2018)
    -atlas_MBM_cortex_vM.nii.gz.nii.gz : the MRI-based parcellation (54 cortical regions) from MBM_v1 atlas (Liu, et al 2018)
    -atlas_MBM_cortex_vH.nii.gz.nii.gz : the connectivity-based parcellation (103 cortical regions) from MBM_v1 atlas (Liu, et al 2018)
    -atlas_MBM_cortex_vPaxinos.nii.gz : the Paxinos brain atlas parcellation from MBM_v1 atlas (Majka, et al, 2016;Liu, et al 2018)
    -atlas_MBM_subcortical_beta.nii.gz : the subcortical beta ROIs from MBM_v1 atlas. (Liu, et al 2018)
    -atlas_RikenBMA_cortex.nii.gz : the cortical atlas from the Riken Brain and Mind atlas (Woodward et al., 2018). It also follows Paxinos nomenclatures as the atlas_MBM_cortex_vPaxinos.nii.gz
    -mask_brain.nii.gz :  brain mask
    -mask_brain_right.nii.gz : right brain mask
    -mask_brain_left.nii.gz : left brain mask
    -*_largeFOV.nii.gz :  the atlases and masks in largeFOV space (to match the matrix size of the CT template)

    -segmentation_*_types_prob_*.nii.gz : Probability maps of tissue types (3 or 6 tissue types)
    -segmentation_*_types_seg.nii.gz : hard segmentations of tissue types (3 or 6 tissue types)

    -template_DTI_.nii.gz : different DTI contrast templates
    -template_DTI_tensor.nii.gz : diffusion tensor templates

    -template_largeFOV_CT.nii.gz : large FOV CT template
    -template_largeFOV_MRI.nii.gz : large FOV head MRI low-contrast template

    -template_T1w.nii.gz : the T1w templates (MPRAGE TI=1200ms)
    -template_T2w.nii.gz : the T2w templates (RARE TE=16ms) 

    -template_MPRAGE_*.nii.gz : MPRAGE temlates for different TIs. The TI=1200ms was used as the T1w template
    -template_RARE_*.nii.gz : RARE templates (T2w) for different effective TEs (providing different levels of T2w contrasts).
    -template_myelinmap.nii.gz : myelin map template (T1w/T2w)

    -template_*_nosharp.nii.gz : the templates by only intensity averaging, without mean normalization and soft sharpening optimized by the ANTs (Avants et al., 2010). This version is more blurring than the default ones.

    -surfAFNI.CT.head.surf.gii : CT Skull surface generated by the IsoSurface of the AFNI/SUMA
    -surfAFNI.?h.pial.inflated.surf.gii : inflated pial surfaces generated by the IsoSurface of the AFNI/SUMA and inflated by the ConnectomeWorkbench command
    -surfAFNI.lh.pial.surf.gii: pial surfaces generated by the IsoSurface of the AFNI/SUMA
    -surfAFNI.lh.white.surf.gii white matter surfaces generated by the IsoSurface of the AFNI/SUMA

    -surfFS.?h.full.flat.patch.surf.gii : flat maps
    -surfFS.?h.white.inflated.surf.gii : inflated white matter surface
    -surfFS.?h.white.surf.gii : white matter surfaces
    -surfFS.?h.pial.inflated.surf.gii : inflated pial surfaces
    -surfFS.?h.pial.surf.gii : pial surfaces   
    -surfFS.?h.graymid.surf.gii : midthickness cortical surface
    -surfFS.?h.sphere.surf.gii : sphere surface generated from the inflated white matter surface
    -surfFS.?h.*.curv.shape.gii : curv files estimated by the Freesurfer
    -surfFS.?h.myelinmap.shape.gii : myelin map (T1w/T2w) projected to the Freesurfer surfaces by ConnectomeWorkbench command (myelin-styple methods)
    -surfFS.ConnectomeWorkbench_example.scene : an example scene file of ConnectomeWorkbench to display all surfFS surfaces 




