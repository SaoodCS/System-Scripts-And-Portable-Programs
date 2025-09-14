$SourceFolder = 'C:\Users\saood\Desktop\Nikkah JPG'   # TODO: set folder with the files you want to copy
$DestinationFolder = 'C:\Users\saood\Pictures\iCloud Photos\Photos' # TODO: set folder where you want to copy the files to

# Options
$copyDataAttrTimestamps = $true   # Preserve Data, Attributes, and Timestamps
$copyDirectoryTimestamps = $true   # Preserve Directory Timestamps
$overwriteSameFileNames = $false  # Overwrite files with the same name?

$options = @()
if ($copyDataAttrTimestamps) { $options += '/COPY:DAT' }
if ($copyDirectoryTimestamps) { $options += '/DCOPY:T' }

# Run robocopy
Write-Host "Running robocopy from '$SourceFolder' to '$DestinationFolder' with options: $($options -join ' ')"

& robocopy $SourceFolder $DestinationFolder '*.*' @options

Write-Host "`nRobocopy completed."

# robocopy "C:\Users\saood\Desktop\Nikkah JPG" "C:\Users\saood\iCloudDrive\Nikkah JPEG" /COPY:DAT /DCOPY:T