# psake build script for Summit 2026 Marp theme exports

Properties {
  # Root paths
  $RootDir = $PSScriptRoot
  $ThemeCss = Join-Path $RootDir 'summit-2026.css'
  $DistDir = Join-Path $RootDir 'dist'

  # Executable name (assumes global install: npm i -g @marp-team/marp-cli)
  $MarpExe = 'marp'

  # Markdown discovery settings
  $Glob = '*.md'
  $Exclude = @('README.md', 'AGENTS.md')
  # Mark properties as referenced for static analyzers
  $null = $RootDir, $ThemeCss, $DistDir, $MarpExe, $Glob, $Exclude
}

# Helper: ensure marp CLI exists
Task EnsureMarp -Description 'Verify marp CLI and theme file exist; ensure dist/ is created' {
  if (-not (Get-Command $MarpExe -ErrorAction SilentlyContinue)) {
    throw "Marp CLI not found. Install with: npm i -g @marp-team/marp-cli"
  }
  if (-not (Test-Path $ThemeCss)) {
    throw "Theme CSS not found at $ThemeCss"
  }
  if (-not (Test-Path $DistDir)) {
    $null = New-Item -ItemType Directory -Path $DistDir
  }
}

# Helper: discover deck files that opt in with `marp: true`
function Get-DeckFiles {
  $files = Get-ChildItem -Path $RootDir -Filter $Glob -Recurse -File |
    Where-Object { $Exclude -notcontains $_.Name }

  foreach ($f in $files) {
    try {
      $head = Get-Content -Path $f.FullName -TotalCount 50 -ErrorAction Stop
      if ($head -match "^---\s*$" -and ($head -match "^marp:\s*true\b")) {
        $f
      }
    } catch {
      Write-Warning "Skipping $($f.FullName): $($_.Exception.Message)"
    }
  }
}

# Helper: export wrapper
function Invoke-MarpExport {
  param(
    [Parameter(Mandatory)] [string] $MarkdownPath,
    [Parameter(Mandatory)] [ValidateSet('html', 'pdf', 'pptx')] [string] $Format
  )

  $rel = Resolve-Path -Path $MarkdownPath | ForEach-Object { $_.Path.Substring($RootDir.Length).TrimStart([char][IO.Path]::DirectorySeparatorChar, [char][IO.Path]::AltDirectorySeparatorChar) }
  $relDir = Split-Path -Path $rel -Parent
  $base = [IO.Path]::GetFileNameWithoutExtension($MarkdownPath)

  $outDir = if ([string]::IsNullOrWhiteSpace($relDir)) { $DistDir } else { Join-Path $DistDir $relDir }
  if (-not (Test-Path $outDir)) { $null = New-Item -ItemType Directory -Path $outDir -Force }

  $outFile = Join-Path $outDir ("$base.$Format")

  $marpParams = @(
    $MarkdownPath,
    '--theme-set', $ThemeCss,
    "--$Format",
    '--output', $outFile
  )
  # Allow local files when producing PDF/PPTX (Chromium sandbox)
  if ($Format -in @('pdf', 'pptx')) { $marpParams += '--allow-local-files' }

  Write-Host "[marp] $Format -> $outFile" -ForegroundColor Cyan

  # Resolve the actual executable/script path for marp (may be a .cmd shim on Windows)
  $marpCmd = Get-Command $MarpExe -ErrorAction Stop
  $marpPath = $marpCmd.Source

  try {
    & $marpPath @marpParams
    $exit = $LASTEXITCODE
  } catch {
    throw "Failed invoking marp CLI at '$marpPath': $($_.Exception.Message)"
  }

  if ($exit -ne 0) {
    throw "Marp export failed ($Format) for $MarkdownPath with exit code $exit"
  }
}

Task Clean -Description 'Remove the dist/ output directory (fresh build)' {
  if (Test-Path $DistDir) {
    Write-Host "Cleaning $DistDir" -ForegroundColor Yellow
    Remove-Item -Path $DistDir -Recurse -Force
  }
}

Task CopyTheme -Depends EnsureMarp -Description 'Copy theme CSS and assets to dist/' {
  Write-Host "Copying theme files to $DistDir" -ForegroundColor Cyan

  # Copy theme CSS
  if (Test-Path $ThemeCss) {
    Copy-Item -Path $ThemeCss -Destination $DistDir -Force
    Write-Host "  Copied $(Split-Path $ThemeCss -Leaf)" -ForegroundColor Green
  }

  # Copy Background.jpg if it exists (used by the theme)
  $backgroundPath = Join-Path $RootDir 'Background.jpg'
  if (Test-Path $backgroundPath) {
    Copy-Item -Path $backgroundPath -Destination $DistDir -Force
    Write-Host "  Copied Background.jpg" -ForegroundColor Green
  }
}

Task ExportHtml -Depends EnsureMarp -Description 'Export all decks (marp: true) to HTML under dist/' {
  $decks = Get-DeckFiles
  if (-not $decks) { Write-Warning 'No decks found with marp: true'; return }
  foreach ($d in $decks) { Invoke-MarpExport -MarkdownPath $d.FullName -Format html }
}

Task ExportPdf -Depends EnsureMarp -Description 'Export all decks (marp: true) to PDF under dist/ (allows local files)' {
  $decks = Get-DeckFiles
  if (-not $decks) { Write-Warning 'No decks found with marp: true'; return }
  foreach ($d in $decks) { Invoke-MarpExport -MarkdownPath $d.FullName -Format pdf }
}

Task ExportPptx -Depends EnsureMarp -Description 'Export all decks (marp: true) to PPTX under dist/ (allows local files)' {
  $decks = Get-DeckFiles
  if (-not $decks) { Write-Warning 'No decks found with marp: true'; return }
  foreach ($d in $decks) { Invoke-MarpExport -MarkdownPath $d.FullName -Format pptx }
}

Task ExportAll -Depends CopyTheme, ExportHtml, ExportPdf, ExportPptx -Description 'Run HTML, PDF, and PPTX exports for all decks' {}

Task default -Depends ExportAll -Description 'Default task: export HTML, PDF, and PPTX for all decks'
