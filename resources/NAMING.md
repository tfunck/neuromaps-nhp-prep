# neuromaps-PRIME Annotation Files

This document describes the annotation files and the naming convention used to identify them.

## Naming Convention

Filenames follow the [BIDS](https://bids-specification.readthedocs.io/en/stable/) specification as closely as possible.

```
src-{space}_den-{den}k_hemi-{hemi}_{subLabelCode}-{subLabel}_desc-{annotationCode}_annot.{extension}
```

| Field | Meaning |
|---|---|
| `space` | The reference/coordinate space the data is aligned to (e.g., `fsLR`, `fsaverage`) |
| `den` | Surface mesh density, in thousands of vertices (e.g., `32k`, `164k`) |
| `hemi` | Hemisphere (`L` = left, `R` = right) |
| `subLabelCode`-`subLabel` | A short code identifying the specific source/variant of the data (e.g., dataset, parcellation name, atlas name), followed by its descriptive name — see [Sub-Label Naming Resources](#sub-label-naming-resources) below |
| `annotationCode` | A short code (below) identifying which **type** of annotation the file contains |
| `extension` | File format (e.g., `.shape.gii`, `.label.gii`, `.nii.gz`, `.txt`) |

## Annotation Type Codes

These codes appear after `desc-` in the filename and indicate the kind of data stored in the file.

| Code | Annotation Type | Description |
|---|---|---|
| **AT** | Atlas | Volumetric atlases (`.nii.gz`) and lookup files (`.txt`) defining labeled regions across cortical and subcortical structures in a common reference space |
| **BM** | Brain Masks | Binary or probabilistic maps defining which surface vertices or voxels correspond to valid cortical tissue (used for masking and analysis inclusion) |
| **CT** | Cortical Thickness | Vertex-wise estimates of the distance between the white matter and pial surfaces, reflecting local cortical thickness |
| **CV** | Curvature | Vertex-wise measures of cortical surface geometry (e.g., mean or Gaussian curvature) indicating gyral and sulcal folding patterns |
| **IT** | Intrinsic Timescale | Regional estimates of neural temporal autocorrelation (e.g., decay constants from fMRI time series), reflecting how quickly activity fluctuates over time |
| **MM** | Myelin Maps | Vertex-wise estimates of cortical myelin content, commonly derived from MRI contrasts such as T1w/T2w ratio and reflecting intracortical myelination |
| **PC** | Parcellations | Discrete atlas-based assignments mapping each surface vertex or voxel to a labeled cortical region, often used to define analysis units |
| **RM** | Receptor Maps | Spatial maps of neurotransmitter receptor density or binding potential, typically derived from PET or autoradiography imaging and aligned to a common surface or volume space |
| **SD** | Sulcal Depth | Vertex-wise measure of the depth of cortical folds, defined as the distance between the cortical surface and a reference (e.g., inflated or convex hull surface) |
| **SMM** | Smoothed Myelin Maps | Spatially smoothed versions of myelin maps (e.g., using surface-based kernels) to improve signal-to-noise ratio and emphasize large-scale gradients |
| **TPL** | Templates | Reference anatomical volumes or surfaces defining a standard coordinate space to which other data are aligned |
| **TPM** | Tissue Probability Maps | Voxel-wise probabilistic maps indicating the likelihood that a given location belongs to a specific tissue class (e.g., gray matter, white matter, CSF) |

## Sub-Label Naming Resources

The `subLabelCode-subLabel` portion of the filename identifies the specific source of the data (e.g., which dataset, atlas, or parcellation it comes from). When naming or interpreting sub-labels, refer to:

- [BIDS Specification: Entities](https://bids-specification.readthedocs.io/en/stable/appendices/entities.html#entities)

## Example

**Surface file:**

```
src-Yerkes19_den-10k_hemi-L_atlas-Yeo7Networks_desc-PC_annot.label.gii
```

- **Space:** Yerkes19
- **Density:** 10k vertices
- **Hemisphere:** Left
- **Atlas:** Yeo7Networks
- **Annotation type:** Parcellation (PC)


**Volume file:**

```
src-MBM_den-08mm_desc-BM_annot.nii
```

- **Space:** MBM
- **Density:** 0.8mm voxel resolution
- **Hemisphere / sub-label:** n/a (omitted for volume files)
- **Annotation type:** Brain Mask (BM)