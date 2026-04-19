# TODO: update the variables here, then run updateProfile.ps1 to add the path of this file to the PowerShell profile
$PathTextColor = [ConsoleColor]::White #TODO: set the path's text color
$PathBackgroundColor = [ConsoleColor]::DarkBlue #TODO: set the path's background color
$GitBranchTextColor = [ConsoleColor]::DarkYellow #TODO: set the git branch's text color
$ShowGitBranch = $true #TODO: set to false if you don't want to see the git branch

function prompt {
    $path = (Get-Location).Path
    $git = ''
    if ($ShowGitBranch) {
        $b = git branch --show-current 2>$null
        if ($b) { $git = "⎇ $b" }
    }
    Write-Host "PS $path" -ForegroundColor $PathTextColor -BackgroundColor $PathBackgroundColor -NoNewline
    if ($git) {
        Write-Host ' > ' -ForegroundColor $PathTextColor -BackgroundColor $PathBackgroundColor -NoNewline
        Write-Host $git -ForegroundColor $GitBranchTextColor -BackgroundColor $PathBackgroundColor -NoNewline
    }
    Write-Host ' > ' -ForegroundColor $PathTextColor -BackgroundColor $PathBackgroundColor -NoNewline
    return ' '
}