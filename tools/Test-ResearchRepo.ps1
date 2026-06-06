param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$requiredFiles = @(
    'README.md',
    'AGENTS.md',
    '00_入口/研究驾驶舱.md',
    '00_入口/当前状态.md',
    '01_台账/研究方向台账.csv',
    '01_台账/实验台账.csv',
    '01_台账/决策台账.csv',
    '01_台账/子代理调用台账.csv',
    '08_方法论/命名与编号规范.md',
    '08_方法论/研究方法论.md',
    '09_术语库/术语库.md'
)

foreach ($file in $requiredFiles) {
    $path = Join-Path $Root $file
    if (-not (Test-Path -LiteralPath $path)) {
        $errors.Add("缺少必需文件：$file")
    }
}

$idPattern = '([A-Z]+-\d{8}T\d{6}Z-[A-Za-z0-9_-]+-[A-Za-z0-9]+)'
$filenameIdRegex = [regex]'([A-Z]+-\d{8}T\d{6}Z-[A-Za-z0-9_-]+-[A-Za-z0-9]+)'
$primaryIdToFiles = @{}
$filenameIdToFiles = @{}
$markdownFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.md'
$subagentLedgerPath = Join-Path $Root '01_台账/子代理调用台账.csv'
$subagentCallIds = New-Object System.Collections.Generic.HashSet[string]
if (Test-Path -LiteralPath $subagentLedgerPath) {
    $subagentRows = @(Import-Csv -LiteralPath $subagentLedgerPath -Encoding UTF8)
    if ($subagentRows.Count -gt 0) {
        $subagentColumns = @($subagentRows[0].PSObject.Properties.Name)
        foreach ($requiredColumn in @('call_id', 'task_code', 'platform_nickname')) {
            if ($subagentColumns -notcontains $requiredColumn) {
                $errors.Add("子代理调用台账缺少字段：$requiredColumn")
            }
        }
    }
    foreach ($row in $subagentRows) {
        if ($row.call_id) {
            [void]$subagentCallIds.Add($row.call_id)
        }
    }
    $duplicateSubtasks = $subagentRows |
        Where-Object { $_.task_code -match '^SUBTASK-\d{8}T\d{6}Z-' } |
        Group-Object -Property task_code |
        Where-Object { $_.Count -gt 1 }
    foreach ($dup in $duplicateSubtasks) {
        $errors.Add("子代理台账存在重复 SUBTASK 任务代号：$($dup.Name)")
    }
}
$strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
$textExtensions = @('.md', '.csv', '.json', '.canvas', '.ps1', '.yml', '.yaml')
$textFileNames = @('.gitignore', '.gitattributes')
$textFiles = Get-ChildItem -LiteralPath $Root -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\.git\\' -and (
        $textExtensions -contains $_.Extension.ToLowerInvariant() -or
        $textFileNames -contains $_.Name
    )
}
$wikiLinksChecked = 0

foreach ($textFile in $textFiles) {
    $rootPrefix = $Root.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $relative = $textFile.FullName
    if ($textFile.FullName.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $textFile.FullName.Substring($rootPrefix.Length)
    }
    try {
        [void][System.IO.File]::ReadAllText($textFile.FullName, $strictUtf8)
    } catch {
        $errors.Add("文本文件不是有效 UTF-8：$relative -> $($_.Exception.Message)")
    }
}

foreach ($file in $markdownFiles) {
    $rootPrefix = $Root.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $relative = $file.FullName
    if ($file.FullName.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $file.FullName.Substring($rootPrefix.Length)
    }
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8

    $frontmatterMatch = [regex]::Match($content, "(?s)^---\s*\r?\n(.*?)\r?\n---")
    if ($frontmatterMatch.Success) {
        $frontmatter = $frontmatterMatch.Groups[1].Value
        if ([regex]::IsMatch($frontmatter, '(?m)^source_old_(relative_)?path:\s*".*\\.*"\s*$')) {
            $errors.Add("YAML 路径字段不能使用带反斜杠的双引号：$relative")
        }
        if ($file.Extension.ToLowerInvariant() -eq '.md' -and [regex]::IsMatch($content, '\bnot_required\b')) {
            $errors.Add("子代理调用状态不得使用 not_required，应使用 called 或标准豁免：$relative")
        }

        $isResearchExecutionDoc = $relative.StartsWith('04_实验记录\', [System.StringComparison]::OrdinalIgnoreCase) -or
            $relative.StartsWith('05_研究决策\', [System.StringComparison]::OrdinalIgnoreCase)
        $isCompleted = [regex]::IsMatch($frontmatter, '(?m)^status:\s*completed\s*$') -or
            [regex]::IsMatch($frontmatter, '(?m)^decision:\s*(?!draft\b).+\S\s*$')
        if ($isResearchExecutionDoc -and $isCompleted) {
            $hasValidSubagentCall = $false
            $callIdsMatch = [regex]::Match($frontmatter, '(?ms)^subagent_call_ids:\s*\[(.*?)\]\s*$')
            if ($callIdsMatch.Success) {
                $callIdsText = $callIdsMatch.Groups[1].Value
                foreach ($callIdMatch in [regex]::Matches($callIdsText, 'SUB-\d{8}T\d{6}Z-[A-Za-z0-9_-]+-[A-Za-z0-9]+')) {
                    if ($subagentCallIds.Contains($callIdMatch.Value)) {
                        $hasValidSubagentCall = $true
                    } else {
                        $errors.Add("subagent_call_ids 未登记到子代理调用台账：$relative -> $($callIdMatch.Value)")
                    }
                }
            }
            foreach ($callIdMatch in [regex]::Matches($content, 'SUB-\d{8}T\d{6}Z-[A-Za-z0-9_-]+-[A-Za-z0-9]+')) {
                if ($subagentCallIds.Contains($callIdMatch.Value)) {
                    $hasValidSubagentCall = $true
                }
            }
            $hasSubagentExemption = [regex]::IsMatch($content, '子代理豁免：.+；主控：.+；时间：\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z')
            if (-not $hasValidSubagentCall -and -not $hasSubagentExemption) {
                $errors.Add("completed 实验/生效决策缺少已登记的子代理调用或标准豁免：$relative")
            }
        }
    }

    $lineNumber = 0
    foreach ($line in ($content -split "\r?\n")) {
        $lineNumber += 1
        if ($line -match '^\s*\|' -and $line -match '\[\[[^\]]*\|[^\]]*\]\]') {
            $errors.Add("Markdown 表格内不能使用 Obsidian 别名双链：${relative}:$lineNumber")
        }
    }

    $expectedField = $null
    if ($file.Name.StartsWith('RD-')) { $expectedField = 'rd_id' }
    elseif ($file.Name.StartsWith('STRAT-')) { $expectedField = 'strategy_id' }
    elseif ($file.Name.StartsWith('EX-')) { $expectedField = 'ex_id' }
    elseif ($file.Name.StartsWith('DEC-')) { $expectedField = 'dec_id' }
    elseif ($file.Name.StartsWith('LIT-')) { $expectedField = 'lit_id' }
    elseif ($file.Name.StartsWith('TERM-')) { $expectedField = 'term_id' }
    elseif ($file.Name.StartsWith('MIG-')) { $expectedField = 'mig_id' }
    elseif ($file.Name.StartsWith('IDEA-') -or $file.Name.StartsWith('FAC-') -or $file.Name.StartsWith('DATA-') -or $file.Name.StartsWith('MECH-')) { $expectedField = 'idea_id' }

    if ($expectedField) {
        $primaryIdRegex = [regex]("(?m)^\s*$expectedField\s*:\s*$idPattern\s*$")
        $primaryMatch = $primaryIdRegex.Match($content)
        if (-not $primaryMatch.Success) {
            $errors.Add("文件缺少主字段 $expectedField：$relative")
        } else {
            $id = $primaryMatch.Groups[1].Value
            if (-not $primaryIdToFiles.ContainsKey($id)) {
                $primaryIdToFiles[$id] = New-Object System.Collections.Generic.HashSet[string]
            }
            [void]$primaryIdToFiles[$id].Add($relative)
        }
    }

    $fileIdMatch = $filenameIdRegex.Match($file.Name)
    if ($fileIdMatch.Success) {
        $id = $fileIdMatch.Groups[1].Value
        if (-not $filenameIdToFiles.ContainsKey($id)) {
            $filenameIdToFiles[$id] = New-Object System.Collections.Generic.HashSet[string]
        }
        [void]$filenameIdToFiles[$id].Add($relative)
    }

    $wikiScanContent = [regex]::Replace($content, '(?s)```.*?```', '')
    $wikiScanContent = [regex]::Replace($wikiScanContent, '(?s)~~~.*?~~~', '')
    $wikiScanContent = [regex]::Replace($wikiScanContent, '`[^`]*`', '')
    $wikiLinkRegex = [regex]'\[\[([^\]]+)\]\]'
    foreach ($linkMatch in $wikiLinkRegex.Matches($wikiScanContent)) {
        $rawTarget = $linkMatch.Groups[1].Value
        $target = ($rawTarget -split '\|')[0]
        $target = ($target -split '#')[0]
        $target = $target.Trim()
        if ([string]::IsNullOrWhiteSpace($target) -or $target.Contains('{{')) {
            continue
        }
        $wikiLinksChecked += 1

        $targetWithMd = $target
        if (-not [System.IO.Path]::HasExtension($targetWithMd)) {
            $targetWithMd = "$targetWithMd.md"
        }

        $found = $false
        if ($target.Contains('/') -or $target.Contains('\')) {
            $candidate = Join-Path $Root $targetWithMd
            $found = Test-Path -LiteralPath $candidate
            if (-not $found -and $target.EndsWith('.canvas')) {
                $found = Test-Path -LiteralPath (Join-Path $Root $target)
            }
        } else {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($target)
            $found = [bool](Get-ChildItem -LiteralPath $Root -Recurse -File | Where-Object {
                [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $name
            } | Select-Object -First 1)
        }

        if (-not $found) {
            $warnings.Add("Wiki 链接目标未找到：$relative -> [[$rawTarget]]")
        }
    }
}

foreach ($id in $primaryIdToFiles.Keys) {
    if ($primaryIdToFiles[$id].Count -gt 1) {
        $files = ($primaryIdToFiles[$id] | Sort-Object) -join '; '
        $errors.Add("主 ID 在多个正文中重复：$id -> $files")
    }
}

foreach ($id in $filenameIdToFiles.Keys) {
    if ($filenameIdToFiles[$id].Count -gt 1) {
        $files = ($filenameIdToFiles[$id] | Sort-Object) -join '; '
        $errors.Add("文件名 ID 重复：$id -> $files")
    }
}

$ledgerFiles = Get-ChildItem -LiteralPath (Join-Path $Root '01_台账') -File -Filter '*.csv'
foreach ($ledger in $ledgerFiles) {
    $lines = @(Get-Content -LiteralPath $ledger.FullName -Encoding UTF8)
    if ($lines.Count -eq 0) {
        $errors.Add("台账为空：$($ledger.Name)")
        continue
    }
    $header = $lines[0].Split(',')[0].Trim('"')
    if ([string]::IsNullOrWhiteSpace($header)) {
        $errors.Add("台账首列为空：$($ledger.Name)")
        continue
    }
    $rows = Import-Csv -LiteralPath $ledger.FullName -Encoding UTF8
    if ($rows.Count -eq 0) {
        continue
    }
    $duplicates = $rows | Where-Object { $_.$header } | Group-Object -Property $header | Where-Object { $_.Count -gt 1 }
    foreach ($dup in $duplicates) {
        $errors.Add("台账 $($ledger.Name) 存在重复 $header：$($dup.Name)")
    }
}

$canvasFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.canvas'
foreach ($canvas in $canvasFiles) {
    try {
        $canvasContent = Get-Content -LiteralPath $canvas.FullName -Raw -Encoding UTF8
        $canvasJson = $canvasContent | ConvertFrom-Json
        if ($null -eq $canvasJson.nodes) {
            $errors.Add("Canvas 缺少 nodes：$($canvas.FullName)")
        }
        if ($null -eq $canvasJson.edges) {
            $errors.Add("Canvas 缺少 edges：$($canvas.FullName)")
        }
    } catch {
        $errors.Add("Canvas JSON 无法解析：$($canvas.FullName) -> $($_.Exception.Message)")
    }
}

if ($errors.Count -eq 0) {
    Write-Output '基础检查：通过'
} else {
    Write-Output '基础检查：失败'
    foreach ($item in $errors) {
        Write-Output "ERROR: $item"
    }
}

foreach ($item in $warnings) {
    Write-Output "WARN: $item"
}

Write-Output "Markdown 文件数：$($markdownFiles.Count)"
Write-Output "台账文件数：$($ledgerFiles.Count)"
Write-Output "Canvas 文件数：$($canvasFiles.Count)"
Write-Output "UTF-8 文件检查数：$($textFiles.Count)"
Write-Output "Wiki 链接检查数：$wikiLinksChecked"

if ($errors.Count -gt 0) {
    exit 1
}
