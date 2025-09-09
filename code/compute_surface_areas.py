#!/usr/bin/env python

# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "nibabel==5.3.2",
#     "niwrap==0.6.3",
# ]
# ///

import re
import shutil
from pathlib import Path

import nibabel as nib
from niwrap import use_docker, workbench

"""Script to compute surface areas from midthickness files."""

HEMI_MAP = {"L": "Left", "R": "Right"}


def validate_surface_area(surf_fpath: Path) -> None:
    """Validate surface file (number of vertices and hemisphere)"""
    expected_den, expected_hemi = re.search(
        r"den-([^_]+)_?hemi-([^_]+)", surf_fpath.name
    ).groups()

    surf = nib.load(surf_fpath)
    # Check hemisphere
    if HEMI_MAP[expected_hemi] not in surf.meta["AnatomicalStructurePrimary"]:
        print(
            f"{surf_fpath}:\n"
            f"Expected hemi: {expected_hemi} | Returned hemi: {surf.meta['AnatomicalStructurePrimary']}"
        )
        raise ValueError()
    # Check density
    vertices = surf.get_arrays_from_intent("normal")[0].dims[0]
    vertices_k = round(vertices / 1000)
    if str(vertices_k) not in expected_den:
        print(
            f"{surf_fpath}:\n"
            f"Expected density: {expected_den} | Return denisty: {vertices_k}k"
        )
        raise ValueError()


def compute_surface_area(mid_fpath: Path) -> Path:
    """Compute surface areas using workbench."""
    out_dir = mid_fpath.parent
    out_fname = mid_fpath.name.split(".")[0].replace(
        "midthickness", "desc-vaavg_midthickness.shape.gii"
    )
    out_fpath = out_dir / out_fname

    surf_area = workbench.surface_vertex_areas(surface=mid_fpath, metric=out_fname)
    shutil.copy(surf_area.metric, out_fpath)
    if not out_fpath.exists():
        raise FileNotFoundError(f"Could not compute surface area for: {mid_fpath}")

    return out_fpath


def main() -> None:
    """Process files."""
    # Setup niwrap to use docker
    working_dir = Path("/tmp") / "styx_tmp"
    use_docker(data_dir=working_dir)

    input_dir = Path("share/Inputs")
    for fpath in input_dir.rglob("**/*midthickness*.gii"):
        if not str(fpath).endswith(("surf.gii", "rsl.gii")):
            continue
        surf_fpath = compute_surface_area(mid_fpath=fpath)
        validate_surface_area(surf_fpath)

    # Clean up working directory
    shutil.rmtree(working_dir)


if __name__ == "__main__":
    main()
