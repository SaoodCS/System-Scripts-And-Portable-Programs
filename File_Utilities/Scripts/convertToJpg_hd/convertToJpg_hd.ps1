$MagickPath = '.\File_Utilities\Programs\ImageMagick\magick.exe'
$SourceFolder = 'D:\AS DNG' #TODO: set the folder containing the original images
$DestinationFolder = 'C:\Users\saood\Desktop\MagickTrying\' #TODO: set the folder you want the converted images in
$Extensions = @('*.png', '*.jpg', '*.jpeg', '*.dng', '*.tif', '*.tiff', '*.bmp', '*.gif', '*.heic', '*.webp', '*.cr2', '*.nef', '*.arw', '*.orf', '*.rw2')
$ImageFiles = Get-ChildItem -Path (Join-Path $SourceFolder '*') -Include $Extensions -File -Recurse

Write-Host "Found $($ImageFiles.Count) file(s). Converting to JPG → $DestinationFolder`n"
$failures = 0
foreach ($File in $ImageFiles) {
    $outPath = Join-Path $DestinationFolder ($File.BaseName + '.jpg')
    $args = @(
        $File.FullName,
        '-auto-orient',
        '-quality', '100',
        $outPath
    )
    Write-Host "→ $($File.FullName)  ->  $outPath"
    & $MagickPath @args 2>$null
    # Use PowerShell to set the date created / modified / accessed to be the same as the original
    if (Test-Path $outPath) {
        $outFile = Get-Item $outPath
        $outFile.CreationTime = $File.CreationTime
        $outFile.LastWriteTime = $File.LastWriteTime
        $outFile.LastAccessTime = $File.LastAccessTime
    }
}
if ($failures -gt 0) {
    Write-Warning "`nCompleted with $failures failure(s). Check messages above."
}
else {
    Write-Host "✅ Conversion completed. Files saved to: $DestinationFolder"
}