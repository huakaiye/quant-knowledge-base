# Build-ResearchBoard.ps1
# Human-readable research board Canvas (TEXT nodes with conclusions).
# Uses [System.IO.File]::ReadAllText UTF-8 to bypass PS 5.1 Import-Csv UTF-8 bug.
# No Chinese literals -> safe under GBK console.
param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)
$dirLedger = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '01_*' } | Select-Object -First 1).FullName
$dirEntrance = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '00_*' } | Select-Object -First 1).FullName

function Parse-CsvLine($line) {
    $fields = New-Object System.Collections.Generic.List[string]
    $sb = New-Object System.Text.StringBuilder; $inQ = $false
    foreach ($ch in $line.ToCharArray()) {
        if ($ch -eq '"') { $inQ = -not $inQ }
        elseif ($ch -eq ',' -and -not $inQ) { $fields.Add($sb.ToString()); [void]$sb.Clear() }
        else { [void]$sb.Append($ch) }
    }
    $fields.Add($sb.ToString()); return ,$fields
}
function Read-CsvUtf8($path) {
    $content = [System.IO.File]::ReadAllText($path, $utf8)
    $lines = $content -split "`r?`n"
    $header = $null; $rows = New-Object System.Collections.Generic.List[object]
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if (-not $header) { $header = Parse-CsvLine $line; continue }
        $fields = Parse-CsvLine $line; $row = @{}
        for ($i = 0; $i -lt $header.Count -and $i -lt $fields.Count; $i++) { $row[$header[$i].Trim('"')] = $fields[$i] }
        $rows.Add([pscustomobject]$row)
    }
    return ,$rows
}
function Find-Csv($dir, $keyCol) {
    foreach ($cf in (Get-ChildItem -LiteralPath $dir -Filter '*.csv')) {
        $fl = ([System.IO.File]::ReadAllText($cf.FullName, $utf8) -split "`r?`n")[0]
        if ($fl -and $fl.Contains($keyCol)) { return $cf.FullName }
    }
    return $null
}
$exRows = Read-CsvUtf8 (Find-Csv $dirLedger 'ex_id')
$decRows = Read-CsvUtf8 (Find-Csv $dirLedger 'dec_id')
$graphFile = Get-ChildItem -LiteralPath $dirEntrance -Filter '*.json' | Select-Object -First 1
$graph = [System.IO.File]::ReadAllText($graphFile.FullName, $utf8) | ConvertFrom-Json
$rdById = @{}; foreach ($n in $graph.nodes) { if ($n.type -eq 'RD') { $rdById[$n.id] = $n } }
$exByRd = @{}; foreach ($r in $exRows) { if ($r.rd_id) { if (-not $exByRd.ContainsKey($r.rd_id)) { $exByRd[$r.rd_id] = @() }; $exByRd[$r.rd_id] += $r } }
$decByRd = @{}; foreach ($r in $decRows) { $rids = $r.rd_ids -split ';' | Where-Object { $_ }; foreach ($rid in $rids) { if (-not $decByRd.ContainsKey($rid)) { $decByRd[$rid] = @() }; $decByRd[$rid] += $r } }
function Trunc($s, $max) { if (-not $s) { return '' }; if ($s.Length -le $max) { return $s }; return $s.Substring(0, $max) + '...' }
function GetDate($s) { if ($s -and $s -match '^(\d{4}-\d{2}-\d{2})') { return $matches[1] }; return '' }

$nodes = New-Object System.Collections.Generic.List[object]
$edges = New-Object System.Collections.Generic.List[object]
$nodeIndex = @{}
$nowUtc = [DateTime]::UtcNow
$activeRds = $graph.nodes | Where-Object { $_.type -eq 'RD' -and $_.status -eq 'active' } | Sort-Object title
$col = 0; $row = 0; $colW = 780; $rowH = 880
foreach ($rd in $activeRds) {
    $exs = @(); if ($exByRd.ContainsKey($rd.id)) { $exs = $exByRd[$rd.id] | Sort-Object { $_.updated_at_utc } -Descending | Select-Object -First 4 }
    $decs = @(); if ($decByRd.ContainsKey($rd.id)) { $decs = $decByRd[$rd.id] | Sort-Object { $_.updated_at_utc } -Descending | Select-Object -First 2 }
    if ($exs.Count -eq 0 -and $decs.Count -eq 0) { continue }
    $parts = New-Object System.Collections.Generic.List[string]
    $parts.Add("# " + $rd.title)
    $parts.Add("")
    if ($rd.parent_rd_id -and $rdById[$rd.parent_rd_id]) { $parts.Add("> " + $rdById[$rd.parent_rd_id].title); $parts.Add("") }
    if ($rd.current_best_ex_id) { $parts.Add("**focus**: " + $rd.current_best_ex_id) }
    if ($exs.Count -gt 0) {
        $parts.Add(""); $parts.Add("## experiments (" + $exs.Count + ")")
        foreach ($ex in $exs) {
            $d = GetDate $ex.updated_at_utc
            $parts.Add("### " + $d + " " + $ex.name)
            if ($ex.novice_summary) { $parts.Add("- " + (Trunc $ex.novice_summary 200)) }
            if ($ex.next_action) { $parts.Add("- next: " + (Trunc $ex.next_action 120)) }
            $parts.Add("")
        }
    }
    if ($decs.Count -gt 0) {
        $parts.Add("## decisions")
        foreach ($dec in $decs) {
            $parts.Add("### [" + $dec.decision + "] " + $dec.name)
            if ($dec.novice_summary) { $parts.Add("- " + (Trunc $dec.novice_summary 180)) }
            if ($dec.next_action) { $parts.Add("- next: " + (Trunc $dec.next_action 120)) }
            $parts.Add("")
        }
    }
    $text = ($parts -join "`r`n").TrimEnd()
    $nodeId = 'board-' + $rd.id
    $x = $col * $colW; $y = $row * $rowH
    $height = [Math]::Max(400, [Math]::Min(1400, [int]($text.Length / 3) + 200))
    $nodes.Add([pscustomobject]@{ id=$nodeId; type='text'; text=$text; x=$x; y=$y; width=740; height=$height; color='1' })
    $nodeIndex[$rd.id] = $nodeId
    $col++; if ($col -ge 2) { $col = 0; $row++ }
}
foreach ($rd in $activeRds) {
    if ($rd.parent_rd_id -and $nodeIndex.ContainsKey($rd.parent_rd_id) -and $nodeIndex.ContainsKey($rd.id)) {
        $edges.Add([pscustomobject]@{ id=("e-"+$rd.id); fromNode=$nodeIndex[$rd.parent_rd_id]; fromSide='bottom'; toNode=$nodeIndex[$rd.id]; toSide='top' })
    }
}
$todayExs = $exRows | Where-Object { $d = GetDate $_.updated_at_utc; if ($d) { try { ($nowUtc - [DateTime]::Parse($d)).TotalDays -le 3 } catch { $false } } else { $false } } | Sort-Object { $_.updated_at_utc } -Descending | Select-Object -First 12
if ($todayExs.Count -gt 0) {
    $tp = New-Object System.Collections.Generic.List[string]
    $tp.Add("# last 3 days"); $tp.Add("")
    foreach ($ex in $todayExs) {
        $d = GetDate $ex.updated_at_utc; $rdT = ''; if ($ex.rd_id -and $rdById[$ex.rd_id]) { $rdT = $rdById[$ex.rd_id].title }
        $tp.Add("### " + $d + " " + $ex.name)
        if ($rdT) { $tp.Add("dir: " + $rdT) }
        if ($ex.novice_summary) { $tp.Add((Trunc $ex.novice_summary 150)) }
        $tp.Add("")
    }
    $todayText = ($tp -join "`r`n").TrimEnd()
    $nodes.Insert(0, [pscustomobject]@{ id='board-today'; type='text'; text=$todayText; x=-880; y=-460; width=840; height=[Math]::Max(500, [int]($todayText.Length/3)+200); color='4' })
}
$canvas = [ordered]@{ nodes = $nodes; edges = $edges }
$json = $canvas | ConvertTo-Json -Depth 8
$outPath = Join-Path $dirEntrance 'research_board.canvas'
[System.IO.File]::WriteAllText($outPath, $json, $utf8)
Write-Output "===== Research Board Built ====="
Write-Output ("direction nodes: " + @($nodes | Where-Object { $_.id -like 'board-RD-*' }).Count)
Write-Output ("today items: " + $todayExs.Count)
Write-Output ("output: " + $outPath)
