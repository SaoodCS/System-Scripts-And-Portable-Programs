$SourceFolder = 'C:\Users\saood\Desktop\Sorted Afterparty FLAT'   # TODO: set folder with the files you want to copy
$DestinationFolder = 'C:\Users\saood\Pictures\iCloud Photos\Photos' # TODO: set folder where you want to copy the files to
$copyDataAttrTimestamps = $true   # Preserve Data, Attributes, and Timestamps
$copyDirectoryTimestamps = $true   # Preserve Directory Timestamps
$options = @()
if ($copyDataAttrTimestamps) { $options += '/COPY:DAT' }
if ($copyDirectoryTimestamps) { $options += '/DCOPY:T' }

# Get all subfolders (recursively) including the root
$AllFolders = Get-ChildItem -Path $SourceFolder -Recurse -Directory | Select-Object -ExpandProperty FullName
$AllFolders = @($SourceFolder) + $AllFolders
# Copy files from each folder into destination folder
foreach ($folder in $AllFolders) {
    Write-Host "Running robocopy from '$folder' to '$DestinationFolder' with options: $($options -join ' ')"
    & robocopy $folder $DestinationFolder '*.*' @options
}
Write-Host "`nRobocopy completed for all subfolders."
