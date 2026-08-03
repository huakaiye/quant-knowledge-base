Write-Warning '历史只读工具：只检查 V1.4 结果证据，不启动或判断当前 V2 回测。'
$legacyRoot = & pwsh -NoProfile -File "$PSScriptRoot\Get-QuantPlatformRoot.ps1" -Target LegacyPlatform -Format Windows
$base = Join-Path $legacyRoot 'results\v2\research\R010-DEFENSE\rule_a_idle\EX-20260627T053730Z-main-JTX7\formal\trend_break'
$dirs = @('ablation_no_gradual_cost1x_11yr','ablation_no_gradual_cost2x_11yr')
foreach ($d in $dirs) {
  $p = Join-Path $base $d
  Write-Host "### $d"
  if (Test-Path $p) {
    $items = Get-ChildItem $p -Recurse -ErrorAction SilentlyContinue
    foreach ($it in $items) { Write-Host ("  " + $it.FullName.Substring($base.Length) + "  " + $it.Length + "B  " + $it.LastWriteTime) }
  } else {
    Write-Host "  NOT FOUND"
  }
}
