param(
    [ValidateSet('Windows', 'WSL', 'All')]
    [string]$Format = 'Windows',

    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Convert-WindowsPathToWsl([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    if ($Path -match '^([A-Za-z]):\\?(.*)$') {
        $drive = $Matches[1].ToLowerInvariant()
        $rest = $Matches[2] -replace '\\', '/'
        if ([string]::IsNullOrWhiteSpace($rest)) { return "/mnt/$drive" }
        return "/mnt/$drive/$rest"
    }
    return $Path -replace '\\', '/'
}

function Convert-WslPathToWindows([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    if ($Path -match '^/mnt/([a-zA-Z])/(.*)$') {
        $drive = $Matches[1].ToUpperInvariant()
        $rest = $Matches[2] -replace '/', '\'
        return "${drive}:\$rest"
    }
    return $Path
}

function Complete-RootPair([string]$WindowsRoot, [string]$WslRoot, [string]$SourceName) {
    if ([string]::IsNullOrWhiteSpace($WindowsRoot) -and [string]::IsNullOrWhiteSpace($WslRoot)) {
        return $null
    }
    if ([string]::IsNullOrWhiteSpace($WindowsRoot)) { $WindowsRoot = Convert-WslPathToWindows $WslRoot }
    if ([string]::IsNullOrWhiteSpace($WslRoot)) { $WslRoot = Convert-WindowsPathToWsl $WindowsRoot }

    $expectedWsl = (Convert-WindowsPathToWsl $WindowsRoot).TrimEnd('/')
    $actualWsl = $WslRoot.TrimEnd('/')
    if (-not $expectedWsl.Equals($actualWsl, [StringComparison]::OrdinalIgnoreCase)) {
        throw "智库项目 Windows/WSL 根不一致：'$WindowsRoot' vs '$WslRoot'（$SourceName）"
    }
    return [pscustomobject]@{
        windows = $WindowsRoot.TrimEnd('\')
        wsl = $actualWsl
        source = $SourceName
    }
}

$pair = Complete-RootPair `
    ([Environment]::GetEnvironmentVariable('THINKTANK_PROJECT_ROOT')) `
    ([Environment]::GetEnvironmentVariable('THINKTANK_PROJECT_WSL_ROOT')) `
    'environment variables'

if ($null -eq $pair) {
    $configPath = Join-Path $Root '.research.local.json'
    if (Test-Path -LiteralPath $configPath) {
        $config = Get-Content -LiteralPath $configPath -Raw -Encoding utf8 | ConvertFrom-Json
        $windows = if ($config.PSObject.Properties.Name -contains 'thinktank_project_root_windows') { [string]$config.thinktank_project_root_windows } else { '' }
        $wsl = if ($config.PSObject.Properties.Name -contains 'thinktank_project_root_wsl') { [string]$config.thinktank_project_root_wsl } else { '' }
        $pair = Complete-RootPair $windows $wsl '.research.local.json'
    }
}

if ($null -eq $pair) {
    throw '智库项目根未配置。设置 THINKTANK_PROJECT_ROOT/THINKTANK_PROJECT_WSL_ROOT，或填写 .research.local.json。'
}
if (-not (Test-Path -LiteralPath $pair.windows -PathType Container)) {
    throw "智库项目根不存在：$($pair.windows)"
}
if (-not (Test-Path -LiteralPath (Join-Path $pair.windows 'AGENTS.md') -PathType Leaf)) {
    throw "智库项目根缺少 AGENTS.md：$($pair.windows)"
}

switch ($Format) {
    'Windows' { Write-Output $pair.windows }
    'WSL' { Write-Output $pair.wsl }
    'All' {
        [pscustomobject]@{
            root_windows = $pair.windows
            root_wsl = $pair.wsl
            source = $pair.source
        } | ConvertTo-Json -Depth 2
    }
}
