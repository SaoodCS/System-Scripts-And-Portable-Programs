# TODO: update the variables here, then run updateProfile.ps1 to add the path of this file to the PowerShell profile
$PathTextColor = [ConsoleColor]::White #TODO: set the path's text color
$PathBackgroundColor = [ConsoleColor]::DarkBlue #TODO: set the path's background color
$ShowGitBranch = $true #TODO: set to false if you don't want to see the git branch

function prompt {
    $path = (Get-Location).Path
    $git = ''
    if ($ShowGitBranch) {
        $b = git branch --show-current 2>$null
        if ($b) { $git = " > ⎇ $b" }
    }
    Write-Host "PS $path$git > " -ForegroundColor $PathTextColor -BackgroundColor $PathBackgroundColor -NoNewline
    return ' '
}
