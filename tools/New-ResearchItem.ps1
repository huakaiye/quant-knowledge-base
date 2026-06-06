param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Direction', 'Strategy', 'Experiment', 'Decision', 'Literature', 'Inspiration', 'Factor', 'Data', 'Mechanism', 'Term', 'Migration')]
    [string]$Type,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [string]$ParentId = '',

    [string]$AgentCode = $env:AGENT_CODE,

    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

if ([string]::IsNullOrWhiteSpace($AgentCode)) {
    $AgentCode = 'main'
}

$AgentCode = ($AgentCode.ToLowerInvariant() -replace '[^a-z0-9_-]', '')
if ([string]::IsNullOrWhiteSpace($AgentCode)) {
    $AgentCode = 'main'
}

function New-RandomCode {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'.ToCharArray()
    $buffer = New-Object char[] 4
    for ($i = 0; $i -lt $buffer.Length; $i++) {
        $buffer[$i] = $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]
    }
    return -join $buffer
}

$prefixMap = @{
    Direction   = 'RD'
    Strategy    = 'STRAT'
    Experiment  = 'EX'
    Decision    = 'DEC'
    Literature  = 'LIT'
    Inspiration = 'IDEA'
    Factor      = 'FAC'
    Data        = 'DATA'
    Mechanism   = 'MECH'
    Term        = 'TERM'
    Migration   = 'MIG'
}

$templateMap = @{
    Direction   = '10_模板/研究方向模板.md'
    Strategy    = '10_模板/策略档案模板.md'
    Experiment  = '10_模板/实验记录模板.md'
    Decision    = '10_模板/研究决策模板.md'
    Literature  = '10_模板/文献笔记模板.md'
    Inspiration = '10_模板/因子数据灵感模板.md'
    Factor      = '10_模板/因子数据灵感模板.md'
    Data        = '10_模板/因子数据灵感模板.md'
    Mechanism   = '10_模板/因子数据灵感模板.md'
    Term        = '10_模板/术语词条模板.md'
    Migration   = '10_模板/迁移卡模板.md'
}

$folderMap = @{
    Direction   = '02_研究方向'
    Strategy    = '03_策略档案'
    Experiment  = '04_实验记录'
    Decision    = '05_研究决策'
    Literature  = '06_文献资料/00_待处理'
    Inspiration = '07_因子数据灵感/04_模块'
    Factor      = '07_因子数据灵感/01_因子'
    Data        = '07_因子数据灵感/02_数据'
    Mechanism   = '07_因子数据灵感/03_机制'
    Term        = '09_术语库'
    Migration   = '11_迁移暂存'
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMdd'T'HHmmss'Z'")
$createdAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$id = "$($prefixMap[$Type])-$timestamp-$AgentCode-$(New-RandomCode)"

$safeTitle = $Title -replace '[\\/:*?"<>|]', ''
$safeTitle = $safeTitle.Trim()
if ([string]::IsNullOrWhiteSpace($safeTitle)) {
    throw '标题清理后为空，请换一个标题。'
}

$templatePath = Join-Path $Root $templateMap[$Type]
$targetFolder = Join-Path $Root $folderMap[$Type]
if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "模板不存在：$templatePath"
}

New-Item -ItemType Directory -Force -Path $targetFolder | Out-Null
$targetPath = Join-Path $targetFolder "$id`_$safeTitle.md"
if (Test-Path -LiteralPath $targetPath) {
    throw "目标文件已存在：$targetPath"
}

$content = Get-Content -LiteralPath $templatePath -Raw -Encoding UTF8
$content = $content.Replace('{{ID}}', $id)
$content = $content.Replace('{{TITLE}}', $Title)
$content = $content.Replace('{{PARENT_ID}}', $ParentId)
$content = $content.Replace('{{AGENT_CODE}}', $AgentCode)
$content = $content.Replace('{{CREATED_AT}}', $createdAt)

[System.IO.File]::WriteAllText($targetPath, $content, [System.Text.UTF8Encoding]::new($false))

Write-Output "已创建：$targetPath"
Write-Output "ID：$id"
Write-Output "提醒：请同步更新 01_台账/ 中对应台账。"
