$ExifToolPath = '.\File_Utilities\Programs\ExifTool\exiftool.exe'
$SourceFolder = 'C:\Users\saood\Desktop\Nikkah JPG' #TODO: set this to the folder that contains the files
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
    "-QuickTime:CreateDate<$SRC",
    "-QuickTime:ContentCreateDate<$SRC",
    "-QuickTime:CreationDate<$SRC",
    "-QuickTime:DateTimeOriginal<$SRC",
    "-QuickTime:MediaCreateDate<$SRC",
    "-QuickTime:MediaModifyDate<$SRC",
    "-QuickTime:EncodingTime<$SRC",
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
    '-progress', # Show progress
    '-api', 'QuickTimeUTC=1' #Ensuring utc tags remain identical to the others
) + $extArgs + $tagArgs + @($SourceFolder)
Write-Host "Running ExifTool to copy 'Date Taken' into all date tags under:`n$SourceFolder`n" -ForegroundColor Cyan
& $ExifToolPath @runArgs
Write-Host "`nDone. Check the output above for the number of files updated." -ForegroundColor Green
