$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$entrance = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '00_*' } | Select-Object -First 1).FullName
$canvases = @(Get-ChildItem -LiteralPath $entrance -Filter '*.canvas')
$board = $null
foreach ($cf in $canvases) {
    $c = Get-Content -LiteralPath $cf.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    $hasToday = $false
    foreach ($n in $c.nodes) { if ($n.id -eq 'board-today') { $hasToday = $true; break } }
    if ($hasToday) { $board = $cf; break }
}
Write-Output ("board file: " + $board.Name)
$c = Get-Content -LiteralPath $board.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Output ("nodes: " + $c.nodes.Count)
Write-Output "===== TODAY NODE ====="
foreach ($n in $c.nodes) { if ($n.id -eq 'board-today') { Write-Output $n.text } }
Write-Output ""
Write-Output "===== H6V3 NODE ====="
foreach ($n in $c.nodes) { if ($n.id -like '*H6V3*') { Write-Output $n.text } }
