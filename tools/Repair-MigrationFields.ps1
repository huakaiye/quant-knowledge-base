# Repair-MigrationFields.ps1
# Batch-repair frontmatter for migration files (EX/DEC/RD with -mig- in name).
# Maps legacy direction_id to new RD via tools/legacy_to_rd_map.csv.
# Dry-run by default; add -Apply to write.
#
# Usage:
#   pwsh -NoProfile -File tools/Repair-MigrationFields.ps1
#   pwsh -NoProfile -File tools/Repair-MigrationFields.ps1 -Apply

param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# ---------- 1. Resolve Chinese directory names by numeric prefix ----------
# Avoid Chinese literals in source so PowerShell 5.1 (GBK default) can parse this file.
$dirEx    = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '04_*' } | Select-Object -First 1).FullName
$dirDec   = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '05_*' } | Select-Object -First 1).FullName
$dirRd    = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '02_*' } | Select-Object -First 1).FullName

# ---------- 1b. Load mapping table ----------
$mapPath = Join-Path $Root 'tools/legacy_to_rd_map.csv'
if (-not (Test-Path -LiteralPath $mapPath)) {
    throw "Mapping table not found: $mapPath"
}
$mapRows = Import-Csv -LiteralPath $mapPath -Encoding UTF8
$exactMap = @{}
$prefixList = @()
foreach ($r in $mapRows) {
    $key = $r.legacy_direction_id.Trim()
    if ($key -notmatch '[*]') { $exactMap[$key] = $r.target_rd_id }
    $prefixList += [pscustomobject]@{ Key = $key; Target = $r.target_rd_id }
}
$prefixList = $prefixList | Sort-Object { $_.Key.Length } -Descending

function Resolve-RdId {
    param([string]$LegacyDir, [string]$LegacyId, [string]$FileName)
    $candidates = @()
    if ($LegacyDir) { $candidates += $LegacyDir }
    if ($LegacyId) { $candidates += $LegacyId }
    if ($FileName) {
        foreach ($m in [regex]::Matches($FileName, 'R\d+-[A-Z]\d*(?:[A-Z]\d*)?|M\d{3}|S\d{8}-\d{3}|INTRADAY-EXECUTION|MULTI-STATE-ATTRIBUTION')) {
            $candidates += $m.Value
        }
        foreach ($m in [regex]::Matches($FileName, 'R010([A-Z]\d*(?:[A-Z]\d*)?)')) {
            $candidates += 'R010-' + $m.Groups[1].Value
        }
    }
    # Also extract compact fragments embedded in legacy_id (e.g. D20260601-R010B3-gate -> R010-B3)
    $haystack = "$LegacyId $FileName"
    foreach ($m in [regex]::Matches($haystack, 'R010([A-Z]\d*(?:[A-Z]\d*)?)')) {
        $candidates += 'R010-' + $m.Groups[1].Value
    }
    foreach ($m in [regex]::Matches($haystack, 'R020([A-Z])')) {
        $candidates += 'R020-' + $m.Groups[1].Value
    }
    foreach ($m in [regex]::Matches($haystack, 'R026([A-Z])')) {
        $candidates += 'R026-' + $m.Groups[1].Value
    }
    foreach ($m in [regex]::Matches($haystack, 'M\d{3}')) {
        $candidates += $m.Value
        $candidates += 'MULTI-STATE-ATTRIBUTION'
    }
    foreach ($m in [regex]::Matches($haystack, 'INTRADAY')) {
        $candidates += 'INTRADAY-EXECUTION'
    }
    foreach ($m in [regex]::Matches($haystack, 'R014|R015|R029')) {
        $candidates += 'R010-B'   # R014/R015 drawdown-defense series -> R010-B defense
    }
    foreach ($m in [regex]::Matches($haystack, 'MiniQMT|miniqmt')) {
        $candidates += 'R010-B4'  # MiniQMT default-off mapping belongs to B3Gate engineering
    }
    foreach ($m in [regex]::Matches($haystack, 'A2SLOPE004|A2-slope004')) {
        $candidates += 'R010-A'   # A2-slope004 offense base
    }
    foreach ($c in $candidates) {
        $c = $c.Trim().Trim('"')
        if ($exactMap.ContainsKey($c)) { return $exactMap[$c] }
    }
    foreach ($c in $candidates) {
        $c = $c.Trim().Trim('"')
        foreach ($p in $prefixList) {
            if ($c -eq $p.Key -or $c.StartsWith($p.Key)) { return $p.Target }
            if ($p.Key.StartsWith($c) -and $c.Length -ge 4) { return $p.Target }
        }
    }
    return $null
}

# ---------- 2. Frontmatter helpers ----------
function Get-Frontmatter {
    param([string]$Content)
    $m = [regex]::Match($Content, "(?s)^---\s*\r?\n(.*?)\r?\n---")
    if (-not $m.Success) { return $null }
    return $m.Groups[1].Value
}
function Get-FieldValue {
    param([string]$Frontmatter, [string]$Field)
    $m = [regex]::Match($Frontmatter, "(?m)^\s*$Field\s*:\s*(.*?)\s*$")
    if ($m.Success) { return $m.Groups[1].Value.Trim('"').Trim("'").Trim() }
    return $null
}
function Get-LegacyDirectionIdFromBody {
    param([string]$Content)
    $m = [regex]::Match($Content, "(?s)~~~ya?ml\s*\r?\n(.*?)\r?\n~~~")
    if ($m.Success) {
        $block = $m.Groups[1].Value
        # Match: direction_id: "R010-B5"  OR  direction_id: R009  (value is alphanumeric with - and _)
        $dm = [regex]::Match($block, '(?m)^\s*direction_id\s*:\s*"?([A-Za-z0-9_-]+)"?\s*$')
        if ($dm.Success) { return $dm.Groups[1].Value }
    }
    return $null
}
function Has-Field {
    param([string]$Frontmatter, [string]$Field)
    return [regex]::IsMatch($Frontmatter, "(?m)^\s*$Field\s*:\s*\S")
}

# ---------- 3. Build repair plan ----------
$plan = New-Object System.Collections.Generic.List[object]
$unresolved = New-Object System.Collections.Generic.List[object]

# 3a. Migration experiments EX-*-mig-*
$exFiles = Get-ChildItem -LiteralPath $dirEx -Filter 'EX-*-mig-*.md' -File
foreach ($f in $exFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName, $utf8NoBom)
    $fm = Get-Frontmatter -Content $content
    if (-not $fm) { continue }
    $exId = Get-FieldValue -Frontmatter $fm -Field 'ex_id'
    $legacyId = Get-FieldValue -Frontmatter $fm -Field 'legacy_id'
    $legacyDir = Get-LegacyDirectionIdFromBody -Content $content
    $hasRdId = Has-Field -Frontmatter $fm -Field 'rd_id'
    $hasStage = Has-Field -Frontmatter $fm -Field 'stage'
    if ($hasRdId -and $hasStage) { continue }
    $targetRd = Resolve-RdId -LegacyDir $legacyDir -LegacyId $legacyId -FileName $f.Name
    if (-not $targetRd) {
        $unresolved.Add([pscustomobject]@{ File = $f.Name; Type = 'EX'; id = $exId; legacy = $legacyId; dir = $legacyDir })
        continue
    }
    $adds = @()
    if (-not $hasRdId) { $adds += "rd_id: $targetRd" }
    if (-not $hasStage) { $adds += 'stage: legacy_raw' }
    $plan.Add([pscustomobject]@{ File = $f.FullName; Type = 'EX'; id = $exId; Adds = $adds; legacy = $legacyId; dir = $legacyDir; target = $targetRd })
}

# 3b. Migration decisions DEC-*-mig-*
$decFiles = Get-ChildItem -LiteralPath $dirDec -Filter 'DEC-*-mig-*.md' -File
foreach ($f in $decFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName, $utf8NoBom)
    $fm = Get-Frontmatter -Content $content
    if (-not $fm) { continue }
    $decId = Get-FieldValue -Frontmatter $fm -Field 'dec_id'
    $legacyId = Get-FieldValue -Frontmatter $fm -Field 'legacy_id'
    $hasRdIds = Has-Field -Frontmatter $fm -Field 'rd_ids'
    $hasDecision = Has-Field -Frontmatter $fm -Field 'decision'
    if ($hasRdIds -and $hasDecision) { continue }
    $targetRd = Resolve-RdId -LegacyDir $null -LegacyId $legacyId -FileName $f.Name
    if (-not $targetRd) {
        $unresolved.Add([pscustomobject]@{ File = $f.Name; Type = 'DEC'; id = $decId; legacy = $legacyId; dir = '' })
        continue
    }
    $adds = @()
    if (-not $hasRdIds) { $adds += "rd_ids: [$targetRd]" }
    if (-not $hasDecision) { $adds += 'decision: observe' }
    $plan.Add([pscustomobject]@{ File = $f.FullName; Type = 'DEC'; id = $decId; Adds = $adds; legacy = $legacyId; dir = ''; target = $targetRd })
}

# 3c. Migration directions RD-*-mig-* (add parent_rd_id)
$rdParentMap = @{
    'RD-20260523T000000Z-mig-BLF20260523001134E1' = 'RD-20260605T115651Z-main-DEF0'
    'RD-20260523T000000Z-mig-BLF20260523002F8A70' = 'RD-20260605T115651Z-main-OFF0'
    'RD-20260528T000000Z-mig-BLF20260528004996F7' = 'RD-20260605T115651Z-main-DEF0'
    'RD-20260603T000000Z-mig-ETF7D5F7'            = 'RD-20260605T115651Z-main-DEF0'
    'RD-20260603T000000Z-mig-HD5EEBAA8D5EEB'      = ''
    'RD-20260603T000000Z-mig-H95AC6BBA95AC6'      = 'RD-20260605T115651Z-main-DEF0'
    'RD-20260603T000000Z-mig-TOP1BB4BE'           = 'RD-20260605T115651Z-main-OFF0'
    'RD-20260603T000000Z-mig-H8F6635B58F663'      = 'RD-20260605T115651Z-main-DEF0'
    'RD-20260604T000000Z-mig-ETFE8991'            = 'RD-20260605T115651Z-main-DEF0'
    'RD-20260605T000000Z-mig-R010AF00BB'          = 'RD-20260605T115651Z-main-OFF0'
    'RD-20260603T000000Z-mig-H35F08B9535F08'      = ''
}
$rdFiles = Get-ChildItem -LiteralPath $dirRd -Filter 'RD-*-mig-*.md' -File
foreach ($f in $rdFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName, $utf8NoBom)
    $fm = Get-Frontmatter -Content $content
    if (-not $fm) { continue }
    $rdId = Get-FieldValue -Frontmatter $fm -Field 'rd_id'
    $hasParent = Has-Field -Frontmatter $fm -Field 'parent_rd_id'
    if ($hasParent) { continue }
    if (-not $rdParentMap.ContainsKey($rdId)) {
        $unresolved.Add([pscustomobject]@{ File = $f.Name; Type = 'RD'; id = $rdId; legacy = ''; dir = '' })
        continue
    }
    $parent = $rdParentMap[$rdId]
    $plan.Add([pscustomobject]@{ File = $f.FullName; Type = 'RD'; id = $rdId; Adds = @("parent_rd_id: $parent"); legacy = ''; dir = ''; target = $parent })
}

# ---------- 4. Preview ----------
Write-Output "===== Migration Repair Preview ====="
Write-Output ("Files to repair: " + $plan.Count)
Write-Output ("Unresolved (need manual review): " + $unresolved.Count)
Write-Output ""
Write-Output "--- By type ---"
$plan | Group-Object Type | ForEach-Object { Write-Output ("  $($_.Name): $($_.Count)") }
Write-Output ""
Write-Output "--- Unresolved ---"
if ($unresolved.Count -eq 0) {
    Write-Output "  (none)"
} else {
    foreach ($u in $unresolved) {
        Write-Output ("  [$($u.Type)] $($u.File)  legacy=$($u.legacy)  dir=$($u.dir)")
    }
}
Write-Output ""
Write-Output "--- Detail (first 40) ---"
$shown = 0
foreach ($p in $plan) {
    if ($shown -ge 40) { Write-Output ("  ...(" + ($plan.Count - 40) + " more)"); break }
    Write-Output ("  [$($p.Type)] $($p.id)  -> $($p.target)")
    foreach ($a in $p.Adds) { Write-Output ("        + $a") }
    $shown++
}

# ---------- 5. Write ----------
if (-not $Apply) {
    Write-Output ""
    Write-Output "Dry-run mode: no files modified. Add -Apply to write."
    return
}
Write-Output ""
Write-Output "===== Writing ====="
$written = 0
foreach ($p in $plan) {
    $content = [System.IO.File]::ReadAllText($p.File, $utf8NoBom)
    $endMatch = [regex]::Match($content, "(?s)^(---\s*\r?\n.*?\r?\n)(---)(\s*\r?\n)")
    if (-not $endMatch.Success) {
        Write-Warning ("Skip (frontmatter end not found): " + $p.File)
        continue
    }
    $insertLines = ($p.Adds -join "`r`n") + "`r`n"
    $newFmBlock = $endMatch.Groups[1].Value + $insertLines + "---" + $endMatch.Groups[3].Value
    $newContent = $content.Substring(0, $endMatch.Index) + $newFmBlock + $content.Substring($endMatch.Index + $endMatch.Value.Length)
    [System.IO.File]::WriteAllText($p.File, $newContent, $utf8NoBom)
    $written++
}
Write-Output ("Wrote $written files.")
Write-Output "Next: run Invoke-RepoAudit.ps1 to verify schema consistency."
