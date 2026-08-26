"""Generate Fiji/ImageJ TileConfiguration coordinates by template matching.

The script matches each small DAPI tile against a full reference image, records
the best x/y location, and writes a TileConfiguration.txt file that can be used
by Fiji's Grid/Collection stitching plugin.

Before running, install the image-processing dependencies from a terminal:
    python -m pip install opencv-python tifffile numpy
"""




import os
import cv2
import tifffile as tiff
import numpy as np

# ==========================
# 路径设置
# ==========================

FULL_IMAGE = r"D:\01.analysis\11.test\DAPI\fullbrain.tif"

TILE_DIR = r"D:\01.analysis\11.test\DAPI\tiles"

OUTPUT_FILE = r"D:\01.analysis\11.test\DAPI\TileConfiguration.txt"

# ==========================
# 读取完整脑片
# ==========================

print("Loading full brain...")

full = tiff.imread(FULL_IMAGE)

if full.ndim > 2:
    full = full[0]

full = cv2.normalize(
    full,
    None,
    0,
    255,
    cv2.NORM_MINMAX
).astype(np.uint8)

print("Full brain size:", full.shape)

# ==========================
# Tile列表
# ==========================

tile_files = sorted([
    f for f in os.listdir(TILE_DIR)
    if f.endswith(".tif")
])

results = []

# ==========================
# 搜索Tile位置
# ==========================

for tile_name in tile_files:

    print("\nSearching:", tile_name)

    tile_path = os.path.join(
        TILE_DIR,
        tile_name
    )

    tile = tiff.imread(tile_path)

    if tile.ndim > 2:
        tile = tile[0]

    tile = cv2.normalize(
        tile,
        None,
        0,
        255,
        cv2.NORM_MINMAX
    ).astype(np.uint8)

    print(
        "Tile size:",
        tile.shape
    )

    result = cv2.matchTemplate(
        full,
        tile,
        cv2.TM_CCOEFF_NORMED
    )

    _, max_val, _, max_loc = cv2.minMaxLoc(result)

    x, y = max_loc

    print(
        f"Position = ({x},{y}) "
        f"Score={max_val:.3f}"
    )

    results.append(
        (
            tile_name,
            x,
            y
        )
    )

# ==========================
# 输出Fiji坐标文件
# ==========================

with open(
    OUTPUT_FILE,
    "w"
) as f:

    f.write("dim = 2\n\n")

    for tile_name,x,y in results:

        f.write(
            f"{tile_name}; ; ({x},{y})\n"
        )

print("\nSaved:")
print(OUTPUT_FILE)
