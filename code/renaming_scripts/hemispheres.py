import argparse
import subprocess

def main():
    parser = argparse.ArgumentParser(
        description="Output the hemisphere of a GIFTI (.gii) file using wb_command."
    )
    parser.add_argument(
        "gii_file",
        help="Path to the GIFTI (.gii) file"
    )
    args = parser.parse_args()

    try:
        # Run wb_command -file-information
        result = subprocess.run(
            ["wb_command", "-file-information", args.gii_file],
            capture_output=True,
            text=True,
            check=True
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"wb_command failed: {e.stderr}")

    # Parse the Structure line
    hemi_label = None
    for line in result.stdout.splitlines():
        if line.startswith("Structure:"):
            structure = line.split(":")[1].strip().lower()
            if "left" in structure:
                hemi_label = "hemi-L"
            elif "right" in structure:
                hemi_label = "hemi-R"
            break

    if not hemi_label:
        raise ValueError("Could not determine hemisphere from wb_command output.")

    print(hemi_label)

if __name__ == "__main__":
    main()
