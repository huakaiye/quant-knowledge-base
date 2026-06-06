param(
    [string]$OldRoot = 'E:\【笔记库】\量化研究库',
    [string]$NewRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$WhatIfOnly
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Get-RelativePathCompat {
    param([string]$Base, [string]$Path)
    $prefix = $Base.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if ($Path.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($prefix.Length)
    }
    return $Path
}

function Convert-ToSafeFileName {
    param([string]$Name)
    $safe = $Name -replace '[\\/:*?"<>|]', ''
    $safe = $safe -replace '\s+', ''
    if ($safe.Length -gt 60) {
        $safe = $safe.Substring(0, 60)
    }
    if ([string]::IsNullOrWhiteSpace($safe)) {
        return '未命名'
    }
    return $safe
}

function Get-ShortHash {
    param([string]$Text, [int]$Length = 8)
    $sha = [System.Security.Cryptography.SHA1]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hashBytes = $sha.ComputeHash($bytes)
    $hex = -join ($hashBytes | ForEach-Object { $_.ToString('x2') })
    return $hex.Substring(0, $Length).ToUpperInvariant()
}

function Get-OldFrontmatterAndBody {
    param([string]$Content)
    $match = [regex]::Match($Content, "(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n?(.*)$")
    if ($match.Success) {
        return @{
            Frontmatter = $match.Groups[1].Value.Trim()
            Body = $match.Groups[2].Value.TrimStart()
        }
    }
    return @{
        Frontmatter = ''
        Body = $Content
    }
}

function Get-FrontmatterValue {
    param([string]$Frontmatter, [string]$Key)
    $match = [regex]::Match($Frontmatter, "(?m)^\s*$([regex]::Escape($Key))\s*:\s*[""']?([^""'\r\n]+)[""']?\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }
    return ''
}

function Get-TitleFromBody {
    param([string]$Body, [string]$Fallback)
    $match = [regex]::Match($Body, "(?m)^\s*#\s+(.+?)\s*$")
    if ($match.Success) {
        return ($match.Groups[1].Value.Trim() -replace '[`#\[\]]', '')
    }
    return $Fallback
}

function Get-DatePart {
    param([string]$OldId, [datetime]$FallbackTime)
    $digits = [regex]::Match($OldId, '(\d{8})')
    if ($digits.Success) {
        return $digits.Groups[1].Value
    }
    return $FallbackTime.ToUniversalTime().ToString('yyyyMMdd')
}

function Get-MigrationKind {
    param([string]$TopFolder, [string]$FileName)

    if ($TopFolder -eq '🧪 实验' -and $FileName -notmatch '模板|说明') {
        return @{ Prefix = 'EX'; IdField = 'ex_id'; TypeName = '实验记录'; TargetDir = '04_实验记录'; Ledger = '实验台账.csv'; Kind = 'experiment' }
    }
    if ($TopFolder -eq '🔀 决策' -and $FileName -notmatch '说明|模板') {
        return @{ Prefix = 'DEC'; IdField = 'dec_id'; TypeName = '研究决策'; TargetDir = '05_研究决策'; Ledger = '决策台账.csv'; Kind = 'decision' }
    }
    if ($TopFolder -eq '🧭 方向') {
        return @{ Prefix = 'RD'; IdField = 'rd_id'; TypeName = '研究方向'; TargetDir = '02_研究方向'; Ledger = '研究方向台账.csv'; Kind = 'direction' }
    }
    if ($TopFolder -eq '🏷️ 策略') {
        return @{ Prefix = 'STRAT'; IdField = 'strategy_id'; TypeName = '策略档案'; TargetDir = '03_策略档案'; Ledger = '策略资产台账.csv'; Kind = 'strategy' }
    }
    if ($TopFolder -eq '📚 文献') {
        return @{ Prefix = 'LIT'; IdField = 'lit_id'; TypeName = '文献卡'; TargetDir = '06_文献资料/08_已归档'; Ledger = '文献台账.csv'; Kind = 'literature' }
    }
    if ($TopFolder -eq '💡 想法') {
        return @{ Prefix = 'IDEA'; IdField = 'idea_id'; TypeName = '因子数据灵感'; TargetDir = '07_因子数据灵感/04_模块'; Ledger = ''; Kind = 'idea' }
    }
    if ($TopFolder -eq '📖 概念') {
        return @{ Prefix = 'TERM'; IdField = 'term_id'; TypeName = '术语'; TargetDir = '09_术语库'; Ledger = '术语台账.csv'; Kind = 'term' }
    }
    return @{ Prefix = 'MIG'; IdField = 'mig_id'; TypeName = '旧库迁移归档'; TargetDir = '12_归档/旧库迁移原文'; Ledger = ''; Kind = 'archive' }
}

function Get-OldId {
    param([string]$Frontmatter, [string]$FileBase, [string]$Kind)
    foreach ($key in @('research_id', 'decision_id', 'direction_id', 'lit_id', 'idea_id', 'strategy_id', 'term_id')) {
        $value = Get-FrontmatterValue -Frontmatter $Frontmatter -Key $key
        if (-not [string]::IsNullOrWhiteSpace($value) -and $value -ne 'N/A') {
            return $value.Trim('"')
        }
    }
    $match = [regex]::Match($FileBase, '^(R\d{8}-\d+|D\d{8}[-_][^_]+|BLF\d{8}-\d+|I\d{8}-\d+|[A-Z]\d{3,}[-_][^_]+)')
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return $FileBase
}

function New-MigratedContent {
    param(
        [hashtable]$Kind,
        [string]$NewId,
        [string]$Title,
        [string]$OldId,
        [string]$SourceOldPath,
        [string]$RelativeOldPath,
        [string]$OldFrontmatter,
        [string]$OldBody,
        [string]$CreatedAt,
        [string]$DirectionLink,
        [string]$StrategyLink
    )

    $idField = $Kind.IdField
    $typeName = $Kind.TypeName
    $yamlSource = $SourceOldPath.Replace("'", "''")
    $yamlRelative = ($RelativeOldPath -replace '\\', '/').Replace("'", "''")
    $migrationCardLink = '[[11_迁移暂存/MIG-20260605T120000Z-mig-BATCH_旧库批量迁移总卡|旧库批量迁移总卡]]'
    $directionLine = if ($DirectionLink) { "- 关联方向：$DirectionLink" } else { "- 关联方向：待复核" }
    $strategyLine = if ($StrategyLink) { "- 关联策略：$StrategyLink" } else { "- 关联策略：待复核" }

    return @"
---
type: $typeName
${idField}: $NewId
legacy_id: "$OldId"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: '$yamlSource'
source_old_relative_path: '$yamlRelative'
owner: mig
created_at: $CreatedAt
updated_at: $CreatedAt
tags: [旧库迁移, 未复核]
---

# $Title

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：``$($OldId)``
- 来源旧库路径：``$($SourceOldPath)``
- 新库 ID：``$($NewId)``
- 证据等级：`legacy_raw`
- 结论边界：本页保留旧库内容，不代表新库已经采纳旧结论。

## 关联链接

- 迁移总卡：$migrationCardLink
$directionLine
$strategyLine
- 迁移规范：[[08_方法论/研究库迁移规范|研究库迁移规范]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]

## 复核清单

- [ ] 旧路径真实存在。
- [ ] 平台配置路径真实存在。
- [ ] 平台结果路径真实存在。
- [ ] 实验前假设和证伪条件满足新库标准。
- [ ] 未来函数和过拟合审计满足新库标准。
- [ ] 已同步对应台账和驾驶舱。

## 旧库 Frontmatter

~~~yaml
$OldFrontmatter
~~~

## 旧库原文

~~~markdown
$OldBody
~~~
"@
}

if (-not (Test-Path -LiteralPath $OldRoot)) {
    throw "旧库不存在：$OldRoot"
}

$createdAt = '2026-06-05T12:00:00Z'
$batchMigId = 'MIG-20260605T120000Z-mig-BATCH'
$batchCardPath = Join-Path $NewRoot '11_迁移暂存/MIG-20260605T120000Z-mig-BATCH_旧库批量迁移总卡.md'
$migrationLedgerPath = Join-Path $NewRoot '01_台账/旧库迁移台账.csv'

$oldFiles = Get-ChildItem -LiteralPath $OldRoot -Recurse -File -Filter '*.md' |
    Where-Object { $_.FullName -notmatch '\\.obsidian\\' -and $_.FullName -notmatch '\\attachments\\' } |
    Sort-Object FullName

$rows = New-Object System.Collections.Generic.List[object]
$typeLedgerRows = @{
    experiment = New-Object System.Collections.Generic.List[object]
    decision = New-Object System.Collections.Generic.List[object]
    direction = New-Object System.Collections.Generic.List[object]
    strategy = New-Object System.Collections.Generic.List[object]
    literature = New-Object System.Collections.Generic.List[object]
    term = New-Object System.Collections.Generic.List[object]
}

foreach ($file in $oldFiles) {
    $relativeOld = Get-RelativePathCompat -Base $OldRoot -Path $file.FullName
    $topFolder = ($relativeOld -split '[\\/]')[0]
    $kind = Get-MigrationKind -TopFolder $topFolder -FileName $file.Name

    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $parts = Get-OldFrontmatterAndBody -Content $content
    $frontmatter = $parts.Frontmatter
    $body = $parts.Body

    $fileBase = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $title = Get-TitleFromBody -Body $body -Fallback $fileBase
    $oldId = Get-OldId -Frontmatter $frontmatter -FileBase $fileBase -Kind $kind.Kind
    $datePart = Get-DatePart -OldId $oldId -FallbackTime $file.LastWriteTime
    $codeBase = ($oldId -replace '[^A-Za-z0-9]', '').ToUpperInvariant()
    if ([string]::IsNullOrWhiteSpace($codeBase)) {
        $codeBase = "H$(Get-ShortHash -Text $relativeOld -Length 8)"
    }
    if ($codeBase.Length -gt 24) {
        $codeBase = $codeBase.Substring(0, 24)
    }
    $hash = Get-ShortHash -Text $relativeOld -Length 5
    $newId = "$($kind.Prefix)-$($datePart)T000000Z-mig-$codeBase$hash"

    $safeTitle = Convert-ToSafeFileName -Name $title
    $targetDir = Join-Path $NewRoot $kind.TargetDir
    $targetPath = Join-Path $targetDir "$newId`_$safeTitle.md"
    $targetRelative = Get-RelativePathCompat -Base $NewRoot -Path $targetPath

    $directionId = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'direction_id'
    $directionLink = ''
    $strategyLink = ''
    if ($directionId -eq 'R010-B5' -or $title -match '双池|ETF|R010') {
        $directionLink = '[[02_研究方向/RD-20260605T115651Z-main-DP00_双池轮动策略|双池轮动策略]]'
        $strategyLink = '[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]'
    }

    $rows.Add([pscustomobject]@{
        new_id = $newId
        mig_batch_id = $batchMigId
        old_id = $oldId
        kind = $kind.Kind
        old_relative_path = $relativeOld
        new_relative_path = $targetRelative
        title = $title
        migration_status = 'migrated_unverified'
        evidence_level = 'legacy_raw'
    }) | Out-Null

    if (-not $WhatIfOnly) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        if (-not (Test-Path -LiteralPath $targetPath)) {
            $migrated = New-MigratedContent -Kind $kind -NewId $newId -Title $title -OldId $oldId -SourceOldPath $file.FullName -RelativeOldPath $relativeOld -OldFrontmatter $frontmatter -OldBody $body -CreatedAt $createdAt -DirectionLink $directionLink -StrategyLink $strategyLink
            [System.IO.File]::WriteAllText($targetPath, $migrated, [System.Text.UTF8Encoding]::new($false))
        }
    }

    switch ($kind.Kind) {
        'experiment' {
            $configPath = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'config_path'
            $resultPath = Get-FrontmatterValue -Frontmatter $frontmatter -Key 'result_path'
            $typeLedgerRows.experiment.Add([pscustomobject]@{
                ex_id = $newId
                rd_id = 'RD-20260605T115651Z-main-DP00'
                status = 'migrated_unverified'
                stage = 'legacy_raw'
                name = $title
                hypothesis_summary = '旧库机械迁移，待复核'
                config_paths = $configPath
                result_paths = $resultPath
                file = $targetRelative
                decision_ids = ''
                created_at_utc = $createdAt
                updated_at_utc = $createdAt
                novice_summary = '旧库迁移记录，不能直接作为新库有效结论'
                next_action = '按新库研究质量审计规范复核'
            }) | Out-Null
        }
        'decision' {
            $typeLedgerRows.decision.Add([pscustomobject]@{
                dec_id = $newId
                rd_ids = 'RD-20260605T115651Z-main-DP00'
                ex_ids = ''
                decision = 'migrated_unverified'
                name = $title
                status = 'migrated_unverified'
                created_at_utc = $createdAt
                updated_at_utc = $createdAt
                file = $targetRelative
                novice_summary = '旧库迁移决策，待复核后才能影响新库路线'
                next_action = '复核证据链和边界'
            }) | Out-Null
        }
        'direction' {
            $typeLedgerRows.direction.Add([pscustomobject]@{
                rd_id = $newId
                parent_rd_id = ''
                scope = '旧库迁移'
                module_type = ''
                name = $title
                status = 'migrated_unverified'
                priority = 'P3'
                owner = 'mig'
                created_at_utc = $createdAt
                updated_at_utc = $createdAt
                file = $targetRelative
                current_decision_id = ''
                current_best_ex_id = ''
                next_action = '复核后决定是否并入现有方向或保留为历史方向'
            }) | Out-Null
        }
        'strategy' {
            $typeLedgerRows.strategy.Add([pscustomobject]@{
                strategy_id = $newId
                name = $title
                status = 'migrated_unverified'
                research_rd_id = ''
                platform_strategy_paths = ''
                platform_config_paths = ''
                platform_result_paths = ''
                file = $targetRelative
                created_at_utc = $createdAt
                updated_at_utc = $createdAt
                next_action = '复核平台代码、配置和结果路径'
            }) | Out-Null
        }
        'literature' {
            $typeLedgerRows.literature.Add([pscustomobject]@{
                lit_id = $newId
                status = 'migrated_unverified'
                category = '旧库迁移'
                title = $title
                authors = ''
                year = ''
                journal = ''
                url = ''
                file = $targetRelative
                related_rd_ids = ''
                created_at_utc = $createdAt
                updated_at_utc = $createdAt
                next_action = '复核来源、数据和可转化灵感'
            }) | Out-Null
        }
        'term' {
            $typeLedgerRows.term.Add([pscustomobject]@{
                term_id = $newId
                term = $title
                aliases = $oldId
                status = 'migrated_unverified'
                file = $targetRelative
                created_at_utc = $createdAt
                updated_at_utc = $createdAt
                summary = '旧库概念迁移，待整理为正式术语'
            }) | Out-Null
        }
    }
}

if ($WhatIfOnly) {
    $rows | Group-Object kind | Sort-Object Name | Select-Object Name,Count | Format-Table -AutoSize
    return
}

$rows | Export-Csv -LiteralPath $migrationLedgerPath -NoTypeInformation -Encoding UTF8

function Merge-Ledger {
    param(
        [string]$LedgerName,
        [System.Collections.IEnumerable]$NewRows,
        [string]$KeyField
    )
    $ledgerPath = Join-Path (Join-Path $NewRoot '01_台账') $LedgerName
    if (-not (Test-Path -LiteralPath $ledgerPath)) {
        return
    }
    $existing = @(Import-Csv -LiteralPath $ledgerPath -Encoding UTF8)
    $existingKeys = @{}
    foreach ($row in $existing) {
        if ($row.$KeyField) {
            $existingKeys[$row.$KeyField] = $true
        }
    }
    $merged = New-Object System.Collections.Generic.List[object]
    foreach ($row in $existing) { $merged.Add($row) | Out-Null }
    foreach ($row in $NewRows) {
        if (-not $existingKeys.ContainsKey($row.$KeyField)) {
            $merged.Add($row) | Out-Null
        }
    }
    $merged | Export-Csv -LiteralPath $ledgerPath -NoTypeInformation -Encoding UTF8
}

Merge-Ledger -LedgerName '实验台账.csv' -NewRows $typeLedgerRows.experiment -KeyField 'ex_id'
Merge-Ledger -LedgerName '决策台账.csv' -NewRows $typeLedgerRows.decision -KeyField 'dec_id'
Merge-Ledger -LedgerName '研究方向台账.csv' -NewRows $typeLedgerRows.direction -KeyField 'rd_id'
Merge-Ledger -LedgerName '策略资产台账.csv' -NewRows $typeLedgerRows.strategy -KeyField 'strategy_id'
Merge-Ledger -LedgerName '文献台账.csv' -NewRows $typeLedgerRows.literature -KeyField 'lit_id'
Merge-Ledger -LedgerName '术语台账.csv' -NewRows $typeLedgerRows.term -KeyField 'term_id'

$summary = $rows | Group-Object kind | Sort-Object Name | ForEach-Object {
    "| $($_.Name) | $($_.Count) |"
}
$summaryText = ($summary -join "`r`n")
$batchContent = @"
---
type: 迁移卡
mig_id: $batchMigId
status: migrated_unverified
owner: mig
created_at: $createdAt
updated_at: $createdAt
source_old_path: '$($OldRoot.Replace("'", "''"))'
target_ids: []
tags: [旧库迁移, 批量迁移]
---

# 旧库批量迁移总卡

## 迁移范围

旧库路径：

````text
$OldRoot
````

本次迁移只处理 Markdown 文档，不迁移 `.obsidian`、附件、缓存、大型数据或平台结果文件。

## 迁移统计

| 类型 | 数量 |
| --- | ---: |
$summaryText

## 迁移台账

[[01_台账/旧库迁移台账.csv|旧库迁移台账]]

## 迁移边界

- 所有迁移文档状态均为 `migrated_unverified`。
- 所有迁移文档证据等级均为 `legacy_raw`。
- 迁移内容保留旧库原文，不代表新库已经采纳旧结论。
- 任何会影响驾驶舱、当前最佳策略或路线状态的结论，必须重新经过新库研究质量审计。

## 下一步

1. 优先复核双池轮动、R010-B5、R010-C 相关实验和决策。
2. 把通过复核的旧记录从 `legacy_raw` 升级为新库正式实验或决策。
3. 更新 [[00_入口/研究驾驶舱|研究驾驶舱]] 和 [[00_入口/研究路线图.canvas|研究路线图 Canvas]]。
"@

[System.IO.File]::WriteAllText($batchCardPath, $batchContent, [System.Text.UTF8Encoding]::new($false))

Write-Output "迁移完成。"
Write-Output "旧文件数：$($oldFiles.Count)"
Write-Output "迁移台账：$migrationLedgerPath"
Write-Output "迁移总卡：$batchCardPath"
$rows | Group-Object kind | Sort-Object Name | Select-Object Name,Count | Format-Table -AutoSize
