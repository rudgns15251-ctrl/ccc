[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GodotPath
)

$ErrorActionPreference = 'Stop'
$taskProjectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskGodotExe = (Resolve-Path -LiteralPath $GodotPath).Path
$taskVersion = (& $taskGodotExe --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $taskVersion -notmatch '^4\.7\.1\.') {
    throw "Godot 4.7.1 is required. Detected: $taskVersion"
}
$taskRunStamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$taskLogRoot = Join-Path $taskProjectRoot ".godot/verification/public_smoke/$taskRunStamp"
New-Item -ItemType Directory -Path $taskLogRoot -Force | Out-Null
$taskScriptCount = 0

function Invoke-GodotCheck {
    param([string]$Name, [string[]]$CheckArguments)
    $taskEngineLog = Join-Path $taskLogRoot "$Name.log"
    $taskArguments = @('--headless', '--path', $taskProjectRoot, '--log-file', $taskEngineLog) + $CheckArguments
    $taskOutput = & $taskGodotExe @taskArguments 2>&1
    $taskExitCode = $LASTEXITCODE
    $taskOutput | Out-File -LiteralPath (Join-Path $taskLogRoot "$Name.console.log") -Encoding utf8
    $taskLogText = $taskOutput | Out-String
    if (Test-Path -LiteralPath $taskEngineLog) {
        $taskLogText += Get-Content -LiteralPath $taskEngineLog -Raw
    }
    if ($taskExitCode -ne 0 -or $taskLogText -match '(?m)^\s*(ERROR:|SCRIPT ERROR:|Parse Error:)' -or $taskLogText -match 'Parse Error') {
        throw "FAIL: $Name (exit $taskExitCode). Logs: $taskLogRoot"
    }
    Write-Output "PASS: $Name"
}

Write-Output "Godot $taskVersion"
Invoke-GodotCheck -Name 'editor_import' -CheckArguments @('--editor', '--import', '--quit')
$taskScripts = Get-ChildItem -LiteralPath (Join-Path $taskProjectRoot 'scripts') -Filter '*.gd' -Recurse -File | Sort-Object FullName
foreach ($taskScript in $taskScripts) {
    $taskRelativeScript = $taskScript.FullName.Substring($taskProjectRoot.Length + 1).Replace('\', '/')
    $taskCheckName = 'check_' + $taskRelativeScript.Replace('/', '_')
    Invoke-GodotCheck -Name $taskCheckName -CheckArguments @('--script', "res://$taskRelativeScript", '--check-only')
    $taskScriptCount++
}
Invoke-GodotCheck -Name 'main_start' -CheckArguments @('--quit-after', '30')
Write-Output "PASS: import, $taskScriptCount scripts, configured Main headless start. Logs: $taskLogRoot"
