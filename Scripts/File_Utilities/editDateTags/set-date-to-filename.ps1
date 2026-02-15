$ExifToolPath = Join-Path $PSScriptRoot '..\..\..\Programs\ExifTool\exiftool.exe'
$SourceFolder = 'C:\Users\saood\Desktop\FOR GOOGLE PHOTOS' #TODO: set this to the folder that contains the files
$Extensions = @('jpg', 'jpeg', 'dng', 'cr2', 'nef', 'arw', 'orf', 'raf', 'heic', 'heif', 'mp4', 'mov', 'png', 'avi')
$DatePrefixRegex = '^(?<dd>\d{2})-(?<MM>\d{2})-(?<yyyy>\d{4})(?:\b|[\s_\-])' # Matches filenames starting with dd-mm-yyyy

$files = Get-ChildItem -Path $SourceFolder -File -Recurse | Where-Object {
    $Extensions -contains $_.Extension.TrimStart('.').ToLowerInvariant()
}

foreach ($file in $files) {

    $m = [regex]::Match($file.BaseName, $DatePrefixRegex)
    if (-not $m.Success) {
        Write-Host "SKIP (no date prefix): $($file.FullName)"
        continue
    }

    $dd = [int]$m.Groups['dd'].Value
    $MM = [int]$m.Groups['MM'].Value
    $yyyy = [int]$m.Groups['yyyy'].Value

    try {
        # Set time to 18:00:00 (6 PM)
        $dt = [datetime]::new($yyyy, $MM, $dd, 18, 0, 0)
    }
    catch {
        Write-Host "SKIP (invalid date): $($file.FullName)"
        continue
    }

    # ExifTool formats
    $Target = $dt.ToString('yyyy:MM:dd HH:mm:ss')  # 2024:12:12 18:00:00
    $TargetDate = $dt.ToString('yyyy:MM:dd')
    $TargetTime = $dt.ToString('HH:mm:ss')             # 18:00:00

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
        "-QuickTime:ModifyDate=$Target",
        "-QuickTime:ContentCreateDate=$Target",
        "-QuickTime:CreationDate=$Target",
        "-QuickTime:DateTimeOriginal=$Target",
        "-QuickTime:MediaCreateDate=$Target",
        "-QuickTime:MediaModifyDate=$Target",
        "-QuickTime:EncodingTime=$Target",
        '-EXIF:OffsetTime=+00:00',
        '-EXIF:OffsetTimeOriginal=+00:00',
        '-EXIF:OffsetTimeDigitized=+00:00',
        "-FileCreateDate=$Target",
        "-FileModifyDate=$Target"
    )

    & $ExifToolPath `
        -overwrite_original `
        -m `
        -q `
        $tagArgs `
        $file.FullName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $($file.Name) -> $Target"
    }
    else {
        Write-Host "ERROR: $($file.FullName)"
    }
}
