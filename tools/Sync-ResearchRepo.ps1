param(
    [string]$Root = '',

    [string]$Remote = 'origin',

    [string]$Branch = 'main',

    [int]$MaxMergeRounds = 2,

    [switch]$NoPush,

    [switch]$NoAutoCommit,

    [switch]$SkipBackup
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

Set-Location -LiteralPath $Root

$script:BackupCreated = $false
$script:BackupPath = $null

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message"
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }
}

function Get-GitLines {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }
    return @($output | ForEach-Object { [string]$_ })
}

function Test-GitPathExists {
    param([string]$RelativePath)

    & git ls-files --error-unmatch -- $RelativePath *> $null
    return ($LASTEXITCODE -eq 0)
}

function Get-UnmergedFiles {
    return @(Get-GitLines -Arguments @('-c', 'core.quotepath=false', 'diff', '--name-only', '--diff-filter=U'))
}

function Get-StatusLines {
    return @(Get-GitLines -Arguments @('-c', 'core.quotepath=false', 'status', '--porcelain=v1'))
}

function Get-AheadBehind {
    param([string]$RemoteRef)

    $line = (Get-GitLines -Arguments @('rev-list', '--left-right', '--count', "HEAD...$RemoteRef") | Select-Object -First 1)
    $parts = @($line -split '\s+')
    return [pscustomobject]@{
        Ahead = [int]$parts[0]
        Behind = [int]$parts[1]
    }
}

function Assert-NoMergeInProgress {
    $gitDir = (Get-GitLines -Arguments @('rev-parse', '--git-dir') | Select-Object -First 1)
    foreach ($marker in @('MERGE_HEAD', 'REBASE_HEAD', 'CHERRY_PICK_HEAD', 'REVERT_HEAD')) {
        $markerPath = Join-Path $gitDir $marker
        if (Test-Path -LiteralPath $markerPath) {
            throw "Unfinished Git operation detected: $marker"
        }
    }
}

function Remove-ObsidianConflictArtifact {
    $artifact = Join-Path $Root 'conflict-files-obsidian-git.md'
    if ((Test-Path -LiteralPath $artifact) -and -not (Test-GitPathExists -RelativePath 'conflict-files-obsidian-git.md')) {
        Remove-Item -LiteralPath $artifact
        Write-Step 'Removed Obsidian Git conflict artifact'
    }
}

function New-SyncBackup {
    if ($SkipBackup -or $script:BackupCreated) {
        return
    }

    $backupRoot = Join-Path (Split-Path -Parent $Root) 'merge-backups'
    $repoName = Split-Path -Leaf $Root
    $stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMdd'T'HHmmss'Z'")
    $target = Join-Path $backupRoot "$repoName`_sync_$stamp"

    New-Item -ItemType Directory -Force -Path $target | Out-Null
    $robocopyArgs = @(
        $Root,
        $target,
        '/E',
        '/XD', '.git', '.obsidian\cache',
        '/XF', 'conflict-files-obsidian-git.md',
        '/NFL', '/NDL', '/NJH', '/NJS', '/NP'
    )
    & robocopy @robocopyArgs | Out-Null
    $code = $LASTEXITCODE
    if ($code -gt 7) {
        throw "Backup failed, robocopy exit code=$code, target=$target"
    }

    $script:BackupCreated = $true
    $script:BackupPath = $target
    Write-Step "Backup created: $target"
}

function Assert-NoConflictMarkers {
    $rg = Get-Command rg -ErrorAction SilentlyContinue
    if ($null -eq $rg) {
        Write-Step 'rg not found; skipped conflict marker scan'
        return
    }

    & rg -n '^(<<<<<<<|=======|>>>>>>>)' -g '*.md' -g '*.csv' -g '*.json' -g '*.canvas' -g '*.yml' -g '*.yaml' -g '*.ps1' .
    $code = $LASTEXITCODE
    if ($code -eq 0) {
        throw 'Conflict markers found; sync stopped.'
    }
    if ($code -gt 1) {
        throw "rg scan failed, exit code=$code"
    }
}

function Test-CachedDiffExists {
    & git diff --cached --quiet
    return ($LASTEXITCODE -eq 1)
}

function Save-LocalChanges {
    Remove-ObsidianConflictArtifact

    $unmerged = Get-UnmergedFiles
    if ($unmerged.Count -gt 0) {
        throw "Unresolved conflicts already exist: $($unmerged -join ', ')"
    }

    $status = Get-StatusLines
    if ($status.Count -eq 0) {
        Write-Step 'Working tree is clean'
        return
    }

    if ($NoAutoCommit) {
        throw 'Working tree has changes and -NoAutoCommit is set.'
    }

    New-SyncBackup
    Assert-NoConflictMarkers

    Invoke-Git -Arguments @('add', '-A')
    if (Test-CachedDiffExists) {
        $stamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
        Invoke-Git -Arguments @('commit', '-m', "sync-local: $stamp")
        Write-Step 'Committed local changes'
    } else {
        Write-Step 'No staged diff to commit'
    }
}

function Resolve-LedgerCsvConflicts {
    $unmerged = Get-UnmergedFiles
    foreach ($path in $unmerged) {
        $normalized = $path -replace '\\', '/'
        if ($normalized -match '^01_[^/]+/.+\.csv$') {
            Write-Step "Auto-merging ledger CSV: $normalized"
            & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Merge-LedgerCsv.ps1') -Root $Root -RepoPath $normalized -StageResult
            if ($LASTEXITCODE -ne 0) {
                throw "Ledger auto-merge failed: $normalized"
            }
        }
    }
}

function Complete-MergeIfOnlyAutoResolved {
    Resolve-LedgerCsvConflicts
    Remove-ObsidianConflictArtifact

    $remaining = Get-UnmergedFiles
    if ($remaining.Count -gt 0) {
        Write-Host ''
        Write-Host 'Manual semantic merge required for:'
        foreach ($path in $remaining) {
            Write-Host "  - $path"
        }
        throw 'Non-ledger or unresolved conflicts remain; sync stopped without push.'
    }

    Assert-NoConflictMarkers
    Invoke-Git -Arguments @('commit', '--no-edit')
    Write-Step 'Committed auto-resolved merge'
}

function Merge-Remote {
    $remoteRef = "$Remote/$Branch"
    $round = 0

    while ($true) {
        Invoke-Git -Arguments @('fetch', '--prune', $Remote)
        $ab = Get-AheadBehind -RemoteRef $remoteRef
        Write-Step "Divergence: ahead=$($ab.Ahead), behind=$($ab.Behind)"

        if ($ab.Behind -eq 0) {
            return
        }

        if ($round -ge $MaxMergeRounds) {
            throw "Remote changed too many times. MaxMergeRounds=$MaxMergeRounds"
        }

        New-SyncBackup
        $round += 1
        Write-Step "Merging $remoteRef round $round"
        & git merge --no-edit $remoteRef
        if ($LASTEXITCODE -ne 0) {
            Complete-MergeIfOnlyAutoResolved
        }
    }
}

function Run-QualityGates {
    Assert-NoConflictMarkers

    Invoke-Git -Arguments @('diff', '--check')
    & powershell -ExecutionPolicy Bypass -File (Join-Path $Root 'tools\Test-ResearchRepo.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw 'Research repo health check failed; sync stopped without push.'
    }
    Write-Step 'Quality gates passed'
}

Write-Step "Safe sync start: $Root"
Assert-NoMergeInProgress
Save-LocalChanges
Merge-Remote
Run-QualityGates

Invoke-Git -Arguments @('fetch', '--prune', $Remote)
$finalAb = Get-AheadBehind -RemoteRef "$Remote/$Branch"
if ($finalAb.Behind -gt 0) {
    throw "Remote moved during quality checks. behind=$($finalAb.Behind). Re-run this script."
}

if (-not $NoPush) {
    Invoke-Git -Arguments @('push', $Remote, "HEAD:$Branch")
    Write-Step "Pushed to $Remote/$Branch"
} else {
    Write-Step 'Skipped push because -NoPush is set'
}

$status = Get-GitLines -Arguments @('-c', 'core.quotepath=false', 'status', '--short', '--branch')
Write-Host ($status -join "`n")
if ($script:BackupPath) {
    Write-Step "Backup for this run: $script:BackupPath"
}
