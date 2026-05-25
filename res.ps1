# Restore image from split files
$partDir = "D:\PeronalAgent"
$outputPath = "$partDir\restored_image.png"

# 按顺序读取所有分片文件
Write-Host "Reading split files in order..."
$base64Content = ""

for ($i = 1; $i -le 20; $i++) {
    $fileName = "image_part_$i.txt"
    $filePath = Join-Path $partDir $fileName
    
    if (Test-Path $filePath) {
        $chunk = Get-Content -Path $filePath -Raw
        $base64Content = $base64Content + $chunk
        Write-Host "  Added: $fileName (Length: $($chunk.Length))"
    }
}

Write-Host "`nTotal base64 length: $($base64Content.Length)"

# 清理可能存在的换行符和空白字符
$base64Content = $base64Content -replace '\s+', ''

Write-Host "Cleaned base64 length: $($base64Content.Length)"

# 验证 base64 开头和结尾
Write-Host "`nBase64 header: $($base64Content.Substring(0, [Math]::Min(20, $base64Content.Length)))"
Write-Host "Base64 footer: $($base64Content.Substring([Math]::Max(0, $base64Content.Length - 20)))"

# 解码 base64 为字节数组
Write-Host "`nDecoding base64 to image..."
try {
    $imageBytes = [Convert]::FromBase64String($base64Content)
    Write-Host "Decoded $($imageBytes.Length) bytes"
    
    # 写入图片文件
    [System.IO.File]::WriteAllBytes($outputPath, $imageBytes)
    
    $fileSize = (Get-Item $outputPath).Length
    Write-Host "`nSuccess! Image restored to: $outputPath"
    Write-Host "File size: $fileSize bytes"
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
