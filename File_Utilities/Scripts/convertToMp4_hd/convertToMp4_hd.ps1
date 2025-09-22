$FFmpegPath = '.\File_Utilities\Programs\FFmpeg\bin\ffmpeg.exe'
$ExifToolPath = '.\File_Utilities\Programs\ExifTool\exiftool.exe'
$SourceFolder = 'C:\Users\saood\Desktop\VideoTry' #TODO: set the folder containing the original videos
$DestinationFolder = 'C:\Users\saood\Desktop\Output' #TODO: set the folder you want the converted videos

$Extensions = @('*.mp4', '*.mov', '*.avi', '*.mkv', '*.wmv', '*.flv', '*.mpg', '*.mpeg', '*.m4v', '*.webm', '*.ts')
$VideoFiles = Get-ChildItem -Path (Join-Path $SourceFolder '*') -Include $Extensions -File -Recurse
Write-Host "Found $($VideoFiles.Count) file(s). Converting to MP4 -> $DestinationFolder`n"

foreach ($file in $VideoFiles) {
    $outputFile = Join-Path $DestinationFolder ($file.BaseName + '.mp4')

    Write-Host "Converting $($file.FullName) to MP4"
    & $FFmpegPath -y -v error -i $file.FullName -c copy -movflags +faststart $outputFile
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to convert $($file.Name)" -ForegroundColor Red
        continue
    }
    & $ExifToolPath -m -q -q -TagsFromFile $file.FullName '-all:all>all:all' -overwrite_original -P $outputFile
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to copy metadata for $(Split-Path -Leaf $outputFile)" -ForegroundColor Yellow
        continue
    }
    Write-Host 'Conversion completed'
}
