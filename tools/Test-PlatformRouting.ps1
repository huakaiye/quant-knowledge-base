param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$errors = New-Object System.Collections.Generic.List[string]

function Add-Error {
    param([string]$Message)
    $errors.Add($Message)
}

$examplePath = Join-Path $Root '.research.local.example.json'
try {
    $example = Get-Content -LiteralPath $examplePath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($propertyName in @(
        'platform_root_windows',
        'platform_root_wsl',
        'legacy_platform_root_windows',
        'legacy_platform_root_wsl',
        'live_root_windows',
        'live_root_wsl'
    )) {
        if ($example.PSObject.Properties.Name -notcontains $propertyName) {
            Add-Error ".research.local.example.json 缺少字段：$propertyName"
        }
    }
}
catch {
    Add-Error ".research.local.example.json 无法解析：$($_.Exception.Message)"
}

$resolver = Join-Path $Root 'tools\Get-QuantPlatformRoot.ps1'
$platform = $null
$legacy = $null
try {
    $platform = (& $resolver -Target Platform -Format All -Root $Root | ConvertFrom-Json)
}
catch {
    Add-Error "当前 V2 平台根解析失败：$($_.Exception.Message)"
}
try {
    $legacy = (& $resolver -Target LegacyPlatform -Format All -Root $Root | ConvertFrom-Json)
}
catch {
    Add-Error "V1.4 历史根解析失败：$($_.Exception.Message)"
}

if ($null -ne $platform -and $null -ne $legacy) {
    if ($platform.root_windows -eq $legacy.root_windows -or $platform.root_wsl -eq $legacy.root_wsl) {
        Add-Error '当前平台根与历史平台根不得相同。'
    }
    foreach ($relative in @('AGENTS.md', '.venv\bin\python', 'scripts\run_wufu_v52.py')) {
        if (-not (Test-Path -LiteralPath (Join-Path $platform.root_windows $relative))) {
            Add-Error "V2 平台缺少当前运行标识：$relative"
        }
    }
    foreach ($relative in @('src\run_v2_backtest.py', 'scripts\research\run_parallel_backtest.sh')) {
        if (Test-Path -LiteralPath (Join-Path $platform.root_windows $relative)) {
            Add-Error "V2 当前平台不应恢复旧入口：$relative"
        }
    }
}

$legacyRelativePrefixes = @(
    'src/strategies',
    'src/quant_v2',
    'src/run_v2_backtest.py',
    'src/run_v2_live.py',
    'src/tests/quant_v2',
    'src/tests/scripts',
    'tests/research',
    'scripts/research',
    'scripts/jq_fetcher',
    'configs/research',
    'configs/validation',
    'configs/v2_',
    'results/v2',
    '聚宽数据',
    'docs/V2_',
    'docs/AGENT_RULES',
    'docs/obsidian',
    'docs/聚宽API底层语义兼容审计_2026-05-27.md',
    'data',
    'tmp/jq_checkpoint',
    'tmp/jq_speed_benchmark_report.txt',
    'tmp/parallel_backtests_',
    'tmp/vtech_',
    'tmp/qmt_order_state'
)
$legacyCurrentPrefixes = foreach ($relative in $legacyRelativePrefixes) {
    '${QUANT_PLATFORM_ROOT}/' + $relative
    '${QUANT_PLATFORM_ROOT}\' + $relative.Replace('/', '\')
}
$assetRoots = @(
    '00_入口',
    '01_台账',
    '02_研究方向',
    '03_策略档案',
    '04_实验记录',
    '05_研究决策',
    '06_文献资料',
    '07_因子数据灵感',
    '08_方法论',
    '10_模板',
    '12_归档',
    'docs'
)
foreach ($assetRoot in $assetRoots) {
    $directory = Join-Path $Root $assetRoot
    if (-not (Test-Path -LiteralPath $directory)) { continue }
    Get-ChildItem -LiteralPath $directory -Recurse -File | Where-Object { $_.Extension -in @('.md', '.csv') } | ForEach-Object {
        $content = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
        $hasLegacyCurrentPrefix = $false
        foreach ($prefix in $legacyCurrentPrefixes) {
            if ($content.Contains($prefix)) {
                $hasLegacyCurrentPrefix = $true
                break
            }
        }
        if ($hasLegacyCurrentPrefix) {
            $relative = $_.FullName.Substring($Root.Length).TrimStart('\', '/')
            Add-Error "旧平台布局仍挂在当前逻辑根：$relative"
        }
    }
}

$launcherPath = Join-Path $Root 'tools\Run-VisibleBacktest.ps1'
$launcher = Get-Content -LiteralPath $launcherPath -Raw -Encoding UTF8
foreach ($requiredText in @("'scripts/run_wufu_v52.py'", '[object[]]$Runs', '[switch]$DryRun', "-Target Platform")) {
    if (-not $launcher.Contains($requiredText)) {
        Add-Error "可视化启动器缺少受控约束：$requiredText"
    }
}
if ($launcher -match '\[string\[\]\]\$Commands|src/run_v2_backtest\.py|run_parallel_backtest') {
    Add-Error '可视化启动器仍接受原始命令或引用旧入口。'
}

$currentRuleFiles = @(
    'AGENTS.md',
    '08_方法论\平台协作规范.md',
    '08_方法论\子代理调度规范.md',
    '08_方法论\可视化分段回测规范.md'
)
foreach ($relative in $currentRuleFiles) {
    $content = Get-Content -LiteralPath (Join-Path $Root $relative) -Raw -Encoding UTF8
    if ($content -match 'PYTHONPATH=src\s+python3|python3\s+src/run_v2_backtest') {
        Add-Error "当前规范仍包含可执行的旧 Python 命令：$relative"
    }
}

if ($errors.Count -eq 0) {
    Write-Output '平台路由检查：通过'
    if ($null -ne $platform) { Write-Output "当前平台：$($platform.root_windows) | $($platform.root_wsl)" }
    if ($null -ne $legacy) { Write-Output "历史平台：$($legacy.root_windows) | $($legacy.root_wsl)" }
    return
}

Write-Output '平台路由检查：失败'
foreach ($item in $errors) {
    Write-Output "ERROR: $item"
}
throw "平台路由检查失败，共 $($errors.Count) 项。"
