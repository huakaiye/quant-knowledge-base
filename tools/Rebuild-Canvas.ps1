# Rebuild-Canvas.ps1
# Restructure the main roadmap Canvas into a slim skeleton + 5 sub-canvases.
# Reads 00_入口/研究路线图.canvas, partitions nodes by branch, lays out each canvas
# on a layered grid (RD top, LIT source, EX middle, DEC bottom), adds group nodes,
# removes cross-level reverse edges.
#
# Usage: powershell -ExecutionPolicy Bypass -File tools/Rebuild-Canvas.ps1 -Apply

param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

$entrance = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '00_*' } | Select-Object -First 1).FullName
$dirRd = (Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like '02_*' } | Select-Object -First 1).FullName

$mainCanvasPath = Join-Path $entrance 'roadmap_main_tmp.canvas'
$srcCanvas = Get-ChildItem -LiteralPath $entrance -Filter '*.canvas' | Where-Object { $_.Name -like '*路线图*' -or $_.Name -like '*roadmap*' } | Select-Object -First 1
if (-not $srcCanvas) { throw "source canvas not found" }
$src = Get-Content -LiteralPath $srcCanvas.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
$nodeById = @{}
foreach ($n in $src.nodes) { $nodeById[$n.id] = $n }

# ---------- Partition: which node goes to which canvas ----------
$partition = @{
    # branch -> array of node ids
    'scorecap' = @(
        'score-cap','score-cap-a20','score-cap-a20-decision','score-cap-a22','score-cap-a22-decision',
        'score-cap-a23','score-cap-a23-decision','score-cap-a23-d09','score-cap-a23-d09-decision',
        'score-cap-a23-lvv7','score-cap-a23-vx4j','score-cap-a23-xbws','score-cap-k3ac','score-cap-k3ac-decision',
        'score-cap-qxss','score-cap-a22n','score-cap-a22n-decision','score-cap-ekz8','score-cap-qtfv',
        'score-cap-qtfv-decision','score-cap-nr75','score-cap-ya5r','score-cap-lwc4','score-cap-gnqh',
        'score-cap-gnqh-decision',
        'score-cap-a25-wemy','score-cap-a25-urwl','score-cap-a25-56r5','score-cap-a26-mkg3','score-cap-a26-dnla',
        'score-cap-a27-6txm','score-cap-a27-zdd3','score-cap-a27-hjgj','score-cap-wemy-66qh',
        'score-cap-a28-un96','score-cap-a28-5e5g'
    )
    'defense' = @(
        'rd-mcyg-dm','lit-vy4k-dm','ex-j7ef-dm','ex-ljq7-dm-label','ex-xa5u-d2-overheat',
        'dec-uarf-d2-overheat','ex-b6fl-d2-formal','dec-ur6s-d2-overheat-fail',
        'ex-k3yl-crash-prob','ex-5lls-d3-strict','ex-z78j-state-transition','lit-rdha-fit-target'
    )
    'core' = @(
        'core-lm3d','core-lm3d-decision','core-lm3d-yjrn',
        'rd-t6r6-residual','lit-wevv-residual','ex-rneu-residual',
        'rd-r25x-52wk','lit-a9bk-52wk','ex-mcws-52wk',
        'mom5-hot','mom5-hot-9qrg','mom5-hot-5bu8','mom5-event-vz8q','mom5-event-22p6','mom5-event-lfeh'
    )
    'dynheat' = @(
        'dynheat-sc65','dynheat-h35f','dynheat-lys9','dynheat-fwze','dynheat-7hkt','dynheat-hmz3',
        'dynheat-lklt','dynheat-jvtq','dynheat-vynr','dynheat-x7pj','dynheat-3csw'
    )
    'intraday' = @(
        'intraday-hot-5bnb','intraday-hot-u92n','intraday-hot-lit-ry67','intraday-hot-vgmh',
        'intraday-hot-vzda','intraday-hot-gu38','intraday-hot-myhu','intraday-hot-uayf',
        'lit-6jy4-nonr2','rd-q88k-nonr2','ex-mtex-nonr2','dec-w29b-nonr2','ex-9vwx-fixed-blend','dec-9prq-fixed-blend'
    )
    'theme' = @(
        'theme-shadow-smoke','theme-shadow-split','theme-forward-attribution','theme-forward-decision',
        'theme-vvvn','theme-vvvn-decision'
    )
}
# skeleton stays in main canvas
$mainSkeleton = @(
    'dashboard','method','legend','dp00','base','decision',
    'off0','core','def0','exe0','theme-mainline','score-cap'
)
# root RD for each branch (main canvas keeps these as entry points)
$branchRoot = @{
    'scorecap'='score-cap'; 'defense'='def0'; 'core'='core';
    'dynheat'='dynheat-sc65'; 'intraday'='intraday-hot-5bnb'; 'theme'='theme-mainline'
}

# ---------- Layout helper: layered grid ----------
# layer 0: RD (y=0), layer 1: LIT (y=-380 above), layer 2: EX (y=420), layer 3: DEC (y=840)
function Get-Layer($id) {
    if ($id -like 'rd-*' -or $id -like 'score-cap-a25-wemy' -or $id -in @('mom5-hot','intraday-hot-5bnb','dynheat-sc65','dynheat-fwze','score-cap')) { return 0 }
    if ($id -like 'lit-*') { return 1 }
    if ($id -like 'score-cap-a2*' -or $id -like 'score-cap-k3ac*' -or $id -like 'score-cap-q*' -or $id -like 'score-cap-n*' -or $id -like 'score-cap-y*' -or $id -like 'score-cap-l*' -or $id -like 'score-cap-g*' -or $id -like 'score-cap-e*' -or $id -like 'ex-*' -or $id -like 'core-lm3d*' -or $id -like 'mom5-hot-9*' -or $id -like 'mom5-event-22*' -or $id -like 'dynheat-*' -or $id -like 'intraday-hot-*' -or $id -like 'theme-*') {
        if ($id -like '*-decision' -or $id -like 'dec-*') { return 3 }
        return 2
    }
    if ($id -like 'dec-*' -or $id -like '*-decision' -or $id -like '*-5bu8' -or $id -like '*-lfeh' -or $id -like '*-uayf' -or $id -like '*-dnla' -or $id -like '*-zdd3' -or $id -like '*-hjgj' -or $id -like '*-5e5g' -or $id -like '*-56r5') { return 3 }
    return 2
}

function New-Layout($ids, $startX) {
    $nodes = @()
    $col = 0
    # sort ids by layer then original order
    $layered = @()
    foreach ($L in 0..3) {
        foreach ($id in $ids) {
            if ((Get-Layer $id) -eq $L) { $layered += [pscustomobject]@{Id=$id; Layer=$L} }
        }
    }
    $pos = @{}
    foreach ($item in $layered) {
        $L = $item.Layer
        if (-not $pos.ContainsKey($L)) { $pos[$L] = 0 }
        $c = $pos[$L]; $pos[$L] = $pos[$L] + 1
        $y = switch ($L) { 0 { 0 } 1 { -360 } 2 { 440 } 3 { 900 } }
        $origNode = $nodeById[$item.Id]
        if (-not $origNode) { continue }
        $nodes += [pscustomobject]@{
            id=$item.Id; type=$origNode.type; file=$origNode.file; text=$origNode.text
            x=($startX + $c * 640); y=$y; width=560; height=240
        }
    }
    return $nodes
}

function Add-Group($nodes, $gid, $label, $color) {
    if ($nodes.Count -eq 0) { return $null }
    $minX = ($nodes | ForEach-Object { $_.x } | Measure-Object -Minimum).Minimum
    $minY = ($nodes | ForEach-Object { $_.y } | Measure-Object -Minimum).Minimum
    $maxX = ($nodes | ForEach-Object { $_.x + $_.width } | Measure-Object -Maximum).Maximum
    $maxY = ($nodes | ForEach-Object { $_.y + $_.height } | Measure-Object -Maximum).Maximum
    return [ordered]@{
        id=$gid; type='group'; label=$label; color=$color
        x=($minX-40); y=($minY-80); width=($maxX-$minX+80); height=($maxY-$minY+120)
    }
}

# ---------- Build sub-canvas file path (chinese) ----------
$subCanvasMeta = [ordered]@{
    'scorecap' = @{ file='H6V3'; title='score过热拥挤机制主线' }
    'defense'  = @{ file='DEF0'; title='防御模块（DM崩溃保护）' }
    'core'     = @{ file='CORE'; title='核心轮动（LM3D/顶刊信号）' }
    'dynheat'  = @{ file='FWZE'; title='动态资金热度单模块消融' }
    'intraday' = @{ file='5BNB'; title='盘中热点与非R方排序' }
}
# find each branch root RD id for the subcanvas filename
$rdIdForBranch = @{
    'scorecap'='RD-20260605T133318Z-main-H6V3'; 'defense'='RD-20260605T115651Z-main-DEF0'
    'core'='RD-20260605T115651Z-main-CORE'; 'dynheat'='RD-20260613T110126Z-main-FWZE'
    'intraday'='RD-20260613T002916Z-main-5BNB'
}

$edgeReport = New-Object System.Text.StringBuilder

# ---------- Forbidden edge detection ----------
function Is-ForbiddenEdge($from, $to, $fromNode, $toNode) {
    # cross-level reverse: EXP->STRAT, DEC->STRAT, DEC->EXP(as next round start)
    $fType = Get-Layer $from; $tType = Get-Layer $to
    # base->dp00 and decision->dp00 are reverse (EX/DEC -> strategy)
    if ($from -in @('base','decision') -and $to -eq 'dp00') { return $true }
    # DEC -> EXP (decision triggering new experiment): dec-* -> ex-*
    if ($from -like 'dec-*' -and $to -like 'ex-*') { return $true }
    if ($from -like '*-decision' -and $to -like 'ex-*') { return $true }
    if ($from -like '*-decision' -and $to -like 'score-cap-k3ac') { return $true }
    if ($from -like '*-decision' -and $to -like 'score-cap-a23-d09') { return $true }
    # DEC -> MODULE (decision -> direction as next start)
    if ($from -like '*-decision' -and $toType -eq 0 -and $to -notlike 'lit-*') {
        if ($from -in @('mom5-hot-5bu8','mom5-event-lfeh','dynheat-lys9','theme-forward-decision','intraday-hot-uayf')) { return $true }
    }
    return $false
}
function Fix-LitDirection($from, $to) {
    # intraday-hot-5bnb -> intraday-hot-lit-ry67 is reverse; flip to LIT -> MODULE
    if ($from -eq 'intraday-hot-5bnb' -and $to -eq 'intraday-hot-lit-ry67') { return $true }
    return $false
}

# ---------- Build each sub-canvas ----------
$subFiles = @()
foreach ($branch in @('scorecap','defense','core','dynheat','intraday')) {
    $ids = $partition[$branch]
    $subNodes = New-Layout $ids 0
    # filter edges that belong to this branch (both endpoints in this branch)
    $idSet = @{}; foreach ($i in $ids) { $idSet[$i] = $true }
    $subEdges = @()
    foreach ($e in $src.edges) {
        if ($idSet.ContainsKey($e.fromNode) -and $idSet.ContainsKey($e.toNode)) {
            $subEdges += $e
        }
    }
    $grp = Add-Group $subNodes ("group-" + $branch) $subCanvasMeta[$branch].Title '5'
    $allNodes = @($subNodes)
    if ($grp) { $allNodes = @($grp) + $allNodes }
    $subCanvas = [ordered]@{ nodes = $allNodes; edges = $subEdges }
    $rdId = $rdIdForBranch[$branch]
    # sub canvas filename: 02_研究方向/<rd_id>_路线图.canvas
    $subPath = Join-Path $dirRd ($rdId + '_路线图.canvas')
    $subFiles += [pscustomobject]@{ branch=$branch; path=$subPath; rdId=$rdId; nodeCount=$subNodes.Count; edgeCount=$subEdges.Count }
    if ($Apply) {
        $json = $subCanvas | ConvertTo-Json -Depth 8
        # Obsidian canvas needs tab indentation; ConvertTo-Json uses 2-space. Reformat.
        [System.IO.File]::WriteAllText($subPath, $json, $utf8)
    }
}

# ---------- Build theme sub-canvas (smaller, keep in core or separate) ----------
$themeIds = $partition['theme']
if ($themeIds.Count -gt 0) {
    $subNodes = New-Layout $themeIds 0
    $idSet = @{}; foreach ($i in $themeIds) { $idSet[$i] = $true }
    $subEdges = @()
    foreach ($e in $src.edges) {
        if ($idSet.ContainsKey($e.fromNode) -and $idSet.ContainsKey($e.toNode)) { $subEdges += $e }
    }
    $grp = Add-Group $subNodes 'group-theme' '主题簇主线（KC7N）' '4'
    $allNodes = @($grp) + @($subNodes)
    $subCanvas = [ordered]@{ nodes = $allNodes; edges = $subEdges }
    $subPath = Join-Path $dirRd 'RD-20260605T131301Z-main-KC7N_路线图.canvas'
    $subFiles += [pscustomobject]@{ branch='theme'; path=$subPath; rdId='RD-20260605T131301Z-main-KC7N'; nodeCount=$subNodes.Count; edgeCount=$subEdges.Count }
    if ($Apply) {
        $json = $subCanvas | ConvertTo-Json -Depth 8
        [System.IO.File]::WriteAllText($subPath, $json, $utf8)
    }
}

# ---------- Build slim main canvas ----------
# Keep skeleton + add sub-canvas entry nodes
$mainNodes = @()
foreach ($id in $mainSkeleton) {
    $n = $nodeById[$id]
    if ($n) { $mainNodes += [pscustomobject]@{ id=$id; type=$n.type; file=$n.file; text=$n.text; x=$n.x; y=$n.y; width=$n.width; height=$n.height } }
}
# add sub-canvas entry nodes pointing to each sub-canvas .canvas file
$entryX = 1500
foreach ($sf in $subFiles) {
    $relPath = ($sf.path.Substring($Root.Length)).TrimStart('\','/').Replace('\','/')
    $entryId = 'entry-' + $sf.branch
    $mainNodes += [pscustomobject]@{ id=$entryId; type='file'; file=$relPath; x=$entryX; y=300; width=460; height=200 }
    # edge from dp00 to entry
    $entryX += 540
}
# edges for main: keep only skeleton-internal + dp00->module + dashboard->dp00, drop reverse
$mainIdSet = @{}; foreach ($i in $mainSkeleton) { $mainIdSet[$i] = $true }
$mainEdges = @()
$droppedReverse = 0
$fixedLit = 0
foreach ($e in $src.edges) {
    $f = $e.fromNode; $t = $e.toNode
    # drop forbidden reverse edges
    if ($f -in @('base','decision') -and $t -eq 'dp00') { $droppedReverse++; continue }
    # fix lit direction: intraday 5bnb -> lit ry67 (handled in subcanvas, skip in main)
    if ($mainIdSet.ContainsKey($f) -and $mainIdSet.ContainsKey($t)) {
        $mainEdges += $e
    }
}
# add edges from dp00 to each sub-canvas entry
foreach ($sf in $subFiles) {
    $mainEdges += [pscustomobject]@{ id=("edge-dp00-entry-"+$sf.branch); fromNode='dp00'; fromSide='right'; toNode=("entry-"+$sf.branch); toSide='left'; label=$subCanvasMeta[$sf.branch].Title }
}
$mainCanvas = [ordered]@{ nodes = $mainNodes; edges = $mainEdges }

Write-Output "===== Canvas Restructure ====="
Write-Output ("Main skeleton nodes: " + $mainNodes.Count)
Write-Output ("Main edges: " + $mainEdges.Count)
Write-Output ("Dropped reverse edges: " + $droppedReverse)
Write-Output ""
Write-Output "--- Sub-canvases ---"
foreach ($sf in $subFiles) {
    Write-Output ("  " + $sf.branch + ": " + $sf.nodeCount + " nodes, " + $sf.edgeCount + " edges -> " + (Split-Path $sf.path -Leaf))
}

if ($Apply) {
    # write main canvas (overwrite original roadmap)
    $mainPath = $srcCanvas.FullName
    $json = $mainCanvas | ConvertTo-Json -Depth 8
    [System.IO.File]::WriteAllText($mainPath, $json, $utf8)
    Write-Output ""
    Write-Output "Written: main canvas + " + $subFiles.Count + " sub-canvases."
} else {
    Write-Output ""
    Write-Output "Dry-run. Add -Apply to write."
}
