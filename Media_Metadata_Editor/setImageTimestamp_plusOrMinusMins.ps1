# ---- Configuration ----
$ExifToolPath = 'C:\Users\saood\PortablePrograms\ExifTool\exiftool.exe' #TODO: set this to the exiftool.exe path
$RootFolder   = 'C:\Users\saood\Desktop\Nikkah Photos\Nikkah Photos DNG' #TODO: set this to the folder that contains the images
$MinutesOffset = 4 # TODO: set this to the no. of mins to change the date by e.g. 3 to add three mins; -5 to subtract five mins

$Extensions = @('jpg', 'jpeg', 'dng', 'cr2', 'nef', 'arw', 'orf', 'raf', 'heic', 'heif', 'mp4', 'mov')
$extArgs = @()
foreach ($ext in $Extensions) { $extArgs += @('-ext', $ext) }
$shiftTags = @(
    'AllDates',
    'EXIF:DateTimeOriginal',
    'XMP:CreateDate',
    'XMP:ModifyDate',
    'XMP:MetadataDate',
    'IPTC:TimeCreated',
    'CreateDate',
    'ModifyDate',
    'TrackCreateDate',
    'TrackModifyDate',
    'MediaCreateDate',
    'MediaModifyDate',
    'Keys:CreationDate',
    'QuickTime:ContentCreateDate',
    'QuickTime:CreationDate',
    'QuickTime:DateTimeOriginal',
    'FileCreateDate',
    'FileModifyDate'
)
if ($MinutesOffset -ge 0) {
    $shiftOp = '+='
    $absMinutes = [int]$MinutesOffset
} else {
    $shiftOp = '-='
    $absMinutes = [int][math]::Abs($MinutesOffset)
}
$shiftString = ("0:0:0 0:{0}:0" -f $absMinutes)
$tagArgs = @()
foreach ($tag in $shiftTags) {
    $tagArgs += "-$tag$shiftOp$shiftString"
}
$runArgs = @(
    '-r', # Recurse into subfolders
    '-overwrite_original', # Do not keep _original backups
    '-m', # Ignore minor warnings
    '-progress', # Show progress
    '-wm', 'w' # Only modify tags that already exist (skip non-existent)
) + $extArgs + $tagArgs + @($RootFolder)
# Execute
$sign = ($(if ($HoursOffset -ge 0) { '+' } else { '-' }))
Write-Host "Running ExifTool to shift times by $sign$absHours hour(s) on files under:`n$RootFolder`n" -ForegroundColor Cyan
& $ExifToolPath @runArgs
Write-Host "`nDone. Check the output above for the number of files updated." -ForegroundColor Green
