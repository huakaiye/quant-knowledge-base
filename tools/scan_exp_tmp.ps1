# 只读扫描：读取实验文件 frontmatter 中的 status / rd_id / ex_id / decision_id 字段
$files = Get-ChildItem -Path '04_实验记录' -Filter 'EX-*.md' -File | Sort-Object Name
$result = foreach ($f in $files) {
    $lines = Get-Content -Path $f.FullName
    if ($lines.Count -eq 0) { continue }
    $inFm = $false
    $fm = @{}
    $title = $null
    foreach ($line in $lines) {
        if ($line -eq '---') {
            if (-not $inFm) { $inFm = $true; continue }
            else { break }
        }
        if (-not $inFm) { continue }
        if ($line -match '^title:\s*"?(.+?)"?$') { if (-not $title) { $title=$matches[1] } }
        if ($line -match '^([^:]+):\s*(.*)$') {
            $key=$matches[1].Trim()
            $val=$matches[2].Trim().Trim('"')
            if ($val -ne '') { $fm[$key] = $val }
        }
    }
    [PSCustomObject]@{
        File = $f.Name
        ExId = if($fm.ContainsKey('id')){$fm['id']} else { '' }
        Status = if($fm.ContainsKey('status')){$fm['status']} else { '' }
        RD = if($fm.ContainsKey('rd_id')){$fm['rd_id']} else { '' }
        DEC = if($fm.ContainsKey('decision_id')){$fm['decision_id']} else { '' }
        Title = $title
        Path = $f.FullName
    }
}
$result | Sort-Object Status,File | Export-Csv -NoTypeInformation 'E:\【笔记库】\量化研究库_V2.0.0\tools\__tmp_exp_scan.csv'
$result | Format-Table -AutoSize
