param(
    [string]$ScriptPath = (Join-Path $PSScriptRoot '..' 'NetInfo.ps1'),
    [string]$ReadmePath = (Join-Path $PSScriptRoot '..' 'README.md')
)

$resolvedScript = (Resolve-Path -Path $ScriptPath).Path
$resolvedReadme = (Resolve-Path -Path $ReadmePath).Path

$hash = (Get-FileHash -Path $resolvedScript -Algorithm SHA256).Hash.ToLowerInvariant()

$readme = Get-Content -Path $resolvedReadme -Raw
$pattern = 'Official SHA-256 Hash:\\s*`([a-f0-9]{64})`'
$replacement = "Official SHA-256 Hash: `\`$hash`"

if ($readme -match $pattern) {
    $updated = [regex]::Replace($readme, $pattern, $replacement, 1)
}
else {
    throw 'Could not find the SHA-256 hash line in README.md.'
}

Set-Content -Path $resolvedReadme -Value $updated -NoNewline
Write-Host "Updated README.md with SHA-256: $hash"
