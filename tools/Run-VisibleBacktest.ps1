<#
.SYNOPSIS
  可视化分段回测启动器：为每个回测 config 弹出一个独立 cmd 窗口，进度实时滚动。
  注意：本文件必须保存为 UTF-8 with BOM，否则 Windows PowerShell 5.1 会用 GBK 读取导致中文注释乱码。
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$Configs,

    [string]$LogPrefix = "live"
)

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = Split-Path -Parent $PSScriptRoot
$platformWsl = & powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\Get-QuantPlatformRoot.ps1" -Target Platform -Format WSL
if ([string]::IsNullOrWhiteSpace($platformWsl)) {
    Write-Error "无法解析平台 WSL 根路径。请检查 .research.local.json 或环境变量。"
    exit 1
}
$platformWsl = $platformWsl.Trim()

Write-Host "platform_wsl = $platformWsl"
Write-Host "config_count = $($Configs.Count)"
Write-Host "----------------------------------------"

foreach ($cfg in $Configs) {
    $cfg = $cfg.Trim()
    if ([string]::IsNullOrWhiteSpace($cfg)) { continue }

    $segName = [System.IO.Path]::GetFileNameWithoutExtension($cfg)

    $cfgRel = $cfg -replace '\\', '/'
    $idx = $cfgRel.IndexOf("configs/")
    if ($idx -ge 0) { $cfgRel = $cfgRel.Substring($idx) }

    $logRel = "tmp/${LogPrefix}_${segName}.log"
    $doneMsg = "====== $segName done, window can be closed ======"

    # bash 命令：进平台目录、设环境、跑回测、tee 写盘、完成后等待回车
    $bashCmd = "cd '$platformWsl'; export PYTHONPATH=src PYTHONUNBUFFERED=1; python3 src/run_v2_backtest.py --config '$cfgRel' 2>&1 | tee '$logRel'; echo '$doneMsg'; read"

    # cmd 窗口命令：先设标题，再启动 wsl bash（用 & 而非 &&，兼容 PS 调用 Start-Process 时的转义）
    $cmdArgs = "/k title $segName & wsl -- bash -c `"$bashCmd`""

    Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs | Out-Null

    Write-Host "window launched: $segName  (config: $cfgRel, log: $logRel)"
}

Write-Host "----------------------------------------"
Write-Host "All $($Configs.Count) window(s) launched."
Write-Host "Patrol protocol: read tmp/${LogPrefix}_*.log every 2 min until all summary.json present."
