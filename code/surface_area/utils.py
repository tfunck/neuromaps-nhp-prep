from pathlib import Path
from typing import Iterable
import nibabel as nib


def find_surface_files(
    input_dir: Path, patterns: Iterable[str] | None = None
) -> list[Path]:
    """
    Find surface files matching the specified patterns.
    """
    if patterns is None:
        patterns = ["*mid*.surf.gii", "*mid*.rsl.gii"]

    input_dir = input_dir.absolute()

    input_files = []
    for pattern in patterns:
        input_files.extend(input_dir.rglob(f"**/{pattern}"))

    # Remove duplicates
    return list(set(input_files))


def detect_density(n_vertices: int) -> str:
    density = str(round(n_vertices / 1000)) + "K"
    return density


def detect_hemi(structure_name: str, filename: str) -> str:
    struct_map = {"CortexLeft": "L", "CortexRight": "R"}

    if structure_name in struct_map:
        return struct_map[structure_name]

    # fallback to filename patterns
    lower = filename.lower()

    # Check for BIDS-style hemi patterns first
    if "hemi-l" in lower:
        return "L"
    if "hemi-r" in lower:
        return "R"

    # Check for other common patterns
    if "lh" in lower or "left" in lower or ".l." in lower:
        return "L"
    if "rh" in lower or "right" in lower or ".r." in lower:
        return "R"

    # If nothing found, raise exception
    raise Exception(f"Could not detect hemisphere. {structure_name}, {filename}")


def detect_space(path: Path) -> str:
    candidates = ["D99", "MEBRAINS", "Yerkes19", "CIVETNMT", "NMT2"]
    for c in candidates:
        if c.lower() in path.lower():
            return c
    raise Exception(f"Could not detect 'space' from filename/path: {path}")


def get_map_info(input_gifti, density=True, hemi=True, space=True):
    """
    Extract relevant information from the output metric.
    """
    surface = nib.load(str(input_gifti))
    map_info = {}

    if density:
        map_info["Density"] = detect_density(surface.darrays[0].data.shape[0])

    if hemi:
        map_info["Hemi"] = detect_hemi(
            surface.meta.get("AnatomicalStructurePrimary", ""), input_gifti.name
        )

    if space:
        map_info["Space"] = detect_space(str(input_gifti))

    return map_info
