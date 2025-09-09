# ---- Configuration (your paths) ----
$ExifToolPath = '.\Media_Metadata_Editor\Programs\ExifTool\exiftool.exe'
$RootFolder   = 'C:\Users\saood\Desktop\Nikkah Photos\Nikkah Photos DNG' #TODO: set this to the folder that contains the images

$Extensions = @('jpg', 'jpeg', 'dng', 'cr2', 'nef', 'arw', 'orf', 'raf', 'heic', 'heif', 'mp4', 'mov')
$extArgs = @()
foreach ($ext in $Extensions) { $extArgs += @('-ext', $ext) }
# Source timestamp priority (first one that exists wins), using ExifTool's redirection with ${a;b;c} to try each in order.
$SRC = '${DateTimeOriginal\#;CreateDate\#;QuickTime:CreateDate\#;QuickTime:MediaCreateDate\#;QuickTime:TrackCreateDate\#;XMP:CreateDate\#}'
$tagArgs = @(
    "-AllDates<$SRC",
    "-EXIF:DateTimeOriginal<$SRC",
    "-XMP:CreateDate<$SRC",
    "-XMP:ModifyDate<$SRC",
    "-XMP:MetadataDate<$SRC",
    "-IPTC:DateCreated<$SRC",
    "-IPTC:TimeCreated<$SRC",
    "-CreateDate<$SRC",
    "-ModifyDate<$SRC",
    "-TrackCreateDate<$SRC",
    "-TrackModifyDate<$SRC",
    "-MediaCreateDate<$SRC",
    "-MediaModifyDate<$SRC",
    "-Keys:CreationDate<$SRC",
    "-QuickTime:ContentCreateDate<$SRC",
    "-QuickTime:CreationDate<$SRC",
    "-QuickTime:DateTimeOriginal<$SRC",
    '-EXIF:OffsetTime<OffsetTime',
    '-EXIF:OffsetTimeOriginal<OffsetTimeOriginal',
    '-EXIF:OffsetTimeDigitized<OffsetTimeDigitized',
    "-FileCreateDate<$SRC",
    "-FileModifyDate<$SRC"
)
$runArgs = @(
    '-r', # Recurse into subfolders
    '-overwrite_original', # Do not keep _original backups
    '-m', # Ignore minor warnings
    '-progress' # Show progress
) + $extArgs + $tagArgs + @($RootFolder)
# Execute
Write-Host "Running ExifTool to copy 'Date Taken' into all date tags under:`n$RootFolder`n" -ForegroundColor Cyan
& $ExifToolPath @runArgs
Write-Host "`nDone. Check the output above for the number of files updated." -ForegroundColor Green
