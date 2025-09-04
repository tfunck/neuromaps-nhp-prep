#!/usr/bin/env python

# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "nibabel==5.3.2",
# ]
# ///

"""Script to rename input and output files of neuromaps-nhp-prep."""

import re
from pathlib import Path

import nibabel as nib

HEMI_MAP = {
    "L": "L",
    "l": "L",
    "lh": "L",
    "left": "L",
    "R": "R",
    "r": "R",
    "rh": "R",
    "right": "R",
}


def find_surf_density(fpath: Path) -> str:
    """Find and return number of vertices in a surface file."""
    gii = nib.load(fpath)
    pointset_array = gii.get_arrays_from_intent("NIFTI_INTENT_POINTSET")[0]
    vertices = pointset_array.data.shape[0]
    vertices_k = round(vertices / 1000)
    return f"{vertices_k}k"


def find_prefix(fpath: Path) -> tuple[str, ...]:
    """Get template and target entities."""
    parent_dir = fpath.parts[-2].split("-")
    if (parts := len(parent_dir)) > 2:
        raise ValueError(f"Unable to determine template and target: {parent_dir}")
    return parent_dir if parts == 2 else (None, parent_dir[0])


def find_entities(fpath: Path, template: str, regex: dict[str, str]) -> dict[str, str]:
    """Get all other relevant entities."""
    fname = fpath.name
    entity_map = re.match(regex[template] if type(regex) is dict else regex, fname)
    if not entity_map:
        print(f"WARNING: Did not find matching entities for: {fpath.name}")
        return {}
    entity_map = entity_map.groupdict()
    if entity_map.get("suffix") is not None and entity_map["suffix"] == "mid":
        entity_map["suffix"] = "midthickness"
    return entity_map


def rename_surf(fpath: Path, regex: dict[str, str]) -> None:
    """Rename surface file."""
    # Find template (and target)
    target, template = find_prefix(fpath=fpath)

    # Find density
    density = find_surf_density(fpath)

    # Find other entities
    entity_map = find_entities(fpath=fpath, template=template, regex=regex)
    if entity_map:
        out_fname = (
            f"src-{template}"
            f"{f'_to-{target}' if target is not None else ''}"
            f"_den-{density}"
            f"_hemi-{HEMI_MAP[entity_map['hemi']]}"
            f"{f'_desc-{entity_map["desc"]}' if entity_map.get('desc') is not None else ''}"
            f"_{entity_map['suffix']}"
            f".{entity_map['ext']}"
        )
        fpath.replace(fpath.parent / str(fpath.name).replace(fpath.name, out_fname))


def rename_inputs(input_dir: Path) -> None:
    """Helper to rename inputs."""
    print("Renaming input files...")
    input_regex = {
        "CIVETNMT": r"\w+_(?P<suffix>\w+)_\w+_(?P<hemi>\w+).(?P<ext>\w+\.gii)",
        "D99": r"\w+_\w+_(?P<suffix>\w+)_\w+_(?P<hemi>\w+).(?P<ext>\w+\.gii)",
        "MEBRAINS": r"(?P<hemi>\w+).\w+.(?P<suffix>\w+).(?P<ext>\w+\.gii)",
        "NMT2Sym": r"\w+_v2\.0_(?P<desc>\w+)_(?P<hemi>\w+)\.(?P<suffix>\w+)_\w+.(?P<ext>\w+\.gii)",
        "S1200": r"\w+.(?P<hemi>\w+).(?P<suffix>\w+).\w+.(?P<ext>\w+\.gii)",
        "Yerkes19": r"\w+.(?P<hemi>\w+).(?P<suffix>\w+(?:_\w+)*).\w+.(?P<ext>\w+\.gii)",
    }
    for fpath in input_dir.rglob("**/*.gii"):
        if not fpath.name.endswith((".surf.gii", "rsl.gii")):
            continue
        rename_surf(fpath=fpath, regex=input_regex)


def rename_outputs(input_dir: Path):
    """Helper to rename outputs"""
    print("Renaming output files...")
    for fpath in input_dir.rglob("**/*.gii"):
        output_regex = r"(?P<hemi>\w+).\w+_(?P<suffix>\w+)_\w+_\w+.(?P<ext>\w+\.gii)"
        if not fpath.name.endswith((".surf.gii")):
            continue
        if "S1200" in str(fpath):
            output_regex = (
                r"(?P<hemi>\w+)\.[\w-]+\.(?P<suffix>\w+)\.(?:\w+\.){2}(?P<ext>\w+\.gii)"
            )
        rename_surf(fpath=fpath, regex=output_regex)


def main() -> None:
    rename_inputs(Path("share/Inputs"))
    rename_outputs(Path("share/Outputs"))


if __name__ == "__main__":
    main()
