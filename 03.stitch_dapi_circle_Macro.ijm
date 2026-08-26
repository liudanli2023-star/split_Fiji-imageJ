// Script: Stitch DAPI tiles for P4 rep2 A-J with Fiji.
// Purpose: run Fiji's Grid/Collection stitching plugin on each round, using an
//          existing TileConfiguration.txt file as the tile position layout.
// Inputs:  rootDir 下每个 “轮次/样本名/DAPI/” 文件夹中的 tile 图像和 TileConfiguration.txt。
// Output:  每个 DAPI 文件夹中的 DAPI-Fused.tif。
// Note:    运行前确认 Grid/Collection stitching 插件已安装，且坐标文件名固定为 TileConfiguration.txt。

// Fiji menu reference:
// Plugins > Stitching > Grid/Collection stitching
// Type: Positions from file
// Order: Defined by TileConfiguration
// Compute overlap: unchecked

rootDir = "D:\\LDL_data\\01.analysis\\02.merge\\P4\\";
repName = "rep2";
channelName = "DAPI";
letters = newArray("A", "B", "C", "D", "E", "F", "G", "H", "I", "J");

setBatchMode(false);

for (i = 0; i < letters.length; i++) {
    letter = letters[i];
    sampleName = "P4-" + repName + "-" + letter;
    tileDir = rootDir + letter + "\\" + sampleName + "\\" + channelName + "\\";
    layoutFile = "TileConfiguration.txt";
    layoutPath = tileDir + layoutFile;
    outputPath = tileDir + channelName + "-Fused.tif";

    print("--------------------------------------------------");
    print("Stitching: " + sampleName + " " + channelName);
    print("Directory: " + tileDir);
    print("Layout   : " + layoutPath);
    print("Output   : " + outputPath);

    if (!File.exists(tileDir)) {
        print("  [skip] Tile directory not found.");
        continue;
    }

    if (!File.exists(layoutPath)) {
        print("  [skip] TileConfiguration.txt not found.");
        continue;
    }

    options = "type=[Positions from file] "
            + "order=[Defined by TileConfiguration] "
            + "directory=[" + tileDir + "] "
            + "layout_file=" + layoutFile + " "
            + "fusion_method=[Linear Blending] "
            + "regression_threshold=0.30 "
            + "max/avg_displacement_threshold=2.50 "
            + "absolute_displacement_threshold=3.50 "
            + "computation_parameters=[Save memory (but be slower)] "
            + "image_output=[Fuse and display]";

    // Do not add "compute_overlap" to the options string.
    run("Grid/Collection stitching", options);

    if (isOpen("Fused")) {
        selectWindow("Fused");
    } else {
        selectImage(nImages);
    }

    rename(channelName + "-Fused");
    saveAs("Tiff", outputPath);
    print("  [saved] " + outputPath);

    close();
}

print("--------------------------------------------------");
print("--- Done: DAPI stitching for P4 rep2 A-J. ---");
