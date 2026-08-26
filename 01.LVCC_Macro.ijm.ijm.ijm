// Script: Batch extract Merged_Lng_LVCC series from Leica .lif files.
// Purpose: traverse selected P4 rounds/replicates, open the last Bio-Formats
//          series when its name contains Merged_Lng_LVCC, enhance channels 1
//          and 5, and save the processed hyperstack as TIFF.
// Inputs:  baseDir 下按 “A轮/P4-rep1-1-A/” 这类结构存放的 .lif 文件。
// Output:  outputDir 中带轮次和样本前缀的 *_processed.tif 文件。
// Note:    修改 rounds/reps/nums/baseDir/outputDir 后再运行。

// 初始化 Bio-Formats 宏扩展组件
run("Bio-Formats Macro Extensions");

// 【根目录与输出目录】
baseDir = "D:\\01.analysis\\11.test\\"; // 根目录
outputDir = "D:\\01.analysis\\11.test_result\\"; // 统一输出的目录

// 定义 A 到 G 轮的字母 (你可以根据需要添加 "C", "D", "E", "F", "G")
rounds = newArray("A", "B", "D");
// 定义每轮下的 2 组数据前缀
reps = newArray("rep1", "rep2");
// 定义子文件夹中的数字范围 (用于拼接出 rep1-4 或 rep2-4 等)
nums = newArray("1", "2", "3", "4");

// 开启批量模式
setBatchMode(true);

// === 第一层循环：遍历 A 到 G ===
for (r = 0; r < rounds.length; r++) {
    currentLetter = rounds[r]; // 例如 "A", "B", "D"    
    
    // === 第二层循环：遍历 rep1 和 rep2 ===
    for (p = 0; p < reps.length; p++) {
        currentRep = reps[p]; // 例如 "rep1", "rep2"
        
        // === 第三层循环：遍历数字 1 到 4 ===
        for (n = 0; n < nums.length; n++) {
            currentNum = nums[n]; // 例如 "1", "2"..."4"
            
            // 严格按照要求的指定文件名拼接路径：
            // 第一层是 currentLetter + "轮" -> 例如 "A轮"
            // 第二层是 "P4-" + currentRep + "-" + currentNum + "-" + currentLetter -> 例如 "P4-rep1-4-A"
            folderName = "P4-" + currentRep + "-" + currentNum + "-" + currentLetter;
            inputDir = baseDir + currentLetter + "轮\\" + folderName + "\\";
            
            // 检查文件夹是否存在
            if (!File.exists(inputDir)) {
                // 如果不存在，也可以尝试不带数字的旧路径备用，这里默认严格匹配新路径
                continue; 
            }
            
            print("========================================");
            print("正在扫描目录: " + inputDir);
            print("========================================");
            
            // 获取当前子目录下的所有文件
            fileList = getFileList(inputDir);
            
            // === 第四层循环：遍历当前目录下的 .lif 文件 ===
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
                        
                        // ---- 【步骤2：构造文件名并保存】 ----
                        baseName = replace(fileName, ".lif", "");
                        
                        // 加上前缀以区分不同文件夹下可能同名的lif文件
                        prefix = currentLetter + "轮_" + folderName + "_";
                        savePath = outputDir + prefix + baseName + "_processed.tif";
                        
                        // 直接保存调整对比度后的原图（不再进行Z轴最大光强投影）
                        saveAs("Tiff", savePath);
                        print("    [已保存] -> " + savePath);
                        
                        // ---- 【步骤3：清理内存】 ----
                        close(); // 关闭当前图像
                        
                    } else {
                        print("    [跳过] 名称不包含 'Merged_Lng_LVCC'。");
                    }
                }
            } // 第四层循环结束
        } // 第三层循环结束
    } // 第二层循环结束
} // 第一层循环结束

// 关闭批量模式，刷新 Fiji 界面
setBatchMode(false);
print("========================================");
print("--- 所有轮次及组别的 .lif 文件全部批处理完成！ ---");
print("========================================");
