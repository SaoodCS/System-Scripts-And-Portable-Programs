$target = 'tidytabs' #TODO: Set the search term (case-insensitive). If the file/folder contains it in it's name, it'll be deleted

# Add paths here that you want to completely ignore (and everything under them)
$ignorePaths = @(
    'C:\Users\saood\Desktop\CodingSuite',
    'C:\Users\saood\Desktop\CreativeSuite'
)

# Normalize ignore paths once (remove trailing \)
$ignorePaths = $ignorePaths | ForEach-Object { $_.TrimEnd('\') }

function IsIgnoredPath([string]$path) {
    foreach ($ignore in $ignorePaths) {
        if ($path.StartsWith($ignore, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

$deletedFiles = 0
$deletedFolders = 0
$processed = 0
$lastProgressAt = 0

# Faster case-insensitive substring predicate than regex -match
$targetLower = $target.ToLowerInvariant()
function NameMatches([string]$name) {
    return $name -and ($name.ToLowerInvariant().Contains($targetLower))
}

# Track paths we already deleted / attempted (avoids repeats across drives/junction weirdness)
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

$drives = Get-PSDrive -PSProvider FileSystem

foreach ($drive in $drives) {
    $root = $drive.Root.TrimEnd('\')  # normalize

    # Skip entire drive if it's within an ignored root (rare, but safe)
    if (IsIgnoredPath $root) { continue }

    # Enumerate directories deepest-first so we can delete whole matching trees early
    try {
        $dirs = Get-ChildItem -LiteralPath $drive.Root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { -not (IsIgnoredPath $_.FullName) } |
            Sort-Object -Property FullName -Descending
    }
    catch {
        continue
    }

    foreach ($d in $dirs) {
        # Skip ignored paths (extra safety in case ignore list changes mid-run)
        if (IsIgnoredPath $d.FullName) { continue }

        $processed++

        # Throttle progress updates (UI calls can be slow)
        if ($processed -ge ($lastProgressAt + 200)) {
            $lastProgressAt = $processed
            Write-Progress `
                -Activity "Deleting items containing '$target'" `
                -Status "Deleted: Files=$deletedFiles , Folders=$deletedFolders`nCurrentPath=$($d.FullName)" `
                -PercentComplete -1
        }

        # If we already deleted/attempted this path, skip
        if (-not $seen.Add($d.FullName)) { continue }

        if (NameMatches $d.Name) {
            try {
                Remove-Item -LiteralPath $d.FullName -Recurse -Force -ErrorAction Stop
                $deletedFolders++

                # Mark descendants as seen so we don't later try to delete them individually
                # (prevents "double work" when enumeration already captured them)
                $prefix = $d.FullName.TrimEnd('\') + '\'
                foreach ($child in $dirs) {
                    # Skip ignored paths (also prevents adding ignored children)
                    if (IsIgnoredPath $child.FullName) { continue }

                    if ($child.FullName.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                        [void]$seen.Add($child.FullName)
                    }
                }
            }
            catch {
                # ignore
            }
        }
    }

    # Now delete matching files that are NOT inside ignored folders or deleted folders (seen prevents repeats)
    try {
        $files = Get-ChildItem -LiteralPath $drive.Root -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { -not (IsIgnoredPath $_.FullName) }
    }
    catch {
        continue
    }

    foreach ($f in $files) {
        if (IsIgnoredPath $f.FullName) { continue }

        $processed++

        if ($processed -ge ($lastProgressAt + 200)) {
            $lastProgressAt = $processed
            Write-Progress `
                -Activity "Deleting items containing '$target'" `
                -Status "Deleted: Files=$deletedFiles , Folders=$deletedFolders`nCurrentPath=$($f.FullName)" `
                -PercentComplete -1
        }

        if (-not $seen.Add($f.FullName)) { continue }

        if (NameMatches $f.Name) {
            try {
                Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop
                $deletedFiles++
            }
            catch {
                # ignore
            }
        }
    }
}

Write-Progress -Activity "Deleting items containing '$target'" -Completed
Write-Host 'Completed.' -ForegroundColor Green
Write-Host "Deleted Files  : $deletedFiles"
Write-Host "Deleted Folders: $deletedFolders"
