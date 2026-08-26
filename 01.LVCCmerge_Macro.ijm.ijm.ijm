// Script: Batch extract merged LVCC image stacks from e16.5 Leica .lif files.
// Purpose: scan A-J rounds and rep1/rep2 folders, select the final series if it
//          is named like Merged_Lng_LVCC, enhance channels 1 and 5, and save it.
// Inputs:  baseDir 下按 “A轮/e16.5-rep1-A/e16.5-rep1-4-A/” 结构存放的 .lif 文件。
// Output:  outputDir 中每个样本对应的 *_processed.tif 文件。
// Note:    该宏不做 Z 投影，保存的是调整对比度后的原始 hyperstack。

// 初始化 Bio-Formats 宏扩展组件
run("Bio-Formats Macro Extensions");

// 【根目录与输出目录】
baseDir = "G:\\e16.5\\"; // 根目录
outputDir = "G:\\e16.5_result\\"; // 统一输出的目录，可根据需要自行修改

// 自动创建输出文件夹（如果不存在的话）
if (!File.exists(outputDir)) {
    File.makeDirectory(outputDir);
}

// 定义 A 到 J 轮的字母
rounds = newArray("A", "B", "C", "D", "E", "F", "G", "H", "I", "J");
// 定义每轮下的 2 组数据前缀
reps = newArray("rep1", "rep2");

// 开启批量模式
setBatchMode(true);

// === 第一层循环：遍历 A 到 J 轮 ===
for (r = 0; r < rounds.length; r++) {
    currentLetter = rounds[r]; // 例如 "A", "B"..."J"    
    
    // === 第二层循环：遍历 rep1 和 rep2 ===
    for (p = 0; p < reps.length; p++) {
        currentRep = reps[p]; // 例如 "rep1", "rep2"
        
        // 严格按照你提供的三层真实路径拼接：
        // 第一层：G:\e16.5\A轮\
        // 第二层：e16.5-rep1-A\
        // 第三层：e16.5-rep1-4-A\
        midFolder = "e16.5-" + currentRep + "-" + currentLetter;
        leafFolder = "e16.5-" + currentRep + "-4-" + currentLetter;
        
        inputDir = baseDir + currentLetter + "轮\\" + midFolder + "\\" + leafFolder + "\\";
        
        // 检查文件夹是否存在，不存在则跳过
        if (!File.exists(inputDir)) {
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
                    
                    // ---- 【步骤1：调整通道1和5的对比度】 ----
                    Stack.setChannel(1);
                    run("Enhance Contrast", "saturated=0.35");
                    
                    Stack.setChannel(5);
                    run("Enhance Contrast", "saturated=0.35");
                    
                    // ---- 【步骤2：构造文件名并保存】 ----
                    baseName = replace(fileName, ".lif", "");
                    
                    // 加上前缀防止跨文件夹同名覆盖
                    prefix = currentLetter + "轮_" + leafFolder + "_";
                    savePath = outputDir + prefix + baseName + "_processed.tif";
                    
                    // 直接保存调整对比度后的原图（不进行Z轴投影）
                    saveAs("Tiff", savePath);
                    print("    [已保存] -> " + savePath);
                    
                    // ---- 【步骤3：清理内存】 ----
                    close(); // 关闭当前图像
                    
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
print("--- A到J轮所有指定目录下的 .lif 文件全部批处理完成！ ---");
print("========================================");
