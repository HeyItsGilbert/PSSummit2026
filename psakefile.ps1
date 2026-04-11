Version 5

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
    Where-Object {
      $Exclude -notcontains $_.Name -and
      # Exclude files whose path contains any directory segment starting with a dot
      ($_.FullName.Substring($RootDir.Length) -split '[/\\]' | Where-Object { $_ -match '^\.' }).Count -eq 0
    }

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

# Helper: copy images referenced in markdown and Background.png to output folder
function Copy-DeckAssets {
  param(
    [Parameter(Mandatory)] [string] $MarkdownPath,
    [Parameter(Mandatory)] [string] $OutputDir
  )

  $mdDir = Split-Path -Path $MarkdownPath -Parent
  $content = Get-Content -Path $MarkdownPath -Raw -ErrorAction Stop

  # Find markdown image references: ![alt](path)
  $mdImages = [regex]::Matches($content, '!\[.*?\]\(([^)]+)\)') | ForEach-Object { $_.Groups[1].Value }

  # Find HTML img tags: <img src="path" ...>
  $htmlImages = [regex]::Matches($content, '<img[^>]+src=["'']([^"'']+)["''][^>]*>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) |
    ForEach-Object { $_.Groups[1].Value }

  # Combine and filter local paths (skip URLs)
  $allImages = ($mdImages + $htmlImages) | Where-Object { $_ -and ($_ -notmatch '^https?://') }

  foreach ($img in $allImages) {
    # Resolve relative to markdown file location
    $srcPath = Join-Path $mdDir $img | Resolve-Path -ErrorAction SilentlyContinue
    if ($srcPath -and (Test-Path $srcPath)) {
      $destPath = Join-Path $OutputDir (Split-Path -Leaf $srcPath)
      if (-not (Test-Path $destPath)) {
        Copy-Item -Path $srcPath -Destination $destPath -Force
        Write-Host "  [asset] Copied $img -> $destPath" -ForegroundColor DarkGray
      }
    }
  }

  # Always copy Background.png if it exists in repo root
  @(
    'Background.png',
    'cc-by-sa.png',
    'date.png',
    'powershell-logo.png',
    'powershell-summit-logo-top-left.png',
    'powershell-summit-logo.png',
    'PSHSummit26-Sponsors.png'
  ) | ForEach-Object {
    $bgPath = Join-Path $RootDir $_
    if (Test-Path $bgPath) {
      $bgDest = Join-Path $OutputDir $_
      if (-not (Test-Path $bgDest)) {
        Copy-Item -Path $bgPath -Destination $bgDest -Force
        Write-Host "  [asset] Copied $_ -> $bgDest" -ForegroundColor DarkGray
      }
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

  # Copy image assets to output directory
  Copy-DeckAssets -MarkdownPath $MarkdownPath -OutputDir $outDir

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

Task 'CopyTheme' @{
  DependsOn = 'EnsureMarp'
  Description = 'Copy theme CSS and assets to dist/'
  Inputs = {
    @($ThemeCss, (Join-Path $RootDir 'Background.png')) | Where-Object { Test-Path $_ } | Get-Item
  }
  Outputs = {
    @($ThemeCss, (Join-Path $RootDir 'Background.png')) |
      Where-Object { Test-Path $_ } |
      ForEach-Object { Join-Path $DistDir (Split-Path $_ -Leaf) } |
      Where-Object { Test-Path $_ } |
      Get-Item
  }
  Action = {
    Write-Host "Copying theme files to $DistDir" -ForegroundColor Cyan

    # Copy theme CSS
    if (Test-Path $ThemeCss) {
      Copy-Item -Path $ThemeCss -Destination $DistDir -Force
      Write-Host "  Copied $(Split-Path $ThemeCss -Leaf)" -ForegroundColor Green
    }

    # Copy Background.png if it exists (used by the theme)
    $backgroundPath = Join-Path $RootDir 'Background.png'
    if (Test-Path $backgroundPath) {
      Copy-Item -Path $backgroundPath -Destination $DistDir -Force
      Write-Host "  Copied Background.png" -ForegroundColor Green
    }
  }
}

Task 'ExportHtml' @{
  DependsOn = 'EnsureMarp'
  Description = 'Export all decks (marp: true) to HTML under dist/'
  Inputs = { @(Get-DeckFiles) + @(Get-Item $ThemeCss) }
  Outputs = { Get-ChildItem -Path $DistDir -Recurse -Filter *.html -ErrorAction SilentlyContinue }
  Action = {
    $decks = Get-DeckFiles
    if (-not $decks) { Write-Warning 'No decks found with marp: true'; return }
    foreach ($d in $decks) { Invoke-MarpExport -MarkdownPath $d.FullName -Format html }
  }
}

Task 'ExportPdf' @{
  DependsOn = 'EnsureMarp'
  Description = 'Export all decks (marp: true) to PDF under dist/ (allows local files)'
  Inputs = { @(Get-DeckFiles) + @(Get-Item $ThemeCss) }
  Outputs = { Get-ChildItem -Path $DistDir -Recurse -Filter *.pdf -ErrorAction SilentlyContinue }
  Action = {
    $decks = Get-DeckFiles
    if (-not $decks) { Write-Warning 'No decks found with marp: true'; return }
    foreach ($d in $decks) { Invoke-MarpExport -MarkdownPath $d.FullName -Format pdf }
  }
}

Task 'ExportPptx' @{
  DependsOn = 'EnsureMarp'
  Description = 'Export all decks (marp: true) to PPTX under dist/ (allows local files)'
  Inputs = { @(Get-DeckFiles) + @(Get-Item $ThemeCss) }
  Outputs = { Get-ChildItem -Path $DistDir -Recurse -Filter *.pptx -ErrorAction SilentlyContinue }
  Action = {
    $decks = Get-DeckFiles
    if (-not $decks) { Write-Warning 'No decks found with marp: true'; return }
    foreach ($d in $decks) { Invoke-MarpExport -MarkdownPath $d.FullName -Format pptx }
  }
}

Task ExportAll -Depends CopyTheme, ExportHtml, ExportPdf, ExportPptx -Description 'Run HTML, PDF, and PPTX exports for all decks' {}

Task 'GenerateIndex' @{
  DependsOn = 'ExportAll'
  Description = 'Generate an index.html linking to all exported decks'
  Action = {
    $htmlFiles = Get-ChildItem -Path $DistDir -Recurse -Filter '*.html' |
      Where-Object { $_.Name -ne 'index.html' } |
      Sort-Object FullName

    $links = foreach ($f in $htmlFiles) {
      $rel = $f.FullName.Substring($DistDir.Length + 1) -replace '\\', '/'
      $name = [IO.Path]::GetFileNameWithoutExtension($f.Name) -replace '-', ' '
      # Split on camelCase/PascalCase boundaries then title-case
      $name = ($name -creplace '([a-z])([A-Z])', '$1 $2')
      $name = (Get-Culture).TextInfo.ToTitleCase($name)
      "      <li><a href=`"$rel`">$name</a></li>"
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Summit 2026 Decks</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 600px; margin: 4rem auto; padding: 0 1rem; }
    h1 { margin-bottom: 0.25rem; }
    p { color: #666; margin-top: 0; }
    ul { list-style: none; padding: 0; }
    li { margin: 0.75rem 0; }
    a { color: #6d28d9; text-decoration: none; font-size: 1.125rem; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>Summit 2026 Decks</h1>
  <p>PowerShell + DevOps Global Summit</p>
  <ul>
$($links -join "`n")
  </ul>
</body>
</html>
"@

    $indexPath = Join-Path $DistDir 'index.html'
    Set-Content -Path $indexPath -Value $html -Encoding utf8
    Write-Host "[index] Generated $indexPath" -ForegroundColor Cyan
  }
}

Task LaunchWebpages -Depends ExportHtml -Description 'Open the dist/ folder in the default file explorer' {
  Get-ChildItem -Path $DistDir -Recurse -Filter *.html | ForEach-Object { Invoke-Item $_.FullName }
}

Task default -Depends GenerateIndex -Description 'Default task: export all decks and generate index'
