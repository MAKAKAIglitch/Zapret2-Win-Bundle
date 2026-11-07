# Downloads the required x64 runtime from an exact upstream commit.
# Every file is validated as a Git blob before any runtime file is replaced.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$RuntimeRoot = Join-Path $RepoRoot 'bin'
$UpstreamCommit = 'bb6a20af35ed74778eb669f5413990eb8209c711'
$UpstreamBase = "https://raw.githubusercontent.com/bol-van/zapret-win-bundle/$UpstreamCommit/"

$Files = @(
    @{ Source = 'zapret-winws/winws2.exe'; Destination = 'winws2.exe'; GitBlob = '44f7d2400bdf9fbfb3b66d860fd11e8d9a1c9690' },
    @{ Source = 'zapret-winws/WinDivert.dll'; Destination = 'WinDivert.dll'; GitBlob = '2c55eeb6921351a6cad292a900f4b8d7d41c4bcc' },
    @{ Source = 'zapret-winws/WinDivert64.sys'; Destination = 'WinDivert64.sys'; GitBlob = '218ccaf423ef0a67696226f9ef3a09149e4441d0' },
    @{ Source = 'zapret-winws/cygwin1.dll'; Destination = 'cygwin1.dll'; GitBlob = '1bb2e05c6d5458ad7987859a17172b635e87b9c5' },
    @{ Source = 'zapret-winws/lua/zapret-lib.lua'; Destination = 'lua/zapret-lib.lua'; GitBlob = '8d942964631277515a516ea5c6a9ab2ba8ee92de' },
    @{ Source = 'zapret-winws/lua/zapret-antidpi.lua'; Destination = 'lua/zapret-antidpi.lua'; GitBlob = 'b768277b01114246503819d15a8ed1bb15011b5c' },
    @{ Source = 'zapret-winws/lua/zapret-auto.lua'; Destination = 'lua/zapret-auto.lua'; GitBlob = '2eb416f86d18f5854e1d29d17121340051430efa' },
    @{ Source = 'zapret-winws/files/quic_initial_www_google_com.bin'; Destination = 'files/quic_initial_www_google_com.bin'; GitBlob = '80a07cc8870c88be6d8ac7f9bf9dc9bb1979468b' },
    @{ Source = 'zapret-winws/windivert.filter/windivert_part.discord_media.txt'; Destination = 'windivert.filter/windivert_part.discord_media.txt'; GitBlob = 'd84f257adf3aa3e0a7b9c1640f3ee2ef390ae407' },
    @{ Source = 'zapret-winws/windivert.filter/windivert_part.stun.txt'; Destination = 'windivert.filter/windivert_part.stun.txt'; GitBlob = 'a76169025c899816dedbc35efe9f39d92631cf95' },
    @{ Source = 'zapret-winws/windivert.filter/windivert_part.wireguard.txt'; Destination = 'windivert.filter/windivert_part.wireguard.txt'; GitBlob = 'bf62026643604b91e33a8b4f399e26739e5a914d' },
    @{ Source = 'zapret-winws/windivert.filter/windivert_part.quic_initial_ietf.txt'; Destination = 'windivert.filter/windivert_part.quic_initial_ietf.txt'; GitBlob = '566844e186dcdb604084148afe029282fbc9b416' }
)

function Get-GitBlobSha1 {
    param([Parameter(Mandatory = $true)][string]$Path)

    $Bytes = [System.IO.File]::ReadAllBytes($Path)
    $HeaderText = 'blob ' + $Bytes.Length + [char]0
    $Header = [System.Text.Encoding]::ASCII.GetBytes($HeaderText)
    $GitObject = New-Object byte[] ($Header.Length + $Bytes.Length)
    [System.Buffer]::BlockCopy($Header, 0, $GitObject, 0, $Header.Length)
    [System.Buffer]::BlockCopy($Bytes, 0, $GitObject, $Header.Length, $Bytes.Length)

    $Sha = [System.Security.Cryptography.SHA1]::Create()
    try {
        $HashBytes = $Sha.ComputeHash($GitObject)
    }
    finally {
        $Sha.Dispose()
    }
    return ([System.BitConverter]::ToString($HashBytes)).Replace('-', '').ToLowerInvariant()
}

$TempRoot = $null
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Running = Get-Process -Name 'winws2' -ErrorAction SilentlyContinue
    if ($Running) {
        throw 'winws2.exe is running. Stop the Zapret2WinBundle service or standalone profile before updating runtime files.'
    }

    $ExistingItems = @()
    if (Test-Path -LiteralPath $RuntimeRoot) {
        $ExistingItems = @(Get-ChildItem -LiteralPath $RuntimeRoot -Force | Where-Object { $_.Name -ne 'README.md' })
    }

    if ($ExistingItems.Count -gt 0) {
        Write-Host ''
        Write-Host 'An existing runtime was found in bin.'
        Write-Host 'It will be backed up under data\runtime-backup before replacement.'
        $Answer = Read-Host 'Type UPDATE to continue'
        if ($Answer -cne 'UPDATE') {
            Write-Host 'Update cancelled. The current runtime has not been changed.'
            exit 2
        }
    }

    $TempRoot = Join-Path $env:TEMP ('Zapret2-Win-Bundle-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $RuntimeRoot -Force | Out-Null

    Write-Host ''
    Write-Host 'Zapret 2 Win Bundle - official runtime installer' -ForegroundColor Cyan
    Write-Host "Pinned upstream commit: $UpstreamCommit"
    Write-Host 'Downloading and verifying every required file before installation.'
    Write-Host ''

    # Stage and verify the complete set first. A network/hash failure cannot leave a mixed runtime.
    $Index = 0
    foreach ($Item in $Files) {
        $Index++
        $TempFile = Join-Path $TempRoot ($Index.ToString('00') + '.download')
        $Uri = $UpstreamBase + $Item.Source

        Write-Host ('[{0}/{1}] Downloading {2}' -f $Index, $Files.Count, $Item.Destination)
        Invoke-WebRequest -Uri $Uri -OutFile $TempFile -UseBasicParsing -TimeoutSec 90

        $ActualGitBlob = Get-GitBlobSha1 -Path $TempFile
        if ($ActualGitBlob -ne $Item.GitBlob) {
            throw ("Hash mismatch for {0}. Expected {1}, received {2}." -f $Item.Source, $Item.GitBlob, $ActualGitBlob)
        }

        Write-Host ('    verified {0}' -f $ActualGitBlob) -ForegroundColor Green
    }

    # Preserve the previous local runtime before replacing any files.
    if ($ExistingItems.Count -gt 0) {
        $DataRoot = Join-Path $RepoRoot 'data'
        New-Item -ItemType Directory -Path $DataRoot -Force | Out-Null
        $BackupName = 'runtime-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
        $BackupRoot = Join-Path $DataRoot $BackupName
        New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
        foreach ($Item in $ExistingItems) {
            Copy-Item -LiteralPath $Item.FullName -Destination $BackupRoot -Recurse -Force
        }
        Write-Host "Previous runtime backed up to data\$BackupName"
    }

    $Index = 0
    foreach ($Item in $Files) {
        $Index++
        $RelativeDestination = $Item.Destination -replace '/', [System.IO.Path]::DirectorySeparatorChar
        $Destination = Join-Path $RuntimeRoot $RelativeDestination
        $DestinationDirectory = Split-Path -Parent $Destination
        New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
        Move-Item -LiteralPath (Join-Path $TempRoot ($Index.ToString('00') + '.download')) -Destination $Destination -Force
    }

    $VersionText = @(
        'Zapret 2 Windows runtime'
        'Upstream repository: https://github.com/bol-van/zapret-win-bundle'
        ('Pinned commit: ' + $UpstreamCommit)
        'All installed files passed Git blob SHA-1 validation.'
        ('Installed UTC: ' + [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))
    ) -join [Environment]::NewLine
    [System.IO.File]::WriteAllText((Join-Path $RuntimeRoot 'UPSTREAM-VERSION.txt'), $VersionText, [System.Text.Encoding]::ASCII)

    Write-Host ''
    Write-Host 'Runtime installed and verified successfully.' -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ''
    Write-Host ('RUNTIME SETUP FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
finally {
    if ($TempRoot -and (Test-Path -LiteralPath $TempRoot)) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
