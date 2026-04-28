# claude-wyvrn - installer and CLI for the Wyvrn Claude harness (Windows / PowerShell).
# Bootstrap:  iwr -useb https://raw.githubusercontent.com/andrewputrajaya/claude-wyvrn/main/install.ps1 | iex
# Installed:  invoked as `claude-wyvrn <verb>` after first install.
#
# If your environment blocks `iex`, save the file and run:
#   Set-ExecutionPolicy -Scope Process Bypass; .\install.ps1
[CmdletBinding()]
param(
    [Parameter(Position = 0)] [string] $Command = 'install',
    [Parameter(ValueFromRemainingArguments = $true)] [string[]] $Rest
)

$ErrorActionPreference = 'Stop'

$Repo         = 'andrewputrajaya/claude-wyvrn'
$InstallDir   = Join-Path $HOME '.claude-wyvrn'
$BinDir       = Join-Path $InstallDir 'bin'
$InternalDir  = Join-Path $InstallDir '.bin'
$Manifest     = Join-Path $InstallDir '.installed-manifest.txt'
$SkeletonDir  = Join-Path $InstallDir '.skeleton'
$ZipName      = 'claude-wyvrn.zip'
$SumsName     = 'SHA256SUMS'
$ShimPs1      = Join-Path $BinDir 'claude-wyvrn.ps1'
$ShimCmd      = Join-Path $BinDir 'claude-wyvrn.cmd'

function Die($msg)  { Write-Error "claude-wyvrn: $msg"; exit 1 }
function Info($msg) { Write-Host "claude-wyvrn: $msg" }

function Resolve-Version {
    $v = if ($env:CLAUDE_WYVRN_VERSION) { $env:CLAUDE_WYVRN_VERSION } else { 'latest' }
    if ($v -in @('latest','local')) { return $v }
    return ($v -replace '^v','')
}

function Read-VersionFile($path) {
    if (-not (Test-Path $path)) { return $null }
    return (Get-Content $path -Raw).Trim()
}

function Get-FileSha256Lower($path) {
    return (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLower()
}

function Test-Sha256($file, $expected) {
    $actual = Get-FileSha256Lower $file
    if ($actual -ne $expected.ToLower()) {
        Die "checksum mismatch for $file (expected $expected, got $actual)"
    }
    Info "verified sha256: $actual"
}

function Download($url, $out) {
    Info "downloading $url"
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $out
}

function Get-Release($version, $tmp) {
    $base = if ($version -eq 'latest') {
        "https://github.com/$Repo/releases/latest/download"
    } else {
        "https://github.com/$Repo/releases/download/v$version"
    }
    Download "$base/$ZipName"     (Join-Path $tmp $ZipName)
    Download "$base/$SumsName"    (Join-Path $tmp $SumsName)
    Download "$base/install.ps1"  (Join-Path $tmp 'install.ps1')
    $sums = Get-Content (Join-Path $tmp $SumsName)
    foreach ($name in @($ZipName, 'install.ps1')) {
        $line = $sums | Where-Object { $_ -match "\s+$([regex]::Escape($name))$" } | Select-Object -First 1
        if (-not $line) { Die "$name not listed in $SumsName" }
        $expected = ($line -split '\s+', 2)[0]
        Test-Sha256 (Join-Path $tmp $name) $expected
    }
    Expand-Archive -Path (Join-Path $tmp $ZipName) -DestinationPath $tmp -Force
    if (-not (Test-Path (Join-Path $tmp '.claude-wyvrn'))) { Die "release archive missing .claude-wyvrn/" }
    if (-not (Test-Path (Join-Path $tmp '.skeleton')))     { Die "release archive missing .skeleton/" }
}

function Initialize-LocalSource($selfDir, $tmp) {
    foreach ($p in @('.claude-wyvrn', '.claude-wyvrn-local', 'CLAUDE.md')) {
        if (-not (Test-Path (Join-Path $selfDir $p))) {
            Die "local mode: $selfDir\$p not found (run install.ps1 from repo root)"
        }
    }
    Copy-Item -Recurse -Force (Join-Path $selfDir '.claude-wyvrn') (Join-Path $tmp '.claude-wyvrn')
    New-Item -ItemType Directory -Force -Path (Join-Path $tmp '.skeleton') | Out-Null
    Copy-Item -Recurse -Force (Join-Path $selfDir '.claude-wyvrn-local') (Join-Path $tmp '.skeleton\.claude-wyvrn-local')
    Copy-Item -Force          (Join-Path $selfDir 'CLAUDE.md')           (Join-Path $tmp '.skeleton\CLAUDE.md')
}

function Write-Manifest($version, $root) {
    $lines = @(
        "# claude-wyvrn manifest",
        "# version: $version",
        "# installed_at: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
    )
    $files = Get-ChildItem -Path $root -Recurse -File | Where-Object {
        $rel = $_.FullName.Substring($root.Length + 1) -replace '\\','/'
        ($rel -ne '.installed-manifest.txt') -and ($rel -notlike '.bin/*') -and ($rel -notlike '.skeleton/*')
    }
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($root.Length + 1) -replace '\\','/'
        $hash = Get-FileSha256Lower $f.FullName
        $lines += "$hash  $rel"
    }
    Set-Content -Path $Manifest -Value $lines -Encoding ASCII
}

function Install-Shim($selfPath, $tmp) {
    New-Item -ItemType Directory -Force -Path $BinDir, $InternalDir | Out-Null
    $internalScript = Join-Path $InternalDir 'install.ps1'
    $releaseScript  = if ($tmp) { Join-Path $tmp 'install.ps1' } else { $null }
    if ($releaseScript -and (Test-Path -LiteralPath $releaseScript)) {
        Copy-Item -Force $releaseScript $internalScript
    } elseif ($selfPath -and (Test-Path -LiteralPath $selfPath)) {
        $selfResolved = (Resolve-Path -LiteralPath $selfPath).Path
        $destResolved = if (Test-Path -LiteralPath $internalScript) {
            (Resolve-Path -LiteralPath $internalScript).Path
        } else { $internalScript }
        if ($selfResolved -ne $destResolved) {
            Copy-Item -Force $selfPath $internalScript
        }
    } else {
        Die "cannot install CLI shim: install.ps1 not available from release or local path (this should not happen - please report)"
    }
    @"
# claude-wyvrn shim
& '$internalScript' @args
"@ | Set-Content -Path $ShimPs1 -Encoding ASCII
    @"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$internalScript" %*
"@ | Set-Content -Path $ShimCmd -Encoding ASCII
}

function Add-ToUserPath($dir) {
    $current = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ([string]::IsNullOrEmpty($current)) { $current = '' }
    $segments = $current -split ';' | Where-Object { $_ -ne '' }
    $persisted = $false
    if ($segments -notcontains $dir) {
        $new = if ($current) { "$current;$dir" } else { $dir }
        [Environment]::SetEnvironmentVariable('PATH', $new, 'User')
        $persisted = $true
    }
    if (($env:PATH -split ';') -notcontains $dir) {
        $env:PATH = "$env:PATH;$dir"
        if ($persisted) {
            Info "added $dir to user PATH (active in this shell now; restart other open shells to pick it up)"
        } else {
            Info "added $dir to current session PATH (already in user PATH)"
        }
    }
}

$ProfileMarkerStart = '# >>> claude-wyvrn PATH >>>'
$ProfileMarkerEnd   = '# <<< claude-wyvrn PATH <<<'

function Update-PSProfile {
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (-not $profilePath) { return }
    $profileDir = Split-Path -Parent $profilePath
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Force -Path $profileDir | Out-Null }
    $content = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { '' }
    if ($null -eq $content) { $content = '' }
    if ($content -match [regex]::Escape($ProfileMarkerStart)) { return }
    $block = @"
$ProfileMarkerStart
`$__cw_bin = Join-Path `$HOME '.claude-wyvrn\bin'
if ((Test-Path `$__cw_bin) -and ((`$env:PATH -split ';') -notcontains `$__cw_bin)) { `$env:PATH += ";`$__cw_bin" }
Remove-Variable __cw_bin -ErrorAction SilentlyContinue
$ProfileMarkerEnd
"@
    if ($content -and -not $content.EndsWith("`n")) { $content += "`r`n" }
    Set-Content -Path $profilePath -Value ($content + $block) -Encoding UTF8
    Info "added PATH ensure to PowerShell profile: $profilePath"
}

function Remove-FromPSProfile {
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (-not $profilePath -or -not (Test-Path $profilePath)) { return }
    $content = Get-Content $profilePath -Raw
    if (-not $content) { return }
    $pattern = '(?s)' + [regex]::Escape($ProfileMarkerStart) + '.*?' + [regex]::Escape($ProfileMarkerEnd) + '\r?\n?'
    $new = $content -replace $pattern, ''
    if ($new -ne $content) {
        Set-Content -Path $profilePath -Value $new -Encoding UTF8
        Info "removed PATH ensure from PowerShell profile: $profilePath"
    }
}

function Install-Payload($tmp, $version, $selfPath) {
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    }
    $preserve = @('.bin', 'bin', '.installed-manifest.txt')
    Get-ChildItem $InstallDir -Force | Where-Object { $preserve -notcontains $_.Name } | ForEach-Object {
        Remove-Item -Recurse -Force $_.FullName
    }
    Copy-Item -Recurse -Force (Join-Path $tmp '.claude-wyvrn\*') $InstallDir
    $skel = Join-Path $InstallDir '.skeleton'
    if (Test-Path $skel) { Remove-Item -Recurse -Force $skel }
    New-Item -ItemType Directory -Force -Path $skel | Out-Null
    Copy-Item -Recurse -Force (Join-Path $tmp '.skeleton\*') $skel
    Install-Shim $selfPath $tmp
    Write-Manifest $version $InstallDir
    Add-ToUserPath $BinDir
    Update-PSProfile
}

function Invoke-Install {
    $selfPath = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
    $version = Resolve-Version
    if ($version -ne 'local' -and (Test-Path (Join-Path $InstallDir 'VERSION'))) {
        $current = Read-VersionFile (Join-Path $InstallDir 'VERSION')
        if ($version -ne 'latest' -and $version -eq $current) {
            Info "already at version $current"
            return
        }
    }
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("claude-wyvrn-" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    try {
        if ($version -eq 'local') {
            if (-not $selfPath) { Die "local mode requires running install.ps1 from a saved file (not via iex)" }
            $selfDir = Split-Path -Parent $selfPath
            Info "installing from local source at $selfDir"
            Initialize-LocalSource $selfDir $tmp
            $version = (Read-VersionFile (Join-Path $tmp '.claude-wyvrn\VERSION')) + '-local'
        } else {
            Get-Release $version $tmp
            if ($version -eq 'latest') {
                $version = Read-VersionFile (Join-Path $tmp '.claude-wyvrn\VERSION')
            }
        }
        Install-Payload $tmp $version $selfPath
        Info "installed claude-wyvrn $version to $InstallDir"
    } finally {
        if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
    }
}

function Invoke-Update { if (-not (Test-Path $InstallDir)) { Die "not installed. Run: claude-wyvrn install" }; Invoke-Install }

function Invoke-Init {
    if (-not (Test-Path $SkeletonDir)) { Die "skeleton missing at $SkeletonDir. Run: claude-wyvrn install" }
    if (Test-Path '.\.claude-wyvrn-local') {
        Die "project already initialized (.claude-wyvrn-local\ exists). To update skeleton structure and CLAUDE.md, run: claude-wyvrn refresh"
    }
    $preserve = $false
    if (Test-Path '.\CLAUDE.md') {
        $existingHash = Get-FileSha256Lower '.\CLAUDE.md'
        $skeletonHash = Get-FileSha256Lower (Join-Path $SkeletonDir 'CLAUDE.md')
        if ($existingHash -ne $skeletonHash) { $preserve = $true }
    }
    Copy-Item -Recurse -Force (Join-Path $SkeletonDir '.claude-wyvrn-local') '.\.claude-wyvrn-local'
    if ($preserve) {
        Move-Item -Force '.\CLAUDE.md' '.\.claude-wyvrn-local\PROJECT.md'
        Info "preserved previous CLAUDE.md as .claude-wyvrn-local\PROJECT.md"
    }
    Copy-Item -Force (Join-Path $SkeletonDir 'CLAUDE.md') '.\CLAUDE.md'
    Info "initialized project skeleton in $(Get-Location)"
}

function Invoke-Uninit {
    if (-not (Test-Path '.\.claude-wyvrn-local')) {
        Die ".claude-wyvrn-local\ not found in cwd; nothing to uninit"
    }
    $force = ($script:Rest -contains '--force') -or ($script:Rest -contains '-f')
    $dirty = @()
    $artifactDirs = @('features','fixes','refactors','decisions','clarifications','reviews','verifier-gaps','.archive','conventions')
    foreach ($d in $artifactDirs) {
        $path = Join-Path '.\.claude-wyvrn-local' $d
        if (Test-Path $path) {
            $contents = Get-ChildItem $path -Recurse -File -Force | Where-Object { $_.Name -ne '.gitkeep' }
            if ($contents) { $dirty += "$d\ ($($contents.Count) file(s))" }
        }
    }
    $archProject  = '.\.claude-wyvrn-local\ARCHITECTURE.md'
    $archSkeleton = Join-Path $SkeletonDir '.claude-wyvrn-local\ARCHITECTURE.md'
    if ((Test-Path $archProject) -and (Test-Path $archSkeleton)) {
        if ((Get-FileSha256Lower $archProject) -ne (Get-FileSha256Lower $archSkeleton)) {
            $dirty += "ARCHITECTURE.md (modified from template)"
        }
    }
    if ($dirty -and -not $force) {
        Write-Host "claude-wyvrn: uninit would discard the following user content:"
        foreach ($d in $dirty) { Write-Host "  - $d" }
        Die "refusing to uninit. Back up the listed items, then re-run with --force."
    }
    if (Test-Path '.\.claude-wyvrn-local\PROJECT.md') {
        Move-Item -Force '.\.claude-wyvrn-local\PROJECT.md' '.\CLAUDE.md'
        Info "restored CLAUDE.md from PROJECT.md"
    } elseif (Test-Path '.\CLAUDE.md') {
        Remove-Item -Force '.\CLAUDE.md'
        Info "removed CLAUDE.md"
    }
    Remove-Item -Recurse -Force '.\.claude-wyvrn-local'
    Info "removed .claude-wyvrn-local\"
    Info "uninit complete; project no longer depends on claude-wyvrn"
}

function Invoke-Refresh {
    if (-not (Test-Path $SkeletonDir)) { Die "skeleton missing at $SkeletonDir. Run: claude-wyvrn install" }
    if (-not (Test-Path '.\.claude-wyvrn-local')) {
        Die ".claude-wyvrn-local\ not found in cwd. Run: claude-wyvrn init"
    }
    $skelClaudePath = Join-Path $SkeletonDir 'CLAUDE.md'
    $needsUpdate = $true
    if (Test-Path '.\CLAUDE.md') {
        $needsUpdate = (Get-FileSha256Lower '.\CLAUDE.md') -ne (Get-FileSha256Lower $skelClaudePath)
    }
    if ($needsUpdate) {
        Copy-Item -Force $skelClaudePath '.\CLAUDE.md'
        Info "updated CLAUDE.md"
    } else {
        Info "CLAUDE.md already up-to-date"
    }
    $skelLocal = Join-Path $SkeletonDir '.claude-wyvrn-local'
    $added = 0
    Get-ChildItem $skelLocal -Recurse -Force | ForEach-Object {
        $rel    = $_.FullName.Substring($skelLocal.Length + 1)
        $target = Join-Path '.\.claude-wyvrn-local' $rel
        if ($_.PSIsContainer) {
            if (-not (Test-Path $target)) {
                New-Item -ItemType Directory -Force -Path $target | Out-Null
                Info "added dir: .claude-wyvrn-local\$rel"
                $added++
            }
        } else {
            if (-not (Test-Path $target)) {
                $parent = Split-Path -Parent $target
                if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
                Copy-Item -Force $_.FullName $target
                Info "added file: .claude-wyvrn-local\$rel"
                $added++
            }
        }
    }
    if ($added -eq 0) { Info "skeleton already complete; PROJECT.md, ARCHITECTURE.md, and artifacts left untouched" }
    else              { Info "refresh complete ($added items added; PROJECT.md, ARCHITECTURE.md, and artifacts left untouched)" }
}

function Invoke-Doctor {
    if (-not (Test-Path $InstallDir)) { Die "not installed at $InstallDir" }
    foreach ($f in @('VERSION', 'HARNESS.md', 'INDEX.md')) {
        if (-not (Test-Path (Join-Path $InstallDir $f))) { Die "required file missing: $InstallDir\$f" }
    }
    $current = Read-VersionFile (Join-Path $InstallDir 'VERSION')
    Info "installed: $current"
    if (Test-Path $Manifest) {
        $bad = 0
        Get-Content $Manifest | Where-Object { $_ -and ($_ -notmatch '^#') } | ForEach-Object {
            $parts = $_ -split '\s+', 2
            $expected = $parts[0]
            $rel = $parts[1]
            $full = Join-Path $InstallDir ($rel -replace '/', '\')
            if (-not (Test-Path $full)) { $bad++; return }
            $actual = Get-FileSha256Lower $full
            if ($actual -ne $expected) { $bad++ }
        }
        if ($bad -eq 0) { Info "manifest: ok" } else { Info "manifest: $bad MISMATCH(es) (run: claude-wyvrn update)" }
    } else {
        Info "manifest: missing"
    }
    $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User') -split ';'
    if ($userPath -contains $BinDir) { Info "PATH: $BinDir present" } else { Info "PATH: $BinDir NOT in PATH" }
    try {
        $rel = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/$Repo/releases/latest"
        $latest = ($rel.tag_name -replace '^v','')
        if ($latest -and $latest -ne $current) { Info "update available: $latest (run: claude-wyvrn update)" }
        elseif ($latest) { Info "latest: $latest (up to date)" }
    } catch { Info "could not check latest version: $($_.Exception.Message)" }
}

function Invoke-Version {
    $vf = Join-Path $InstallDir 'VERSION'
    if (-not (Test-Path $vf)) { Die "not installed" }
    Write-Host (Read-VersionFile $vf)
}

function Invoke-Uninstall {
    if (Test-Path $InstallDir) { Remove-Item -Recurse -Force $InstallDir }
    foreach ($s in @($ShimPs1, $ShimCmd)) { if (Test-Path $s) { Remove-Item -Force $s } }
    $current = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ($current) {
        $kept = ($current -split ';' | Where-Object { $_ -and ($_ -ne $BinDir) }) -join ';'
        if ($kept -ne $current) { [Environment]::SetEnvironmentVariable('PATH', $kept, 'User') }
    }
    Remove-FromPSProfile
    Info "uninstalled claude-wyvrn"
}

function Invoke-Help {
    @'
claude-wyvrn - Wyvrn Claude harness installer/CLI

Usage: claude-wyvrn <command>

Commands:
  install      Install the harness to ~/.claude-wyvrn/
  update       Update to the latest release (or CLAUDE_WYVRN_VERSION)
  init         Initialize a new project (CLAUDE.md + .claude-wyvrn-local/).
               Auto-preserves any pre-existing CLAUDE.md to PROJECT.md.
  refresh      Re-apply skeleton in an already-initialized project.
               Overwrites CLAUDE.md, additively adds missing dirs/files.
               Never touches PROJECT.md, ARCHITECTURE.md, or artifacts.
  uninit       Inverse of init: restore PROJECT.md as CLAUDE.md and remove
               .claude-wyvrn-local/. Refuses if artifacts present;
               override with --force.
  doctor       Verify install integrity, check for updates
  version      Print installed harness version
  uninstall    Remove ~/.claude-wyvrn/ and CLI shim (global, not per-project)
  help         Show this help

Environment:
  CLAUDE_WYVRN_VERSION   Pin to a release version (e.g. 0.2.1) or 'local' for
                         dev installs from a repo checkout. Default: latest.
'@ | Write-Host
}

switch ($Command) {
    'install'   { Invoke-Install }
    'update'    { Invoke-Update }
    'init'      { Invoke-Init }
    'refresh'   { Invoke-Refresh }
    'uninit'    { Invoke-Uninit }
    'doctor'    { Invoke-Doctor }
    'version'   { Invoke-Version }
    '--version' { Invoke-Version }
    '-v'        { Invoke-Version }
    'uninstall' { Invoke-Uninstall }
    'help'      { Invoke-Help }
    '--help'    { Invoke-Help }
    '-h'        { Invoke-Help }
    default     { Die "unknown command: $Command (try: claude-wyvrn help)" }
}
