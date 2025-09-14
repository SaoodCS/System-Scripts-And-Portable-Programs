$ExifToolPath = '.\Metadata_Editor\Programs\ExifTool\exiftool.exe'
$IrfanViewPath = '.\Metadata_Editor\Programs\IrfanView\i_view64.exe'
$SourceFolder = 'D:\AS DNG'   # TODO: set folder with the files you want to convert
$DestinationFolder = 'C:\Users\saood\Desktop\IrfanViewTrying' # TODO: set folder where you want to convert the files to
$Output_JPG_Quality = 100
$OriginalFormats = @(
  '.jpg', '.jpeg', '.png', '.tif', '.tiff', '.bmp', '.gif',
  '.webp', '.heic', '.heif', '.arw', '.cr2', '.nef', '.orf', '.rw2', '.dng'
)

# Convert all files to jpeg highest quality and then update the exifdata with that from the original
Get-ChildItem -Path $SourceFolder -File | Where-Object { 
    $OriginalFormats -contains $_.Extension.ToLower() 
} | ForEach-Object {
    $InputFile  = $_.FullName
    $BaseName   = $_.BaseName
    $OutputFile = Join-Path $DestinationFolder ($BaseName + '.jpg')
    Write-Host "Converting $InputFile -> $OutputFile"
    Start-Process -FilePath $IrfanViewPath -ArgumentList "`"$InputFile`" /convert=`"$OutputFile`" /jpgq=100" -NoNewWindow -Wait
        & $ExifToolPath `
        -all= `
        -tagsfromfile "$InputFile" `
        -all:all `
        -overwrite_original `
        -m `
        "$OutputFile" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "ExifTool failed for: $OutputFile"
    } else {
        Write-Host "Metadata copied to $OutputFile"
    }
}

# TODO: then, set all the date tags of the converted files to the datetaken tag by running the "set-all-to-datetaken-tag.ps1" on the destination folder