# Build-ResearchGraph.ps1
# Scan all research assets' frontmatter and build a machine-readable knowledge graph.
# Inspired by codegraph: nodes = assets, edges = frontmatter reference relations.
#
# Outputs:
#   00_入口/研究图谱.json  - machine-readable graph (for agent / tool consumption)
#   00_入口/研究图谱.md    - human-readable handoff summary
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools/Build-ResearchGraph.ps1

param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

# ---------- Resolve Chinese dir names by numeric prefix ----------
function Get-Dir($pattern) {
    $d = Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like $pattern } | Select-Object -First 1
    if (-not $d) { throw "Directory not found for pattern: $pattern" }
    return $d.FullName
}
$dirRd   = Get-Dir '02_*'
$dirStrat = Get-Dir '03_*'
$dirEx   = Get-Dir '04_*'
$dirDec  = Get-Dir '05_*'
$dirLit  = Get-Dir '06_*'
$dirIdea = Get-Dir '07_*'
$dirTerm = Get-Dir '09_*'
$dirEntrance = Get-Dir '00_*'

# ---------- Frontmatter parser ----------
function Get-Fm($content) {
    $m = [regex]::Match($content, "(?s)^---\s*\r?\n(.*?)\r?\n---")
    if (-not $m.Success) { return $null }
    return $m.Groups[1].Value
}
function Get-Val($fm, $field) {
    # [ \t]* instead of \s* so it does not cross newlines (avoids capturing next line when value is empty)
    $m = [regex]::Match($fm, "(?m)^[ \t]*$field[ \t]*:[ \t]*(.*?)\s*$")
    if (-not $m.Success) { return $null }
    return $m.Groups[1].Value.Trim().Trim('"').Trim("'").Trim()
}
function Get-List($fm, $field) {
    # Parse YAML list: inline [a, b] OR multiline items. Line-by-line state machine so
    # config_paths/result_paths/subagent_call_ids are NOT mixed into decision_ids/lit_ids/idea_ids.
    $vals = New-Object System.Collections.Generic.List[string]
    # Inline form: field: [a, b]
    $inline = [regex]::Match($fm, "(?m)^[ \t]*$field[ \t]*:[ \t]*\[(.*?)\][ \t]*$")
    if ($inline.Success -and $inline.Groups[1].Value.Trim() -ne '') {
        foreach ($p in $inline.Groups[1].Value -split ',') {
            $t = $p.Trim().Trim('"').Trim("'").Trim()
            if ($t) { $vals.Add($t) }
        }
        return $vals
    }
    # Multiline: collect "- item" lines immediately after "field:" until next field line.
    $lines = $fm -split "\r?\n"
    $collecting = $false
    foreach ($line in $lines) {
        if (-not $collecting) {
            if ($line -match ("^[ \t]*" + [regex]::Escape($field) + "[ \t]*:[ \t]*$")) {
                $collecting = $true
            }
            continue
        }
        # collecting: only accept indented list items "  - value"
        if ($line -match "^[ \t]+-[ \t]+(.*)$") {
            $t = $Matches[1].Trim().Trim('"').Trim("'").Trim()
            if ($t) { $vals.Add($t) }
        } elseif ($line -match "^[ \t]*\S") {
            # hit a non-empty, non-list line (next field or content) -> stop
            break
        }
    }
    return $vals
}
function Get-Title($content, $fm, $fallbackId) {
    $h1 = [regex]::Match($content, "(?m)^#\s+(.+?)\s*$")
    if ($h1.Success) { return $h1.Groups[1].Value.Trim() }
    $n = Get-Val $fm 'name'
    if ($n) { return $n }
    return $fallbackId
}

# ---------- Collect nodes ----------
$nodes = New-Object System.Collections.Generic.List[object]
$edges = New-Object System.Collections.Generic.List[object]
$nodeIndex = @{}   # id -> node

function Add-Node($id, $type, $title, $status, $extra, $file, $updated) {
    if (-not $id) { return }
    $node = [ordered]@{
        id = $id; type = $type; title = $title; status = $status
        updated_at = $updated; file = $file
    }
    foreach ($k in $extra.Keys) { $node[$k] = $extra[$k] }
    $nodes.Add($node)
    if (-not $nodeIndex.ContainsKey($id)) { $nodeIndex[$id] = $node }
}

function Add-Edge($from, $to, $rel) {
    if (-not $from -or -not $to) { return }
    $edges.Add([ordered]@{ from = $from; to = $to; rel = $rel })
}

# --- RD ---
foreach ($f in (Get-ChildItem -LiteralPath $dirRd -Filter 'RD-*.md' -File)) {
    $c = [System.IO.File]::ReadAllText($f.FullName, $utf8)
    $fm = Get-Fm $c
    if (-not $fm) { continue }
    $id = Get-Val $fm 'rd_id'
    $parent = Get-Val $fm 'parent_rd_id'
    $scope = Get-Val $fm 'scope'
    $status = Get-Val $fm 'status'
    $module = Get-Val $fm 'module_type'
    $updated = Get-Val $fm 'updated_at'
    $cd = Get-Val $fm 'current_decision_id'
    $ce = Get-Val $fm 'current_best_ex_id'
    Add-Node $id 'RD' (Get-Title $c $fm $id) $status ([ordered]@{ parent_rd_id=$parent; scope=$scope; module_type=$module; current_decision_id=$cd; current_best_ex_id=$ce }) $f.Name $updated
    if ($parent) { Add-Edge $id $parent 'parent' }
}

# --- EX ---
foreach ($f in (Get-ChildItem -LiteralPath $dirEx -Filter 'EX-*.md' -File)) {
    $c = [System.IO.File]::ReadAllText($f.FullName, $utf8)
    $fm = Get-Fm $c
    if (-not $fm) { continue }
    $id = Get-Val $fm 'ex_id'
    $rd = Get-Val $fm 'rd_id'
    $status = Get-Val $fm 'status'
    $stage = Get-Val $fm 'stage'
    $updated = Get-Val $fm 'updated_at'
    $decIds = Get-List $fm 'decision_ids'
    $litIds = Get-List $fm 'lit_ids'
    $ideaIds = Get-List $fm 'idea_ids'
    Add-Node $id 'EX' (Get-Title $c $fm $id) $status ([ordered]@{ rd_id=$rd; stage=$stage }) $f.Name $updated
    if ($rd) { Add-Edge $id $rd 'experiment_of' }
    foreach ($d in $decIds) { Add-Edge $id $d 'produced_decision' }
    foreach ($l in $litIds) { Add-Edge $id $l 'lit_source' }
    foreach ($i in $ideaIds) { Add-Edge $id $i 'idea_source' }
}

# --- DEC ---
foreach ($f in (Get-ChildItem -LiteralPath $dirDec -Filter 'DEC-*.md' -File)) {
    $c = [System.IO.File]::ReadAllText($f.FullName, $utf8)
    $fm = Get-Fm $c
    if (-not $fm) { continue }
    $id = Get-Val $fm 'dec_id'
    $decision = Get-Val $fm 'decision'
    $updated = Get-Val $fm 'updated_at'
    $rdIds = Get-List $fm 'rd_ids'
    $exIds = Get-List $fm 'ex_ids'
    Add-Node $id 'DEC' (Get-Title $c $fm $id) $null ([ordered]@{ decision=$decision; rd_ids=($rdIds -join ';'); ex_ids=($exIds -join ';') }) $f.Name $updated
    foreach ($r in $rdIds) { Add-Edge $id $r 'decision_affects' }
    foreach ($e in $exIds) { Add-Edge $id $e 'decision_on_experiment' }
}

# --- LIT ---
foreach ($f in (Get-ChildItem -LiteralPath $dirLit -Recurse -Filter 'LIT-*.md' -File)) {
    $c = [System.IO.File]::ReadAllText($f.FullName, $utf8)
    $fm = Get-Fm $c
    if (-not $fm) { continue }
    $id = Get-Val $fm 'lit_id'
    $status = Get-Val $fm 'status'
    $updated = Get-Val $fm 'updated_at'
    Add-Node $id 'LIT' (Get-Title $c $fm $id) $status @{} $f.Name $updated
}

# --- IDEA/FAC/DATA/MECH ---
foreach ($f in (Get-ChildItem -LiteralPath $dirIdea -Recurse -File -Filter '*.md')) {
    if ($f.Name -like 'README*') { continue }
    $c = [System.IO.File]::ReadAllText($f.FullName, $utf8)
    $fm = Get-Fm $c
    if (-not $fm) { continue }
    $id = Get-Val $fm 'idea_id'
    if (-not $id) { continue }
    $status = Get-Val $fm 'status'
    $updated = Get-Val $fm 'updated_at'
    $t = Get-Val $fm 'type'
    Add-Node $id 'IDEA' (Get-Title $c $fm $id) $status ([ordered]@{ subtype=$t }) $f.Name $updated
}

# --- STRAT ---
foreach ($f in (Get-ChildItem -LiteralPath $dirStrat -Filter 'STRAT-*.md' -File)) {
    $c = [System.IO.File]::ReadAllText($f.FullName, $utf8)
    $fm = Get-Fm $c
    if (-not $fm) { continue }
    $id = Get-Val $fm 'strategy_id'
    $status = Get-Val $fm 'status'
    $updated = Get-Val $fm 'updated_at'
    $rd = Get-Val $fm 'rd_id'
    Add-Node $id 'STRAT' (Get-Val $fm 'name') $status ([ordered]@{ rd_id=$rd }) $f.Name $updated
    if ($rd) { Add-Edge $id $rd 'strategy_of' }
}

# ---------- Dangling edge detection ----------
$dangling = New-Object System.Collections.Generic.List[object]
foreach ($e in $edges) {
    if (-not $nodeIndex.ContainsKey($e.to)) {
        $dangling.Add([ordered]@{ from=$e.from; to=$e.to; rel=$e.rel })
    }
}

# ---------- Summary stats ----------
$byType = @{}
foreach ($n in $nodes) {
    $t = $n.type
    if (-not $byType.ContainsKey($t)) { $byType[$t] = 0 }
    $byType[$t]++
}
$byStatusRd = @{}
foreach ($n in $nodes | Where-Object { $_.type -eq 'RD' }) {
    $s = if ($n.status) { $n.status } else { '(empty)' }
    if (-not $byStatusRd.ContainsKey($s)) { $byStatusRd[$s] = 0 }
    $byStatusRd[$s]++
}
$nowUtc = [DateTime]::UtcNow
$recentDays = 7
$recent = @()
foreach ($n in $nodes) {
    if ($n.updated_at -match '^(\d{4})-(\d{2})-(\d{2})') {
        try {
            $dt = [DateTime]::Parse($n.updated_at, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal)
            if (($nowUtc - $dt).TotalDays -le $recentDays) { $recent += $n }
        } catch {}
    }
}
$recent = $recent | Sort-Object updated_at -Descending

# active directions tree
$activeRds = $nodes | Where-Object { $_.type -eq 'RD' -and $_.status -eq 'active' } | Sort-Object title

# ---------- Write JSON ----------
$graph = [ordered]@{
    generated_at_utc = ($nowUtc.ToString('yyyy-MM-ddTHH:mm:ssZ'))
    summary = [ordered]@{
        node_count = $nodes.Count
        edge_count = $edges.Count
        dangling_edge_count = $dangling.Count
        by_type = $byType
        rd_by_status = $byStatusRd
        recent_change_count_7d = $recent.Count
    }
    active_directions = ($activeRds | ForEach-Object { $_.id })
    nodes = $nodes
    edges = $edges
    dangling_edges = $dangling
    recent_changes_7d = ($recent | Select-Object id, type, title, status, updated_at, file)
}
$jsonPath = Join-Path $dirEntrance 'research_graph.json'
$json = $graph | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($jsonPath, $json, $utf8)

# ---------- Write MD handoff ----------
$sb = New-Object System.Text.StringBuilder
function W($line) { [void]$sb.AppendLine($line) }

W "# 研究知识图谱"
W ""
W ("更新时间：" + $nowUtc.ToString('yyyy-MM-ddTHH:mm:ssZ'))
W ""
W "机器可读图谱：本目录下同名 JSON 文件（供 agent 和工具查询）。本文档为人类可读接手摘要。"
W ""
W "## 概览"
W ""
W "| Metric | Value |"
W "| --- | --- |"
W "| 节点数 | $($nodes.Count) |"
W "| 边数 | $($edges.Count) |"
W "| 悬空边 | $($dangling.Count) |"
W "| 近 7 天变更 | $($recent.Count) |"
W ""
W "### 按类型统计"
W ""
W "| 类型 | 数量 |"
W "| --- | --- |"
foreach ($k in ($byType.Keys | Sort-Object)) { W "| $k | $($byType[$k]) |" }
W ""
W "### RD 按状态统计"
W ""
W "| 状态 | 数量 |"
W "| --- | --- |"
foreach ($k in ($byStatusRd.Keys | Sort-Object)) { W "| $k | $($byStatusRd[$k]) |" }
W ""
W "## 活跃方向（接手入口）"
W ""
W "接手时先看这些方向。每条通过图谱可反向追溯到其最新实验与决策。"
W ""
foreach ($rd in $activeRds) {
    $parentLabel = if ($rd.parent_rd_id) { "（父方向：$($rd.parent_rd_id)）" } else { "（根方向）" }
    W "- **$($rd.id)** $($rd.title)$parentLabel"
    if ($rd.current_best_ex_id) { W "  - 最新实验：$($rd.current_best_ex_id)" }
    if ($rd.current_decision_id) { W "  - 当前决策：$($rd.current_decision_id)" }
}
W ""
W "## 近 7 天变更"
W ""
if ($recent.Count -eq 0) {
W "  （无）"
} else {
W "| ID | 类型 | 标题 | 更新时间 | 文件 |"
W "| --- | --- | --- | --- | --- |"
foreach ($r in ($recent | Select-Object -First 50)) {
    $title = if ($r.title) { $r.title -replace '\|', '/' } else { '' }
    W "| $($r.id) | $($r.type) | $title | $($r.updated_at) | $($r.file) |"
}
}
W ""
W "## 悬空边（schema 完整性警告）"
W ""
W "指向不存在节点的边，表示 frontmatter 引用缺失或 ID 错误。"
W ""
if ($dangling.Count -eq 0) {
W "  （无）—— 全部引用可解析。"
} else {
W "| 来源 | 目标（缺失） | 关系 |"
W "| --- | --- | --- |"
foreach ($d in $dangling) { W "| $($d.from) | $($d.to) | $($d.rel) |" }
}
W ""
W "## Agent 使用方式"
W ""
W "1. 先读本文件获取 1 分钟全局概览。"
W "2. 查询同名 JSON 文件做结构化检索：某节点的邻居、某 RD 下所有 EX、影响某 RD 的所有 DEC、悬空引用。"
W "3. 读 [[00_入口/研究驾驶舱|研究驾驶舱]] 获取叙述性上下文。"
W "4. 资产变更后重新生成：powershell -ExecutionPolicy Bypass -File tools/Build-ResearchGraph.ps1"

$mdPath = Join-Path $dirEntrance 'research_graph.md'
[System.IO.File]::WriteAllText($mdPath, $sb.ToString(), $utf8)

Write-Output "===== Research Graph Built ====="
Write-Output ("Nodes: " + $nodes.Count)
Write-Output ("Edges: " + $edges.Count)
Write-Output ("Dangling edges: " + $dangling.Count)
Write-Output ("Active directions: " + $activeRds.Count)
Write-Output ("Recent changes (7d): " + $recent.Count)
Write-Output ("JSON: " + $jsonPath)
Write-Output ("MD:   " + $mdPath)
