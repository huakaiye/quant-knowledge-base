param(
    [ValidateSet('Platform', 'Live')]
    [string]$Target = 'Platform',

    [ValidateSet('Windows', 'WSL', 'All')]
    [string]$Format = 'Windows',

    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Convert-WindowsPathToWsl {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ''
    }
    if ($Path -match '^([A-Za-z]):\\?(.*)$') {
        $drive = $Matches[1].ToLowerInvariant()
        $rest = $Matches[2] -replace '\\', '/'
        if ([string]::IsNullOrWhiteSpace($rest)) {
            return "/mnt/$drive"
        }
        return "/mnt/$drive/$rest"
    }
    return $Path -replace '\\', '/'
}

function Convert-WslPathToWindows {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ''
    }
    if ($Path -match '^/mnt/([a-zA-Z])/(.*)$') {
        $drive = $Matches[1].ToUpperInvariant()
        $rest = $Matches[2] -replace '/', '\'
        return "${drive}:\$rest"
    }
    return $Path
}

$configPath = Join-Path $Root '.research.local.json'
$examplePath = Join-Path $Root '.research.local.example.json'
$windowsRoot = ''
$wslRoot = ''
$targetName = 'platform'
$windowsEnvName = 'QUANT_PLATFORM_ROOT'
$wslEnvName = 'QUANT_PLATFORM_WSL_ROOT'
$windowsProperty = 'platform_root_windows'
$wslProperty = 'platform_root_wsl'

if ($Target -eq 'Live') {
    $targetName = 'live'
    $windowsEnvName = 'LIVE_TRADING_ROOT'
    $wslEnvName = 'LIVE_TRADING_WSL_ROOT'
    $windowsProperty = 'live_root_windows'
    $wslProperty = 'live_root_wsl'
}

$windowsRoot = [Environment]::GetEnvironmentVariable($windowsEnvName)
$wslRoot = [Environment]::GetEnvironmentVariable($wslEnvName)

if (Test-Path -LiteralPath $configPath) {
    $config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ([string]::IsNullOrWhiteSpace($windowsRoot) -and $config.PSObject.Properties.Name -contains $windowsProperty) {
        $windowsRoot = [string]$config.$windowsProperty
    }
    if ([string]::IsNullOrWhiteSpace($wslRoot) -and $config.PSObject.Properties.Name -contains $wslProperty) {
        $wslRoot = [string]$config.$wslProperty
    }
}

if ([string]::IsNullOrWhiteSpace($windowsRoot) -and (Test-Path -LiteralPath $examplePath)) {
    $example = Get-Content -LiteralPath $examplePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($example.PSObject.Properties.Name -contains $windowsProperty) {
        $windowsRoot = [string]$example.$windowsProperty
    }
    if ($example.PSObject.Properties.Name -contains $wslProperty) {
        $wslRoot = [string]$example.$wslProperty
    }
}

if ([string]::IsNullOrWhiteSpace($windowsRoot) -and -not [string]::IsNullOrWhiteSpace($wslRoot)) {
    $windowsRoot = Convert-WslPathToWindows -Path $wslRoot
}

if ([string]::IsNullOrWhiteSpace($wslRoot) -and -not [string]::IsNullOrWhiteSpace($windowsRoot)) {
    $wslRoot = Convert-WindowsPathToWsl -Path $windowsRoot
}

if ([string]::IsNullOrWhiteSpace($windowsRoot)) {
    throw "$targetName root not found. Set $windowsEnvName, or copy .research.local.example.json to .research.local.json and edit it."
}

$source = 'env or .research.local.example.json default'
if (Test-Path -LiteralPath $configPath) {
    $source = 'env or .research.local.json'
}

switch ($Format) {
    'Windows' { Write-Output $windowsRoot }
    'WSL' { Write-Output $wslRoot }
    'All' {
        [pscustomobject]@{
            target = $Target
            root_windows = $windowsRoot
            root_wsl = $wslRoot
            source = $source
        } | ConvertTo-Json -Depth 2
    }
}
