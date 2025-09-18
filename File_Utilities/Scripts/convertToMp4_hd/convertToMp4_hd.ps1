$FFmpegPath = '.\File_Utilities\Programs\FFmpeg\bin\ffmpeg.exe'
$SourceFolder = 'C:\Users\saood\Desktop\MOVs' #TODO: set the folder containing the original videos
$DestinationFolder = 'C:\Users\saood\Desktop\MOVs' #TODO: set the folder you want the converted videos

# Get all .mov files in source folder
$movFiles = Get-ChildItem -Path $SourceFolder -Filter *.mov

foreach ($file in $movFiles) {
    $outputFile = Join-Path $DestinationFolder ($file.BaseName + '.mp4')
    Write-Host "Converting: $($file.FullName) -> $outputFile"
    & $FFmpegPath -i $file.FullName -c copy $outputFile
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully converted $($file.Name)"
    }
    else {
        Write-Host "Failed to convert $($file.Name)" -ForegroundColor Red
    }
}
