Write-Warning '历史只读工具：只比较 V1.4 结果证据，不能用于当前 V2 结果。'
$legacyRoot = & pwsh -NoProfile -File "$PSScriptRoot\Get-QuantPlatformRoot.ps1" -Target LegacyPlatform -Format Windows
$base = Join-Path $legacyRoot 'results\v2\research\R010-DEFENSE\rule_a_idle\EX-20260627T053730Z-main-JTX7'
$pairs = @{
  'cost1x' = @(
    'decade5_fixed\a2_trend\3829c8cd790148f7be2b0a5461849d1a\equity_curve.csv',
    'formal\trend_break\ablation_no_gradual_cost1x_11yr\8fd4b217048e454f89520acf1e79f52b\equity_curve.csv'
  )
  'cost2x' = @(
    'formal\trend_break\cost2x_11yr_a2\442e723ab89b488dbb7e871d9bc9c439\equity_curve.csv',
    'formal\trend_break\ablation_no_gradual_cost2x_11yr\23dad9ab5c984ab684ab36d2e91dbb11\equity_curve.csv'
  )
}

foreach ($pair in $pairs.Keys) {
  Write-Host "===== $pair (full vs no_gradual) ====="
  $full = Import-Csv (Join-Path $base $pairs[$pair][0])
  $ablation = Import-Csv (Join-Path $base $pairs[$pair][1])
  $fullByMonth = @{}
  foreach ($r in $full) {
    $ym = ($r.date -split '-')[0..1] -join '-'
    $fullByMonth[$ym] = [double]$r.equity
  }
  $ablByMonth = @{}
  foreach ($r in $ablation) {
    $ym = ($r.date -split '-')[0..1] -join '-'
    $ablByMonth[$ym] = [double]$r.equity
  }
  Write-Host ("{0,-8} {1,12} {2,12} {3,12} {4,8}" -f 'month', 'full', 'no_gradual', 'diff', 'ratio%')
  $yms = ($fullByMonth.Keys | Sort-Object)
  foreach ($ym in $yms) {
    if ($ablByMonth.ContainsKey($ym)) {
      $f = $fullByMonth[$ym]
      $a = $ablByMonth[$ym]
      $diff = $a - $f
      $ratio = if ($f -ne 0) { [math]::Round(($a/$f - 1)*100, 1) } else { 0 }
      Write-Host ("{0,-8} {1,12:N0} {2,12:N0} {3,12:N0} {4,7}%" -f $ym, $f, $a, $diff, $ratio)
    }
  }
  Write-Host ''
}
