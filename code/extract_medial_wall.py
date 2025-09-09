#!/usr/bin/env python

# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "nibabel==5.3.2",
#     "niwrap==0.6.3",
# ]
# ///

"""Script to extract (and optionally resample) medial wall for NHP templates."""

import shutil
import tempfile
from pathlib import Path

import nibabel as nib
import numpy as np
from niwrap import use_docker, workbench

HEMIS = ("L", "R")
TPLS_MAP = {
    "CIVETNMT": {  # Also uses the D99, there might be better atlas
        "atlas": "D99_atlas_cortical_labels.txt",
        "surf": "src-CIVETNMT_den-41k_hemi-{hemi}_midthickness.surf.gii",
        "vol": "D99_atlas_v2.0_sym.nii.gz",
    },
    "D99": {
        "atlas": "D99_atlas_cortical_labels.txt",
        "surf": "src-D99_den-41k_hemi-{hemi}_midthickness.surf.gii",
        "vol": "D99_atlas_v2.0_sym.nii.gz",
    },
    "MEBRAINS": "{hemi}.MEBRAINS_brainmask.func.gii",
    "NMT2": {  # This does an okay job, but there might be a better volume
        "surf": "src-NMT2_den-41k_hemi-{hemi}_desc-sym_midthickness.rsl.gii",
        "vol": "NMT_v2.0_sym_GM_cortical_mask.nii.gz",
    },
    "S1200_10k": "{hemi}.Glasser2016.human.10k_fs_LR.label.gii",
    "S1200_32k": "S1200.corrThickness_MSMAll.32k_fs_LR.dscalar.nii",
    "Yerkes19_10k": "{hemi}.Markov.monkey.10k_fs_LR.label.gii",
    "Yerkes19_32k": "MacaqueYerkes19_v1.2.corrThickness.32k_fs_LR.dscalar.nii",
}
OUT_FNAME = "src-{template}_den-{den}k_hemi-{hemi}_desc-nomedialwall_dparc.label.gii"


def _save_output(src: Path, tpl_dir: Path, hemi: str) -> None:
    """Copy file to output location."""
    shutil.copy(
        src,
        tpl_dir
        / OUT_FNAME.format(
            template=tpl_dir.name, den=_find_density(fpath=src), hemi=hemi
        ),
    )


def _find_density(fpath: Path) -> int:
    """Determine the number of vertices"""
    surf = nib.load(fpath)
    vertices = len(surf.darrays[0].data)
    return round(vertices / 1000)


def medial_wall_from_thickness(tpl_dir: Path, tpl_surf: str) -> None:
    """Find medial wall from cortical thickness."""
    # Split thickness by hemisphere
    metrics = workbench.cifti_separate(
        cifti_in=tpl_dir / tpl_surf,
        direction="COLUMN",
        metric=[
            workbench.cifti_separate_metric_params(
                structure=structure, metric_out=f"{hemi}_thickness.func.gii"
            )
            for structure, hemi in zip(("CORTEX_LEFT", "CORTEX_RIGHT"), HEMIS)
        ],
    ).metric

    for hemi, metric in zip(HEMIS, metrics):
        thick = workbench.metric_math(
            expression="x==0",
            metric_out=f"{hemi}.func.gii",
            var=[workbench.metric_math_var_params(name="x", metric=metric.metric_out)],
        )
        mask = workbench.metric_label_import(
            input_=thick.metric_out,
            label_list_file="",
            output=f"{hemi}_nan.label.gii",
            opt_drop_unused_labels=True,
        )
        _save_output(src=mask.output, tpl_dir=tpl_dir, hemi=hemi)


def medial_wall_resampled_metric(tpl_dir: Path, tpl_dict: dict[str, str]) -> None:
    """Find medial wall using resampled label."""
    metrics = workbench.cifti_separate(
        cifti_in=tpl_dir.parent / tpl_dict["metric"],
        direction="COLUMN",
        metric=[
            workbench.cifti_separate_metric_params(
                structure=structure,
                metric_out=f"{hemi}_thickness.func.gii",
            )
            for structure, hemi in zip(("CORTEX_LEFT", "CORTEX_RIGHT"), HEMIS)
        ],
    ).metric
    for hemi, metric in zip(HEMIS, metrics):
        resampled_metric = workbench.metric_resample(
            metric_in=metric.metric_out,
            current_sphere=tpl_dir.parent / tpl_dict["old_sphere"].format(hemi=hemi),
            new_sphere=tpl_dir.parents[-2] / tpl_dict["reg_sphere"].format(hemi=hemi),
            method="ADAP_BARY_AREA",
            metric_out=f"{hemi}.Markov.resampled.func.gii",
            area_surfs=workbench.metric_resample_area_surfs_params(
                current_area=tpl_dir.parent
                / tpl_dict["old_sphere"]
                .format(hemi=hemi)
                .replace("sphere", "midthickness"),
                new_area=tpl_dir
                / tpl_dict["new_sphere"]
                .format(hemi=hemi)
                .replace("sphere", "midthickness"),
            ),
        )
        thick = workbench.metric_math(
            expression="x==0",
            metric_out=f"{hemi}.func.gii",
            var=[
                workbench.metric_math_var_params(
                    name="x", metric=resampled_metric.metric_out
                )
            ],
        )
        mask = workbench.metric_label_import(
            input_=thick.metric_out,
            label_list_file="",
            output=f"{hemi}_nan.label.gii",
            opt_drop_unused_labels=True,
        )
        _save_output(src=mask.output, tpl_dir=tpl_dir, hemi=hemi)


def medial_wall_from_label(tpl_dir: Path, tpl_label: str, hemi: str) -> None:
    """Find medial wall using NaN values from label."""
    roi = workbench.metric_math(
        expression="x==0",
        metric_out="nan.func.gii",
        var=[
            workbench.metric_math_var_params(
                name="x", metric=tpl_dir / tpl_label.format(hemi=hemi)
            )
        ],
    )
    _save_output(src=roi.metric_out, tpl_dir=tpl_dir, hemi=hemi)


def medial_wall_from_volume(tpl_dir: Path, tpl_vol: str, tpl_surf: str) -> None:
    """Infer medial wall using volume mapped to surface."""
    for hemi in HEMIS:
        metric = workbench.volume_to_surface_mapping(
            volume=tpl_dir / tpl_vol,
            surface=tpl_dir / tpl_surf.format(hemi=hemi),
            metric_out="temp_metric.func.gii",
            ribbon_constrained=workbench.volume_to_surface_mapping_ribbon_constrained_params(
                inner_surf=tpl_dir
                / tpl_surf.format(hemi=hemi).replace("midthickness", "white"),
                outer_surf=tpl_dir / tpl_surf.format(hemi=hemi),
                opt_interpolate_method="TRILINEAR",
            ),
        )
        roi = workbench.metric_math(
            expression="x==0",
            metric_out="nan.func.gii",
            var=[workbench.metric_math_var_params(name="x", metric=metric.metric_out)],
        )
        # Just to be sure, grab largest iisland and perform closing
        roi = workbench.metric_remove_islands(
            surface=tpl_dir / tpl_surf.format(hemi=hemi),
            metric_in=roi.metric_out,
            metric_out="wall.func.gii",
        )
        roi = workbench.metric_fill_holes(
            surface=tpl_dir / tpl_surf.format(hemi=hemi),
            metric_in=roi.metric_out,
            metric_out="wall_fixed.func.gii",
        )
        _save_output(src=roi.metric_out, tpl_dir=tpl_dir, hemi=hemi)


def medial_wall_from_atlas(
    tpl_dir: Path, tpl_surf: str, tpl_vol: str, tpl_atlas: str
) -> None:
    """Infer medial wall using cortical atlas labels."""
    atlas_labels = list(map(int, (tpl_dir / tpl_atlas).read_text().split()))
    atlas_nii = nib.load(tpl_dir / tpl_vol)
    # Identify cortical mask
    atlas_arr = atlas_nii.get_fdata()
    mask_arr = np.isin(atlas_arr, atlas_labels).astype(np.uint8)
    mask_nii = nib.Nifti1Image(mask_arr, affine=atlas_nii.affine)
    with tempfile.NamedTemporaryFile(dir=tpl_dir, suffix=".nii.gz") as tmp_file:
        nib.save(mask_nii, tmp_file.name)
        medial_wall_from_volume(
            tpl_dir=tpl_dir, tpl_vol=tmp_file.name, tpl_surf=tpl_surf
        )


def main() -> None:
    # Setup niwrap to use docker
    input_dir = Path("share/Inputs")
    working_dir = Path("/tmp/styx_tmp")
    use_docker(data_dir=working_dir)

    # Extract medial wall
    for tpl_name, tpl_item in TPLS_MAP.items():
        tpl_dir = input_dir / tpl_name.split("_")[0]

        if isinstance(tpl_item, dict):
            if "metric" in tpl_item.keys():
                medial_wall_resampled_metric(tpl_dir=tpl_dir, tpl_dict=tpl_item)
            else:
                medial_wall_from_volume(
                    tpl_dir=tpl_dir, tpl_vol=tpl_item["vol"], tpl_surf=tpl_item["surf"]
                )
        else:
            if "32k" in tpl_name:
                medial_wall_from_thickness(tpl_dir=tpl_dir, tpl_surf=tpl_item)
            else:
                for hemi in HEMIS:
                    medial_wall_from_label(
                        tpl_dir=tpl_dir,
                        tpl_label=tpl_item,
                        hemi="lh" if hemi == "L" else "rh",
                    )

    # Clean up working directory
    shutil.rmtree(working_dir)


if __name__ == "__main__":
    main()
