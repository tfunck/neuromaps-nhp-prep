#!/usr/bin/env python

# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "niwrap==0.6.3",
# ]
# ///

"""Script to perform midthickness transformation to target space."""

import itertools as it
import shutil
from pathlib import Path

from niwrap import use_docker, workbench

HEMIS = ("L", "R")
TEMPLATES = ("S1200", "Yerkes19")
DENSITIES = ("10k", "32k")


def xfm_midthickness(input_dir: Path, src: str, tgt: str) -> None:
    """Perform midthickness transformation."""
    src_dir = input_dir / "Inputs" / src
    tgt_dir = input_dir / f"Outputs/{tgt}-{src}"

    for den, hemi in it.product(DENSITIES, HEMIS):
        print(f"[PROCESSING] {src}-to-{tgt} (hemi={hemi}, den={den})")
        ref_midthickness = (
            src_dir.parent
            / tgt
            / f"src-{tgt}_den-{den}_hemi-{hemi}_midthickness.surf.gii"
        )
        src_midthickness = (
            src_dir / f"src-{src}_den-{den}_hemi-{hemi}_midthickness.surf.gii"
        )
        src_sphere = src_dir / f"src-{src}_den-{den}_hemi-{hemi}_sphere.surf.gii"
        tgt_sphere = (
            tgt_dir / f"src-{src}_to-{tgt}_den-{den}_hemi-{hemi}_sphere.surf.gii"
        )
        tgt_midthickness = (
            tgt_dir / f"src-{src}_to-{tgt}_den-{den}_hemi-{hemi}_midthickness.surf.gii"
        )
        surface_resample = workbench.surface_resample(
            surface_in=src_midthickness,
            current_sphere=src_sphere,
            new_sphere=tgt_sphere,
            method="ADAP_BARY_AREA",
            surface_out=tgt_midthickness.name,
            area_surfs=workbench.surface_resample_area_surfs_params(
                current_area=src_midthickness,
                new_area=ref_midthickness,
            ),
        )
        shutil.copy(surface_resample.surface_out, tgt_midthickness)


def main() -> None:
    # Setup niwrap to use podman (set uid=0 to run as root inside the container)
    input_dir = Path("share").absolute()
    use_docker(
        data_dir=Path("/tmp/styx_tmp"), docker_executable="podman", docker_user_id=0
    )

    for src, tgt in it.permutations(TEMPLATES, 2):
        xfm_midthickness(input_dir=input_dir, src=src, tgt=tgt)


if __name__ == "__main__":
    main()
