$MagickPath = '.\File_Utilities\Programs\ImageMagick\magick.exe'
$ExifToolPath = '.\File_Utilities\Programs\ExifTool\exiftool.exe'
$SourceFolder = 'C:\Users\saood\Desktop\PhotosTry' #TODO: set the folder containing the original images
$DestinationFolder = 'C:\Users\saood\Desktop\Output' #TODO: set the folder you want the converted images in

$Extensions = @('*.png', '*.jpg', '*.jpeg', '*.dng', '*.tif', '*.tiff', '*.bmp', '*.gif', '*.heic', '*.webp', '*.cr2', '*.nef', '*.arw', '*.orf', '*.rw2')
$ImageFiles = Get-ChildItem -Path (Join-Path $SourceFolder '*') -Include $Extensions -File -Recurse
Write-Host "Found $($ImageFiles.Count) file(s). Converting to JPG → $DestinationFolder`n"

foreach ($file in $ImageFiles) {
    $outputFile = Join-Path $DestinationFolder ($file.BaseName + '.jpg')

    Write-Host "Converting $($file.FullName) to JPG"
    & $MagickPath $file.FullName -auto-orient -quality 100 $outputFile 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to convert $($file.Name)" -ForegroundColor Red
        continue
    }
    
    & $ExifToolPath -m -q -q -TagsFromFile $file.FullName '-all:all>all:all' -FileModifyDate -FileCreateDate -FileAccessDate -overwrite_original -P $outputFile
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to copy metadata for $(Split-Path -Leaf $outputFile)" -ForegroundColor Yellow
        continue
    }
    Write-Host 'Conversion completed'
}