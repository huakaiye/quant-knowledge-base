Write-Warning '历史只读工具：只读取 V1.4 summary，不代表当前 V2 结果。'
$legacyRoot = & pwsh -NoProfile -File "$PSScriptRoot\Get-QuantPlatformRoot.ps1" -Target LegacyPlatform -Format Windows
$base = Join-Path $legacyRoot 'results\v2\research\R010-DEFENSE\rule_a_idle\EX-20260627T053730Z-main-JTX7'
$dirs = @(
  'decade5_fixed\a2_trend',
  'decade5_fixed\baseline_hard5',
  'decade5_fixed\ra5_instant',
  'formal\trend_break\cost2x_11yr_a2',
  'formal\trend_break\cost2x_11yr_baseline',
  'formal\trend_break\cost2x_11yr_ra5'
)
foreach ($d in $dirs) {
  $p = Join-Path $base $d
  Write-Host "### $d"
  if (Test-Path $p) {
    $f = Get-ChildItem $p -Filter 'summary.json' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($f) {
      Get-Content $f.FullName -Encoding UTF8 -Raw
    } else {
      Write-Host '  NO summary.json. Files in dir:'
      Get-ChildItem $p -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "    $($_.Name)" }
      Write-Host '  Subdirs:'
      Get-ChildItem $p -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "    [D] $($_.Name)" }
    }
  } else {
    Write-Host '  PATH NOT FOUND'
  }
  Write-Host ''
}
