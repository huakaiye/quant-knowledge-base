param(
    [ValidateSet('Platform', 'LegacyPlatform', 'Live')]
    [string]$Target = 'Platform',

    [ValidateSet('Windows', 'WSL', 'All')]
    [string]$Format = 'Windows',

    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Convert-WindowsPathToWsl {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    if ($Path -match '^([A-Za-z]):\\?(.*)$') {
        $drive = $Matches[1].ToLowerInvariant()
        $rest = $Matches[2] -replace '\\', '/'
        if ([string]::IsNullOrWhiteSpace($rest)) { return "/mnt/$drive" }
        return "/mnt/$drive/$rest"
    }
    return $Path -replace '\\', '/'
}

function Convert-WslPathToWindows {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    if ($Path -match '^/mnt/([a-zA-Z])/(.*)$') {
        $drive = $Matches[1].ToUpperInvariant()
        $rest = $Matches[2] -replace '/', '\'
        return "${drive}:\$rest"
    }
    return $Path
}

function Complete-And-TestPair {
    param(
        [string]$WindowsRoot,
        [string]$WslRoot,
        [string]$SourceName
    )

    if ([string]::IsNullOrWhiteSpace($WindowsRoot) -and [string]::IsNullOrWhiteSpace($WslRoot)) {
        return $null
    }
    if ([string]::IsNullOrWhiteSpace($WindowsRoot)) {
        $WindowsRoot = Convert-WslPathToWindows -Path $WslRoot
    }
    if ([string]::IsNullOrWhiteSpace($WslRoot)) {
        $WslRoot = Convert-WindowsPathToWsl -Path $WindowsRoot
    }

    $expectedWsl = (Convert-WindowsPathToWsl -Path $WindowsRoot).TrimEnd('/')
    $actualWsl = $WslRoot.TrimEnd('/')
    if (-not $expectedWsl.Equals($actualWsl, [StringComparison]::OrdinalIgnoreCase)) {
        throw "$targetName Windows/WSL roots disagree in $SourceName`: '$WindowsRoot' vs '$WslRoot'."
    }

    [pscustomobject]@{
        windows = $WindowsRoot.TrimEnd('\')
        wsl = $actualWsl
        source = $SourceName
    }
}

$configPath = Join-Path $Root '.research.local.json'
$examplePath = Join-Path $Root '.research.local.example.json'
$targetName = 'platform'
$windowsEnvName = 'QUANT_PLATFORM_ROOT'
$wslEnvName = 'QUANT_PLATFORM_WSL_ROOT'
$windowsProperty = 'platform_root_windows'
$wslProperty = 'platform_root_wsl'

if ($Target -eq 'LegacyPlatform') {
    $targetName = 'legacy platform'
    $windowsEnvName = 'LEGACY_QUANT_PLATFORM_ROOT'
    $wslEnvName = 'LEGACY_QUANT_PLATFORM_WSL_ROOT'
    $windowsProperty = 'legacy_platform_root_windows'
    $wslProperty = 'legacy_platform_root_wsl'
}
elseif ($Target -eq 'Live') {
    $targetName = 'live'
    $windowsEnvName = 'LIVE_TRADING_ROOT'
    $wslEnvName = 'LIVE_TRADING_WSL_ROOT'
    $windowsProperty = 'live_root_windows'
    $wslProperty = 'live_root_wsl'
}

$pair = Complete-And-TestPair `
    -WindowsRoot ([Environment]::GetEnvironmentVariable($windowsEnvName)) `
    -WslRoot ([Environment]::GetEnvironmentVariable($wslEnvName)) `
    -SourceName 'environment variables'

if ($null -eq $pair -and (Test-Path -LiteralPath $configPath)) {
    $config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $configWindows = if ($config.PSObject.Properties.Name -contains $windowsProperty) { [string]$config.$windowsProperty } else { '' }
    $configWsl = if ($config.PSObject.Properties.Name -contains $wslProperty) { [string]$config.$wslProperty } else { '' }
    $pair = Complete-And-TestPair -WindowsRoot $configWindows -WslRoot $configWsl -SourceName '.research.local.json'
}

if ($null -eq $pair -and (Test-Path -LiteralPath $examplePath)) {
    $example = Get-Content -LiteralPath $examplePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $exampleWindows = if ($example.PSObject.Properties.Name -contains $windowsProperty) { [string]$example.$windowsProperty } else { '' }
    $exampleWsl = if ($example.PSObject.Properties.Name -contains $wslProperty) { [string]$example.$wslProperty } else { '' }
    $pair = Complete-And-TestPair -WindowsRoot $exampleWindows -WslRoot $exampleWsl -SourceName '.research.local.example.json'
}

if ($null -eq $pair) {
    throw "$targetName root not found. Set $windowsEnvName/$wslEnvName, or configure .research.local.json."
}

if ($Target -ne 'Live') {
    if (-not (Test-Path -LiteralPath $pair.windows -PathType Container)) {
        throw "$targetName Windows root does not exist: $($pair.windows)"
    }
}

if ($Target -eq 'Platform') {
    if (-not (Test-Path -LiteralPath (Join-Path $pair.windows 'AGENTS.md') -PathType Leaf)) {
        throw "$targetName root is missing AGENTS.md: $($pair.windows)"
    }
}

switch ($Format) {
    'Windows' { Write-Output $pair.windows }
    'WSL' { Write-Output $pair.wsl }
    'All' {
        [pscustomobject]@{
            target = $Target
            root_windows = $pair.windows
            root_wsl = $pair.wsl
            source = $pair.source
        } | ConvertTo-Json -Depth 2
    }
}
