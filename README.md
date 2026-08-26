# split_Fiji-imageJ

Fiji/ImageJ and Python helper scripts for splitting, locating, stitching, and
merging microscopy image tiles.

## Script Overview

| File | Purpose |
| --- | --- |
| `01.LVCC_Macro.ijm.ijm.ijm` | Batch scan P4 `.lif` files, extract the final `Merged_Lng_LVCC` series, enhance channels 1 and 5, and save processed TIFF stacks. |
| `01.LVCCmerge_Macro.ijm.ijm.ijm` | Batch scan e16.5 `.lif` files across A-J rounds, extract merged LVCC series, enhance channels 1 and 5, and save processed TIFF stacks. |
| `Z_MAX_cicro_Macro.ijm` | Extract merged LVCC series and save maximum-intensity Z projections. |
| `03.stitch_dapi_circle_Macro.ijm` | Run Fiji Grid/Collection stitching for DAPI tiles using `TileConfiguration.txt`. |
| `Untitled-1.py` | Match DAPI tiles to a full reference image and write Fiji `TileConfiguration.txt`. |
| `step1.ipynb` | Early notebook version of the tile-to-reference template matching workflow. |
| `step1 copy.ipynb` | Basic template matching workflow that writes `TileConfiguration.txt`. |
| `test.ipynb` | Template matching test notebook with confidence threshold checks. |
| `02.dapi_loci_test.ipynb` | Advanced DAPI tile localization with coarse matching, refined matching, and row-position priors. |
| `02.dapi_loci_test2.ipynb` | Empty placeholder notebook for future DAPI localization tests. |
| `02.merge_dapi.ipynb` | Full DAPI tile coordinate workflow using coarse-to-fine matching. |
| `rename_tile.ipynb` | Rename TIFF tiles inside channel folders to `tile_01.tif`, `tile_02.tif`, etc. |
| `copy_Tile.ipynb` | Copy DAPI `TileConfiguration.txt` into other channel folders for consistent stitching. |
| `merge_channel.ipynb` | Stack fused single-channel TIFFs into one multi-channel TIFF. |
| `03.channel.ipynb` | Merge fused channels into an OME-TIFF with channel color metadata. |

## Typical Workflow

1. Use the Fiji macros to extract the target `.lif` series and optionally create
   Z projections.
2. Use a DAPI template-matching notebook or `Untitled-1.py` to generate
   `TileConfiguration.txt`.
3. Copy the DAPI tile configuration into the other channel folders.
4. Stitch each channel in Fiji.
5. Merge the fused channels into a multi-channel TIFF or OME-TIFF.

Before running any script, update the hard-coded paths so they match the local
image folder layout.
