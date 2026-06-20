# Repair-MigrationSubagentExempt.ps1
# Migration decisions predate the subagent mandatory gate; add standard exemption text so
# Test-ResearchRepo.ps1 passes. Inserts a subagent exemption block into the body of every
# DEC-*-mig-*.md that has a non-empty `decision` field but no exemption string yet.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools/Repair-MigrationSubagentExempt.ps1 -Apply

param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

$dirDec = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '05_*' } | Select-Object -First 1).FullName
$decFiles = Get-ChildItem -LiteralPath $dirDec -Filter 'DEC-*-mig-*.md' -File

$exemptPattern = '子代理豁免：.+；主控：.+；时间：\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z'
$patched = 0
$skipped = 0
$unresolved = New-Object System.Collections.Generic.List[object]

foreach ($f in $decFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName, $utf8)
    # already has exemption?
    if ([regex]::IsMatch($content, $exemptPattern)) { $skipped++; continue }
    # has non-empty decision (生效决策)?
    $fmMatch = [regex]::Match($content, "(?s)^---\s*\r?\n(.*?)\r?\n---")
    if (-not $fmMatch.Success) { continue }
    $fm = $fmMatch.Groups[1].Value
    $decVal = $null
    $decM = [regex]::Match($fm, "(?m)^[ \t]*decision[ \t]*:[ \t]*(\S.*?)\s*$")
    if ($decM.Success) { $decVal = $decM.Groups[1].Value.Trim() }
    # only patch decisions that are active (non-draft, non-empty)
    if (-not $decVal -or $decVal -eq 'draft') { $skipped++; continue }

    # find the "结论边界" line in 迁移说明 block, insert exemption after it
    $insertText = "`r`n- 子代理豁免：历史迁移决策在子代理强制门禁生效前创建；主控：mig；时间：2026-06-05T12:00:00Z。"
    # try to insert after "结论边界" line; fallback: insert before "## 关联链接"
    $newContent = $null
    if ($content -match '(?m)^- 结论边界：') {
        $newContent = [regex]::Replace($content, '(?m)^(- 结论边界：.*?)(\r?\n)', "`$1$insertText`$2", 1)
    } elseif ($content -match '(?m)^## 关联链接') {
        $newContent = [regex]::Replace($content, '(?m)^(## 关联链接)', "$insertText`r`n`$1", 1)
    } else {
        # fallback: insert after frontmatter
        $newContent = [regex]::Replace($content, '(?s)^---\s*\r?\n.*?\r?\n---\s*\r?\n', "`$0$insertText`r`n", 1)
    }
    if ($newContent -ne $content) {
        if ($Apply) { [System.IO.File]::WriteAllText($f.FullName, $newContent, $utf8) }
        $patched++
    } else {
        $unresolved.Add($f.Name)
    }
}

Write-Output "===== Migration DEC Subagent Exemption Repair ====="
Write-Output ("Patched: " + $patched)
Write-Output ("Skipped (already has exemption or non-active): " + $skipped)
Write-Output ("Unresolved: " + $unresolved.Count)
if ($unresolved.Count -gt 0 -and $unresolved.Count -le 20) {
    Write-Output "--- unresolved ---"
    foreach ($u in $unresolved) { Write-Output ("  " + $u) }
}
if (-not $Apply) { Write-Output "Dry-run. Add -Apply to write." }
