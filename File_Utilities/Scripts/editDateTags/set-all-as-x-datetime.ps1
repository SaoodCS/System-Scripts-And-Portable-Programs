$ExifToolPath = '.\File_Utilities\Programs\ExifTool\exiftool.exe'
$SourceFolder   = 'C:\Users\saood\Pictures\Backgrounds' #TODO: set this to the folder that contains the files
$TargetDate = '2018:01:01' #TODO: set this to the target date you want the files to be set to
$TargetTime = '12:00:00' #TODO: set this to the target time you want the files to be set to
$Target = "$TargetDate $TargetTime"
$Extensions = @('jpg', 'jpeg', 'dng', 'cr2', 'nef', 'arw', 'orf', 'raf', 'heic', 'heif', 'mp4', 'mov')
$extArgs = @()
foreach ($ext in $Extensions) { $extArgs += @('-ext', $ext) }
$tagArgs = @(
    "-AllDates=$Target",
    "-EXIF:DateTimeOriginal=$Target",
    "-XMP:CreateDate=$Target",
    "-XMP:ModifyDate=$Target",
    "-XMP:MetadataDate=$Target",
    "-IPTC:DateCreated=$TargetDate",
    "-IPTC:TimeCreated=$TargetTime",
    "-CreateDate=$Target",
    "-ModifyDate=$Target",
    "-TrackCreateDate=$Target",
    "-TrackModifyDate=$Target",
    "-MediaCreateDate=$Target",
    "-MediaModifyDate=$Target",
    "-Keys:CreationDate=$Target",
    "-QuickTime:CreateDate=$Target",
    "-QuickTime:ContentCreateDate=$Target",
    "-QuickTime:CreationDate=$Target",
    "-QuickTime:DateTimeOriginal=$Target",
    "-QuickTime:MediaCreateDate=$Target",
    "-QuickTime:MediaModifyDate=$Target",
    '-EXIF:OffsetTime=+00:00',
    '-EXIF:OffsetTimeOriginal=+00:00',
    '-EXIF:OffsetTimeDigitized=+00:00',
    "-FileCreateDate=$Target",
    "-FileModifyDate=$Target"
)
$runArgs = @(
    '-r', # Recurse into subfolders
    '-overwrite_original', #Do not keep _original backups
    '-m', #Ignore minor warnings that could halt processing
    '-progress', #Show progress in console
    '-api','QuickTimeUTC=1'   # <— add this (see note above)
) + $extArgs + $tagArgs + @($SourceFolder)
Write-Host "Running ExifTool to set dates to $Target on files under:`n$SourceFolder`n" -ForegroundColor Cyan
& $ExifToolPath @runArgs
Write-Host "`nDone. Check the output above for the number of files updated." -ForegroundColor Green
