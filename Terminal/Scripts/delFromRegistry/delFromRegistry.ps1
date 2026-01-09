# Safely deletes an app from registry without deleting important binaries
$SearchTerm = "mp3directcut" #TODO: Set the search term (case-insensitive). If the reg key/value name contains it or the value contains it in its string val, it'll be deleted
$RootMap = @{
    "HKLM" = [Microsoft.Win32.Registry]::LocalMachine
    "HKCU" = [Microsoft.Win32.Registry]::CurrentUser
    "HKCR" = [Microsoft.Win32.Registry]::ClassesRoot
    "HKU"  = [Microsoft.Win32.Registry]::Users
    "HKCC" = [Microsoft.Win32.Registry]::CurrentConfig
}
$Visited = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

$Queue = [System.Collections.Generic.Queue[object]]::new()
foreach ($rk in $RootMap.Keys) {
    $Queue.Enqueue(@($rk, ""))
}

function ContainsTerm {
    param([string]$Text, [string]$Term)
    if ([string]::IsNullOrEmpty($Text)) { return $false }
    return ($Text.IndexOf($Term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
}

function DataContainsTerm {
    param([object]$Data, [string]$Term)

    if ($null -eq $Data) { return $false }

    if ($Data -is [string]) {
        return (ContainsTerm $Data $Term)
    }

    if ($Data -is [string[]]) {
        foreach ($s in $Data) {
            if (ContainsTerm $s $Term) { return $true }
        }
    }

    return $false
}

$processed = 0
$keysDeleted = 0
$valuesDeleted = 0

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$lastUiMs = -999999

while ($Queue.Count -gt 0) {
    $item = $Queue.Dequeue()
    $rootShort = [string]$item[0]
    $subPath   = [string]$item[1]

    $fullPath = if ([string]::IsNullOrEmpty($subPath)) {
        "${rootShort}:\"
    } else {
        "${rootShort}:\$subPath"
    }
    if ($Visited.Contains($fullPath)) { continue }
    $null = $Visited.Add($fullPath)
    $processed++
    $ms = $sw.ElapsedMilliseconds
    if (($ms - $lastUiMs) -ge 350) {
        $lastUiMs = $ms
        Write-Progress -Activity "Registry cleanup" `
            -Status "Processed: $processed   Queued: $($Queue.Count)   Deleted: K=$keysDeleted V=$valuesDeleted   Current: $fullPath" `
            -PercentComplete 0
    }

    $baseKey = $RootMap[$rootShort]
    $key = $null
    $writable = $true
    try {
        $key = if ([string]::IsNullOrEmpty($subPath)) { $baseKey } else { $baseKey.OpenSubKey($subPath, $true) }
        if ($null -eq $key) { continue }
    } catch {
        $writable = $false
        try {
            $key = if ([string]::IsNullOrEmpty($subPath)) { $baseKey } else { $baseKey.OpenSubKey($subPath, $false) }
            if ($null -eq $key) { continue }
        } catch {
            continue
        }
    }
    $keyName = if ([string]::IsNullOrEmpty($subPath)) {
        ""
    } else {
        $i = $subPath.LastIndexOf('\')
        if ($i -ge 0) { $subPath.Substring($i + 1) } else { $subPath }
    }

    if (-not [string]::IsNullOrEmpty($subPath) -and (ContainsTerm $keyName $SearchTerm)) {
        $deleted = $false
        try {
            $lastSlash = $subPath.LastIndexOf('\')
            $parentPath = if ($lastSlash -ge 0) { $subPath.Substring(0, $lastSlash) } else { "" }
            $leafName   = $keyName

            $parentKey = if ([string]::IsNullOrEmpty($parentPath)) { $baseKey } else { $baseKey.OpenSubKey($parentPath, $true) }
            if ($parentKey -ne $null) {
                $parentKey.DeleteSubKeyTree($leafName, $false)
                $deleted = $true
                $parentKey.Close()
            }
        } catch {
            # ignore access/protection issues
        }

        if ($deleted) { $keysDeleted++ }

        try { if ($key -ne $baseKey) { $key.Close() } } catch {}
        continue
    }
    try {
        foreach ($child in $key.GetSubKeyNames()) {
            $childPath = if ([string]::IsNullOrEmpty($subPath)) { $child } else { "$subPath\$child" }
            $childFull = "${rootShort}:\$childPath"
            if (-not $Visited.Contains($childFull)) {
                $Queue.Enqueue(@($rootShort, $childPath))
            }
        }
    } catch {
        # ignore
    }

    # Remove values whose DATA contains the term (including Default)
    if ($writable) {
        try {
            $defaultData = $key.GetValue("", $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            if (DataContainsTerm $defaultData $SearchTerm) {
                try {
                    $key.DeleteValue("", $false)
                    $valuesDeleted++
                } catch { }
            }

            foreach ($vn in $key.GetValueNames()) {
                if ($vn -eq "") { continue }
                $vd = $key.GetValue($vn, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                if (DataContainsTerm $vd $SearchTerm) {
                    try {
                        $key.DeleteValue($vn, $false)
                        $valuesDeleted++
                    } catch { }
                }
            }
        } catch {
            # ignore
        }
    }

    try { if ($key -ne $baseKey) { $key.Close() } } catch {}
}

Write-Progress -Activity "Registry cleanup" -Completed
Write-Host "Registry cleanup complete."
Write-Host "Processed: $processed   Visited: $($Visited.Count)"
Write-Host "Deleted: Keys=$keysDeleted   Values=$valuesDeleted   Total=$($keysDeleted + $valuesDeleted)"
