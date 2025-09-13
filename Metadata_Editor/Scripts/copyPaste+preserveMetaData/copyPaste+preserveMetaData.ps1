$SourceFolder = 'C:\Users\saood\Desktop\Nikkah DNG'   # TODO: set folder with the files you want to copy
$DestinationFolder = 'D:\AS DNG'                       # TODO: set folder where you want to copy the files to

# Options
$copyDataAttrTimestamps = $true   # Preserve Data, Attributes, and Timestamps
$copyDirectoryTimestamps = $true   # Preserve Directory Timestamps
$overwriteSameFileNames = $false  # Overwrite files with the same name?
if ($copyDataAttrTimestamps) {
    $options = '/COPY:DAT'
}
if ($copyDirectoryTimestamps) {
    $options += ' /DCOPY:T'
}
if (-not $overwriteSameFileNames) {
    $options += ' /XO'
}
$options += ' /R:1 /W:1'

# Run robocopy
Write-Host "Running robocopy from '$SourceFolder' to '$DestinationFolder' with options: $options"
robocopy $SourceFolder $DestinationFolder *.* $options

Write-Host "`nRobocopy completed."
