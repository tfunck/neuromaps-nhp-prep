# neuromaps-nhp-prep

- `code` - contains scripts and notebooks used for preparing data
- `share` - contains data to be used for processing and sharing

> [!Note]
> Output directories are named `<target>_<source>`

## Tools

<details>
<summary><b>Surface Area Computation (<code>code/surface_area.py</code>)</b></summary>

Computes vertex-wise surface area metrics for brain surface meshes using Connectome Workbench.

**Usage:**
```bash
# Process all mid-thickness surfaces in default directory
python code/surface_area.py

# Use custom directory
python code/surface_area.py -i path/to/surfaces

# Validate outputs and show verbose information  
python code/surface_area.py -i ../share/Inputs --validate -v

# See what files would be processed
python code/surface_area.py --dry-run
```

**Input:** `.surf.gii` files containing "mid" or "midthickness" in filename  
**Output:** `.shape.gii` files with vertex area metrics in the same directory

</details>