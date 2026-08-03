# Repair-LedgerFormat.ps1
# Normalize all ledger CSVs in 01_台账/:
#   1. Strip BOM -> UTF-8 no BOM (consistent with 研究方向台账.csv)
#   2. file column: backslash -> forward slash
#   3. *_at_utc columns: +08:00 offset -> Z (convert to UTC)
#   4. Trim trailing empty lines
# Dry-run by default; add -Apply to write.
#
# Usage:
#   pwsh -NoProfile -File tools/Repair-LedgerFormat.ps1
#   pwsh -NoProfile -File tools/Repair-LedgerFormat.ps1 -Apply

param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$dirLedger = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '01_*' } | Select-Object -First 1).FullName
$csvFiles = Get-ChildItem -LiteralPath $dirLedger -Filter '*.csv' -File

function Convert-TzToUtc {
    param([string]$val)
    if (-not $val) { return $val }
    $v = $val.Trim().Trim('"').Trim("'")
    # Only convert values with explicit +HH:MM offset (not already Z, not date-only)
    if ($v -match '^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})([+-]\d{2}:\d{2})$') {
        try {
            $dto = [DateTimeOffset]::Parse($v, [System.Globalization.CultureInfo]::InvariantCulture)
            $utc = $dto.ToUniversalTime()
            return $utc.ToString('yyyy-MM-ddTHH:mm:ssZ', [System.Globalization.CultureInfo]::InvariantCulture)
        } catch {
            return $val
        }
    }
    return $val
}

function Normalize-Backslash {
    param([string]$val)
    if (-not $val) { return $val }
    return $val.Replace('\', '/')
}

$totalChanges = 0
$report = New-Object System.Text.StringBuilder

foreach ($csv in $csvFiles) {
    $rows = Import-Csv -LiteralPath $csv.FullName -Encoding UTF8
    if ($rows.Count -eq 0) { continue }
    $cols = $rows[0].PSObject.Properties.Name
    $fileCol = $null
    foreach ($c in $cols) { if ($c -ieq 'file' -or $c -ieq 'new_relative_path' -or $c -ieq 'old_relative_path') { } }
    # find the file/path column name (case-insensitive 'file' preferred)
    $fileColName = $cols | Where-Object { $_ -ieq 'file' } | Select-Object -First 1
    $tzCols = $cols | Where-Object { $_ -match '_at_utc$' -or $_ -eq 'timestamp' }
    $changeCount = 0

    foreach ($row in $rows) {
        if ($fileColName -and $row.$fileColName) {
            $orig = $row.$fileColName
            $new = Normalize-Backslash $orig
            if ($orig -ne $new) { $row.$fileColName = $new; $changeCount++ }
        }
        foreach ($tc in $tzCols) {
            if ($row.$tc) {
                $orig = $row.$tc
                $new = Convert-TzToUtc $orig
                if ($orig -ne $new) { $row.$tc = $new; $changeCount++ }
            }
        }
    }

    # Serialize back to CSV text, UTF-8 no BOM, trim trailing empty lines
    $csvText = ($rows | ConvertTo-Csv -NoTypeInformation) -join "`r`n"
    $csvText = $csvText.TrimEnd() + "`r`n"

    if ($Apply) {
        [System.IO.File]::WriteAllText($csv.FullName, $csvText, $utf8NoBom)
    }
    [void]$report.AppendLine(($csv.Name + ": " + $changeCount + " cell changes" + $(if ($Apply) { " [written]" } else { " [dry-run]" })))
    $totalChanges += $changeCount
}

Write-Output "===== Ledger Format Repair ====="
Write-Output ("Total cell changes: " + $totalChanges)
Write-Output ("Mode: " + $(if ($Apply) { 'Apply' } else { 'Dry-run' }))
Write-Output ""
Write-Output $report.ToString()
if (-not $Apply) {
    Write-Output "Add -Apply to write changes."
}
