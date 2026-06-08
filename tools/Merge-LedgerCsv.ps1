param(
    [Parameter(Mandatory = $true)]
    [string]$RepoPath,

    [string]$Root = '',

    [switch]$StageResult
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

Set-Location -LiteralPath $Root

$normalizedPath = $RepoPath -replace '\\', '/'
if ($normalizedPath -notmatch '^01_[^/]+/.+\.csv$') {
    throw "Only ledger CSV files under 01_* can be auto-merged: $RepoPath"
}

function Get-GitStageText {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Stage,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $stageSpec = ":${Stage}:$Path"
    $output = & git show $stageSpec 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $null
    }
    return (($output | ForEach-Object { [string]$_ }) -join "`n")
}

function Get-CsvHeaders {
    param([string[]]$Lines)

    if ($Lines.Count -eq 0) {
        return @()
    }
    return @($Lines[0].Split(',') | ForEach-Object { $_.Trim().Trim('"') })
}

function Convert-StageCsv {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return [pscustomobject]@{
            Headers = @()
            Rows = @()
        }
    }

    $lines = @(
        $Text -split "`r?`n" |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_) -and
                $_ -notmatch '^(<<<<<<<|=======|>>>>>>>)'
            }
    )

    if ($lines.Count -eq 0) {
        return [pscustomobject]@{
            Headers = @()
            Rows = @()
        }
    }

    $headers = Get-CsvHeaders -Lines $lines
    $cleanText = $lines -join "`n"
    $rows = @($cleanText | ConvertFrom-Csv)

    return [pscustomobject]@{
        Headers = $headers
        Rows = $rows
    }
}

function Convert-RowToMap {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Row,

        [Parameter(Mandatory = $true)]
        [string[]]$Headers
    )

    $map = @{}
    foreach ($header in $Headers) {
        $property = $Row.PSObject.Properties[$header]
        if ($null -eq $property -or $null -eq $property.Value) {
            $map[$header] = ''
        } else {
            $map[$header] = [string]$property.Value
        }
    }
    return $map
}

function Get-RowTimestamp {
    param([hashtable]$Row)

    foreach ($key in @('updated_at_utc', 'updated_at', 'timestamp_utc', 'completed_at_utc', 'created_at_utc', 'started_at_utc', 'date')) {
        if ($Row.ContainsKey($key) -and -not [string]::IsNullOrWhiteSpace($Row[$key])) {
            return [string]$Row[$key]
        }
    }
    return ''
}

function Get-FilledFieldCount {
    param([hashtable]$Row)

    $count = 0
    foreach ($value in $Row.Values) {
        if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
            $count += 1
        }
    }
    return $count
}

function Merge-Row {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Existing,

        [Parameter(Mandatory = $true)]
        [hashtable]$Incoming,

        [Parameter(Mandatory = $true)]
        [string[]]$Headers
    )

    $existingTimestamp = Get-RowTimestamp -Row $Existing
    $incomingTimestamp = Get-RowTimestamp -Row $Incoming

    $preferIncoming = $false
    if ($incomingTimestamp -and $existingTimestamp) {
        $preferIncoming = ($incomingTimestamp -ge $existingTimestamp)
    } elseif ($incomingTimestamp -and -not $existingTimestamp) {
        $preferIncoming = $true
    } elseif (-not $incomingTimestamp -and -not $existingTimestamp) {
        $preferIncoming = ((Get-FilledFieldCount -Row $Incoming) -ge (Get-FilledFieldCount -Row $Existing))
    }

    if ($preferIncoming) {
        $primary = $Incoming
        $secondary = $Existing
    } else {
        $primary = $Existing
        $secondary = $Incoming
    }

    $result = @{}
    foreach ($header in $Headers) {
        $value = ''
        if ($primary.ContainsKey($header)) {
            $value = [string]$primary[$header]
        }
        if ([string]::IsNullOrWhiteSpace($value) -and $secondary.ContainsKey($header)) {
            $value = [string]$secondary[$header]
        }
        $result[$header] = $value
    }
    return $result
}

$oursText = Get-GitStageText -Stage 2 -Path $normalizedPath
$theirsText = Get-GitStageText -Stage 3 -Path $normalizedPath

if ([string]::IsNullOrWhiteSpace($oursText) -and [string]::IsNullOrWhiteSpace($theirsText)) {
    throw "Cannot read conflicted Git stages for: $normalizedPath"
}

$ours = Convert-StageCsv -Text $oursText
$theirs = Convert-StageCsv -Text $theirsText

$headers = New-Object System.Collections.Generic.List[string]
foreach ($header in @($ours.Headers + $theirs.Headers)) {
    if (-not [string]::IsNullOrWhiteSpace($header) -and -not $headers.Contains($header)) {
        [void]$headers.Add($header)
    }
}

if ($headers.Count -eq 0) {
    throw "CSV header not found: $normalizedPath"
}

$keyField = $headers[0]
$mergedRows = @{}
$order = New-Object System.Collections.Generic.List[string]

foreach ($row in @($ours.Rows + $theirs.Rows)) {
    $map = Convert-RowToMap -Row $row -Headers $headers
    $key = ''
    if ($map.ContainsKey($keyField)) {
        $key = ([string]$map[$keyField]).Trim()
    }

    if ([string]::IsNullOrWhiteSpace($key) -or $key -eq $keyField -or $key -match '^(<<<<<<<|=======|>>>>>>>)') {
        continue
    }

    if ($mergedRows.ContainsKey($key)) {
        $mergedRows[$key] = Merge-Row -Existing $mergedRows[$key] -Incoming $map -Headers $headers
    } else {
        $mergedRows[$key] = $map
        [void]$order.Add($key)
    }
}

$objects = foreach ($key in $order) {
    $ordered = [ordered]@{}
    foreach ($header in $headers) {
        $ordered[$header] = [string]$mergedRows[$key][$header]
    }
    [pscustomobject]$ordered
}

$targetPath = Join-Path $Root $normalizedPath
$csvLines = @($objects | ConvertTo-Csv -NoTypeInformation)
if ($csvLines.Count -eq 0) {
    $csvLines = @(($headers | ForEach-Object { '"' + ($_ -replace '"', '""') + '"' }) -join ',')
}

[System.IO.File]::WriteAllText($targetPath, ($csvLines -join "`n") + "`n", [System.Text.UTF8Encoding]::new($false))

if ($StageResult) {
    & git add -- $normalizedPath
    if ($LASTEXITCODE -ne 0) {
        throw "git add failed: $normalizedPath"
    }
}

Write-Output "Merged ledger CSV by $keyField`: $normalizedPath rows=$($order.Count)"
