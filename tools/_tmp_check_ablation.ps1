$base = 'E:\量化平台_V1.4.0\results\v2\research\R010-DEFENSE\rule_a_idle\EX-20260627T053730Z-main-JTX7\formal\trend_break'
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
# check wsl backtest processes still running
Write-Host "### wsl processes"
Get-Process -Name "wsl*" -ErrorAction SilentlyContinue | Select-Object Name, Id, StartTime, CPU
Write-Host "### python in wsl"
wsl -- bash -lc "ps aux | grep -E 'run_v2_backtest|run_parallel' | grep -v grep" 2>$null
