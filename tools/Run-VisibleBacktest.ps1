<#
.SYNOPSIS
  为最多四个结构化 V2 受控回测任务打开独立窗口，并保留实时日志。
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [object[]]$Runs,

    [string]$LogPrefix = 'live',

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
$allowedEntryPoints = @('scripts/run_wufu_v52.py')

function Convert-ToBashLiteral {
    param([string]$Value)
    if ($Value -match '[\r\n]') {
        throw '参数不得包含换行符。'
    }
    $escaped = $Value.Replace("'", '''"''"''')
    return "'" + $escaped + "'"
}

if ($Runs.Count -lt 1 -or $Runs.Count -gt 4) {
    throw "V2 受控并发要求一次启动 1 至 4 个任务，当前为 $($Runs.Count) 个。"
}

$platformWsl = & pwsh -NoProfile -File "$PSScriptRoot\Get-QuantPlatformRoot.ps1" -Target Platform -Format WSL
if ([string]::IsNullOrWhiteSpace($platformWsl)) {
    throw '无法解析 V2 平台 WSL 根路径。请检查 .research.local.json 或环境变量。'
}
$platformWsl = $platformWsl.Trim()

Write-Host "platform_wsl = $platformWsl"
Write-Host "run_count = $($Runs.Count)"
Write-Host "dry_run = $($DryRun.IsPresent)"
Write-Host '----------------------------------------'

for ($i = 0; $i -lt $Runs.Count; $i++) {
    $run = $Runs[$i]
    $entryPoint = [string]$run.EntryPoint
    if ($entryPoint -notin $allowedEntryPoints) {
        throw "任务 $($i + 1) 的入口 '$entryPoint' 不在 V2 受控白名单：$($allowedEntryPoints -join ', ')"
    }

    $arguments = @($run.Arguments | ForEach-Object { [string]$_ })
    if ($arguments -contains '--in-process') {
        throw "任务 $($i + 1) 禁止使用 --in-process。"
    }

    $segmentName = [string]$run.Name
    if ([string]::IsNullOrWhiteSpace($segmentName)) {
        $segmentName = "run_$($i + 1)"
    }
    $safeName = $segmentName -replace '[^A-Za-z0-9_.-]', '_'
    $safePrefix = $LogPrefix -replace '[^A-Za-z0-9_.-]', '_'
    $logRel = "tmp/${safePrefix}_${safeName}.log"
    $doneMsg = "====== $safeName done, window can be closed ======"

    $commandParts = @(
        '.venv/bin/python',
        (Convert-ToBashLiteral -Value $entryPoint)
    )
    $commandParts += $arguments | ForEach-Object { Convert-ToBashLiteral -Value $_ }
    $command = $commandParts -join ' '

    $bashCmd = "set -o pipefail; cd '$platformWsl' && export PYTHONUNBUFFERED=1 && $command 2>&1 | tee '$logRel'; status=`$?; echo '$doneMsg exit_status='`$status; read -r; exit `$status"
    $cmdArgs = "/k title $safeName & wsl.exe bash -lc `"$bashCmd`""

    Write-Host "run: $safeName"
    Write-Host "entry: $entryPoint"
    Write-Host "log: $logRel"
    Write-Host "bash: $bashCmd"

    if (-not $DryRun) {
        Start-Process -FilePath 'cmd.exe' -ArgumentList $cmdArgs | Out-Null
        Write-Host "window launched: $safeName"
    }
}

Write-Host '----------------------------------------'
if ($DryRun) {
    Write-Host 'DryRun 完成，未启动任何回测进程。'
}
else {
    Write-Host '全部窗口已启动；请按规范主动巡检日志、结果产物和进程组状态。'
}
