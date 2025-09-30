$ExifToolPath = '.\File_Utilities\Programs\ExifTool\exiftool.exe'
$FilePath = 'C:\Users\saood\Desktop\Nikkah Video\19.45\baby.mp4' #TODO: set this to the path of the file you want to view the metadata for

$arguments = @(
    '-a',     # duplicate tags
    '-u',     # unknown tags
    '-g1',    # group by category
    '-s',     # short tag names
    '--',     # stop processing options
    $FilePath
)

& $ExifToolPath @arguments | Out-String | Write-Output