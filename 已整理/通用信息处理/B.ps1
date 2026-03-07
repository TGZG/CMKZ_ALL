# 获取脚本所在目录
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 递归获取所有md文件，并按文件名排序
$mdFiles = Get-ChildItem -Path $scriptDir -Recurse -File -Filter "*.md" | 
           Where-Object { $_.FullName -ne (Join-Path $scriptDir "合并.md") } |
           Sort-Object Name

if ($mdFiles.Count -eq 0) {
    Write-Host "未找到任何md文件！"
    exit 1
}

# 构建合并内容
$mergedContent = @()

foreach ($file in $mdFiles) {
    # 添加文件名
    $mergedContent += $file.Name
    
    # 添加文件内容
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    if ($content) {
        $mergedContent += $content.TrimEnd()
    }
    
    # 添加分隔符
    $mergedContent += "【文件变更】"
}

# 移除最后一个分隔符
if ($mergedContent.Count -gt 0) {
    $mergedContent = $mergedContent[0..($mergedContent.Count - 2)]
}

# 输出到合并.md
$outputPath = Join-Path -Path $scriptDir -ChildPath "合并.md"
$mergedContent -join "`n" | Out-File -FilePath $outputPath -Encoding UTF8 -NoNewline

Write-Host "已合并 $($mdFiles.Count) 个文件到: 合并.md"