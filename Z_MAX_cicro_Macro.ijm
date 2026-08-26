// Script: Batch generate maximum-intensity Z projections from LVCC .lif files.
// Purpose: find the final Merged_Lng_LVCC series, enhance channels 1 and 5,
//          compute a Z-axis maximum projection, and save a *_ZMAX.tif image.
// Inputs:  baseDir 下按 “A轮/P4-rep1-A/” 这类结构存放的 .lif 文件。
// Output:  outputDir 中每个输入文件对应的 *_ZMAX.tif。
// Note:    该宏会同时打开原始图和投影图，保存后会关闭二者释放内存。

// 初始化 Bio-Formats 宏扩展组件
run("Bio-Formats Macro Extensions");

// 【根目录与输出目录】
baseDir = "D:\\01.analysis\\11.test\\"; // 根目录
outputDir = "D:\\01.analysis\\11.test_result\\"; // 统一输出的目录

// 定义 A 到 G 轮的字母
rounds = newArray("A", "B");
// 定义每轮下的 2 组数据后缀
reps = newArray("rep1", "rep2");

// 开启批量模式
setBatchMode(true);

// === 第一层循环：遍历 A 到 G ===
for (r = 0; r < rounds.length; r++) {
    currentLetter = rounds[r]; // 例如 "A", "B"
    
    // === 第二层循环：遍历 rep1 和 rep2 ===
    for (p = 0; p < reps.length; p++) {
        currentRep = reps[p]; // 例如 "rep1", "rep2"
        
        // 严格按照真实路径拼接：
        // 第一层是 currentLetter + "轮" -> 例如 "B轮"
        // 第二层是 "P4-" + currentRep + "-" + currentLetter -> 例如 "P4-rep2-B"
        inputDir = baseDir + currentLetter + "轮\\" + "P4-" + currentRep + "-" + currentLetter + "\\";
        
        // 检查文件夹是否存在
        if (!File.exists(inputDir)) {
            print("[跳过目录] 文件夹不存在: " + inputDir);
            continue;
        }
        
        print("========================================");
        print("正在扫描目录: " + inputDir);
        print("========================================");
        
        // 获取当前子目录下的所有文件
        fileList = getFileList(inputDir);
        
        // === 第三层循环：遍历当前目录下的 .lif 文件 ===
        for (f = 0; f < fileList.length; f++) {
            fileName = fileList[f];
            
            // 严格匹配 .lif 后缀的文件
            if (endsWith(toLowerCase(fileName), ".lif")) {
                filePath = inputDir + fileName;
                print("  -> 发现文件: " + fileName);
                
                // 读取元数据
                Ext.setId(filePath);
                Ext.getSeriesCount(seriesCount);
                
                if (seriesCount == 0) {
                    print("    [警告] 该文件内未检测到任何 Series，跳过。");
                    continue;
                }
                
                // 严格指向最后一个 Series
                lastSeriesIndex = seriesCount - 1;
                Ext.setSeries(lastSeriesIndex);
                Ext.getSeriesName(seriesName);
                
                print("    最后一个 Series 索引: " + lastSeriesIndex + " | 原始名称: " + seriesName);
                
                // 转换成小写进行安全匹配
                lowerSeriesName = toLowerCase(seriesName);
                
                if (indexOf(lowerSeriesName, "merged_lng_lvcc") >= 0) {
                    print("    [匹配成功] 正在提取并处理...");
                    
                    // 导入最后一个 Series
                    bfOptions = "open=[" + filePath + "] "
                              + "color_mode=Default "
                              + "view=Hyperstack "
                              + "stack_order=XYCZT "
                              + "series_" + (lastSeriesIndex + 1);
                    
                    run("Bio-Formats Importer", bfOptions);
                    
                    // 备份原图标题
                    originalImage = getTitle();
                    
                    // ---- 【步骤1：调整通道1和5的对比度】 ----
                    Stack.setChannel(1);
                    run("Enhance Contrast", "saturated=0.35");
                    
                    Stack.setChannel(5);
                    run("Enhance Contrast", "saturated=0.35");
                    
                    // ---- 【步骤2：Z轴最大光强投影】 ----
                    run("Z Project...", "projection=[Max Intensity]");
                    
                    // ---- 【步骤3：构造文件名并保存】 ----
                    baseName = replace(fileName, ".lif", "");
                    
                    // 加上当前轮次和组名作为前缀，防止同名冲突
                    // 保存格式示例：B轮_P4-rep2-B_P4-rep2-B-1_ZMAX.tif
                    //prefix = currentLetter + "轮_P4-" + currentRep + "-" + currentLetter + "_";
                    savePath = outputDir  + baseName + "_ZMAX.tif";
                    
                    // 保存投影后的图像
                    saveAs("Tiff", savePath);
                    print("    [已保存] -> " + savePath);
                    
                    // ---- 【步骤4：清理内存】 ----
                    close(); // 关闭投影图
                    selectImage(originalImage);
                    close(); // 关闭原图
                    
                } else {
                    print("    [跳过] 名称不包含 'Merged_Lng_LVCC'。");
                }
            }
        } // 第三层循环结束
    } // 第二层循环结束
} // 第一层循环结束

// 关闭批量模式，刷新 Fiji 界面
setBatchMode(false);
print("========================================");
print("--- 所有轮次及组别的 .lif 文件全部批处理完成！ ---");
print("========================================");
