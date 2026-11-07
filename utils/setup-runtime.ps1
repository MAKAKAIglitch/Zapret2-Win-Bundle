$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Pinned upstream revision checked on 2026-11-07.
# Pinning the commit keeps winws2.exe and its Lua modules reproducible.
$UpstreamCommit = 'bb6a20af35ed74778eb669f5413990eb8209c711'
$ArchiveUrl = "https://codeload.github.com/bol-van/zapret-win-bundle/zip/$UpstreamCommit"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$BinRoot = Join-Path $RepoRoot 'bin'
$DataRoot = Join-Path $RepoRoot 'data'
$WorkRoot = Join-Path ([System.IO.Path]::GetTempPath()) "zapret2-win-bundle-$UpstreamCommit"
$ZipPath = Join-Path $WorkRoot 'upstream.zip'
$ExtractRoot = Join-Path $WorkRoot 'extract'

$RequiredFiles = @(
    'winws2.exe',
    'WinDivert.dll',
    'WinDivert64.sys',
    'cygwin1.dll',
    'lua\zapret-lib.lua',
    'lua\zapret-antidpi.lua',
    'lua\zapret-auto.lua',
    'files\quic_initial_www_google_com.bin',
    'windivert.filter\windivert_part.discord_media.txt',
    'windivert.filter\windivert_part.stun.txt',
    'windivert.filter\windivert_part.wireguard.txt',
    'windivert.filter\windivert_part.quic_initial_ietf.txt'
)

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $running = Get-Process -Name 'winws2' -ErrorAction SilentlyContinue
    if ($running) {
        throw 'winws2.exe is running. Stop the Zapret2WinBundle service or standalone strategy before updating its runtime.'
    }

    if (Test-Path -LiteralPath $BinRoot) {
        $existingItems = @(Get-ChildItem -LiteralPath $BinRoot -Force | Where-Object { $_.Name -ne 'README.md' })
    } else {
        $existingItems = @()
    }

    if ($existingItems.Count -gt 0) {
        Write-Host ''
        Write-Host 'An existing runtime was found in bin.'
        Write-Host 'It will be backed up to data\runtime-backup before replacement.'
        $answer = Read-Host 'Type UPDATE to continue'
        if ($answer -cne 'UPDATE') {
            Write-Host '[INFO] Update cancelled. Existing runtime was not changed.'
            exit 2
        }
    }

    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $ExtractRoot -Force | Out-Null

    Write-Host "[INFO] Downloading pinned upstream commit $UpstreamCommit"
    Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ZipPath -TimeoutSec 180 -UseBasicParsing

    $archive = Get-Item -LiteralPath $ZipPath
    if ($archive.Length -lt 1MB) {
        throw "The downloaded archive is unexpectedly small ($($archive.Length) bytes)."
    }

    Write-Host '[INFO] Extracting upstream Windows bundle'
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $ExtractRoot -Force

    $RuntimeSource = $null
    foreach ($directory in Get-ChildItem -LiteralPath $ExtractRoot -Directory) {
        $candidate = Join-Path $directory.FullName 'zapret-winws'
        if (Test-Path -LiteralPath (Join-Path $candidate 'winws2.exe')) {
            $RuntimeSource = $candidate
            break
        }
    }

    if (-not $RuntimeSource) {
        throw 'The archive does not contain zapret-winws\winws2.exe. No runtime files were copied.'
    }

    foreach ($relativePath in $RequiredFiles) {
        $sourcePath = Join-Path $RuntimeSource $relativePath
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            throw "Required upstream file is missing: $relativePath"
        }
    }

    New-Item -ItemType Directory -Path $BinRoot -Force | Out-Null

    if ($existingItems.Count -gt 0) {
        $backupName = 'runtime-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
        $BackupRoot = Join-Path $DataRoot $backupName
        New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

        foreach ($item in $existingItems) {
            Copy-Item -LiteralPath $item.FullName -Destination $BackupRoot -Recurse -Force
        }
        Write-Host "[INFO] Previous runtime backed up to data\$backupName"
    }

    Write-Host '[INFO] Copying upstream zapret-winws runtime into bin'
    Copy-Item -Path (Join-Path $RuntimeSource '*') -Destination $BinRoot -Recurse -Force

    foreach ($relativePath in $RequiredFiles) {
        $targetPath = Join-Path $BinRoot $relativePath
        if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
            throw "Runtime copy verification failed: bin\$relativePath"
        }
    }

    $versionText = @(
        'Runtime source: https://github.com/bol-van/zapret-win-bundle'
        "Pinned commit: $UpstreamCommit"
        "Installed UTC: $([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))"
    ) -join [Environment]::NewLine
    Set-Content -LiteralPath (Join-Path $BinRoot 'runtime-version.txt') -Value $versionText -Encoding UTF8

    Write-Host ''
    Write-Host '[INFO] Runtime files were copied and verified.'
    Write-Host "[INFO] Upstream commit: $UpstreamCommit"
    Write-Host '[INFO] Next: run service.bat and choose option 6 (Check runtime and lists).'
}
catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    if (Test-Path -LiteralPath $WorkRoot) {
        Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
