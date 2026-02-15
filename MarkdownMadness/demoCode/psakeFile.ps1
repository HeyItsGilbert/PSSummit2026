# ---------------------------------------------------------------------------
# psakeFile.ps1 — Markdown Madness demo scaffolding for PS Summit 2026
# ---------------------------------------------------------------------------
# Called by build.ps1: ./build.ps1 ScaffoldAll | ScaffoldJekyll | Clean | ...
# ---------------------------------------------------------------------------

# ── Shared Configuration ──────────────────────────────────────────────────
Properties {
    # Set script-scoped variables for content and output paths
    # DemoRoot is where all scaffolded sites will be created (./sites/)
    $script:DemoRoot = Join-Path $PSScriptRoot 'sites'
    # ContentRoot is where our source markdown and assets live (./docs/, ./blog/, ./images/)
    $script:ContentRoot = $PSScriptRoot   # docs/, blog/, images/ live under demoCode/
}

# ── Helper Function ───────────────────────────────────────────────────────

function Copy-SampleContent {
    <#
    .SYNOPSIS
        Copies sample markdown and asset files to a destination, creating
        parent directories as needed.
    .PARAMETER Destination
        The root directory of the target site scaffold.
    .PARAMETER FileMap
        A hashtable mapping source paths (relative to $script:ContentRoot)
        to destination paths (relative to $Destination).
    .PARAMETER FrontMatterKeys
        Optional ordered dictionary of YAML front-matter keys to inject into
        every copied markdown file. Keys are added after the opening '---' line.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Destination,

        [Parameter(Mandatory)]
        [hashtable]$FileMap,

        [System.Collections.Specialized.OrderedDictionary]$FrontMatterKeys
    )

    foreach ($entry in $FileMap.GetEnumerator()) {
        $sourcePath = Join-Path $script:ContentRoot $entry.Key
        $targetPath = Join-Path $Destination $entry.Value

        # Ensure the parent directory exists
        $targetDir = Split-Path -Path $targetPath -Parent
        if (-not (Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        }

        if (Test-Path $sourcePath -PathType Container) {
            # Copy entire directory tree (e.g. images/)
            Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
            Write-Host "  [copy-dir]  $($entry.Key) -> $($entry.Value)"
        } else {
            $content = Get-Content -Path $sourcePath -Raw

            # Inject additional front-matter keys when requested
            if ($FrontMatterKeys -and $FrontMatterKeys.Count -gt 0 -and $targetPath -match '\.md$') {
                $yamlLines = ($FrontMatterKeys.GetEnumerator() | ForEach-Object {
                        "$($_.Key): $($_.Value)"
                    }) -join "`n"

                if ($content -match '^---\s*\r?\n') {
                    # Insert new keys right after the opening ---
                    $content = $content -replace '^(---\s*\r?\n)', "`$1$yamlLines`n"
                } else {
                    # No existing front matter — wrap with ---
                    $content = "---`n$yamlLines`n---`n$content"
                }
            }

            Set-Content -Path $targetPath -Value $content -NoNewline
            Write-Host "  [copy]      $($entry.Key) -> $($entry.Value)"
        }
    }
}

# ── Tasks ─────────────────────────────────────────────────────────────────

Task default -Depends ScaffoldAll -Description 'Run all scaffold tasks'

# ---------- Init / Clean --------------------------------------------------

Task Init -Description 'Create the demo output directory' {
    if (-not (Test-Path $script:DemoRoot)) {
        New-Item -Path $script:DemoRoot -ItemType Directory -Force | Out-Null
        Write-Host "[Init] Created demo root: $script:DemoRoot"
    } else {
        Write-Host "[Init] Demo root already exists: $script:DemoRoot"
    }
}

Task Clean -Description 'Remove the demo output directory entirely' {
    if (Test-Path $script:DemoRoot) {
        Remove-Item -Path $script:DemoRoot -Recurse -Force
        Write-Host "[Clean] Removed: $script:DemoRoot"
    } else {
        Write-Host "[Clean] Nothing to clean — $script:DemoRoot does not exist."
    }
}

# ---------- Jekyll --------------------------------------------------------

Task ScaffoldJekyll -Depends Init -Description 'Scaffold a Jekyll site and copy sample content' {
    $sitePath = Join-Path $script:DemoRoot 'jekyll-demo'

    if (Test-Path $sitePath) {
        Write-Host "[ScaffoldJekyll] $sitePath already exists — skipping scaffold."
    } else {
        Write-Host "[ScaffoldJekyll] Running: jekyll new $sitePath --skip-bundle"
        Exec { jekyll new $sitePath --skip-bundle }
    }

    Write-Host "[ScaffoldJekyll] Copying sample content..."

    # Doc pages get layout: page
    $docMap = @{
        'docs/index.md' = 'index.md'
        'docs/getting-started.md' = 'getting-started.md'
        'docs/showcase.md' = 'showcase.md'
    }
    $pageFM = [ordered]@{ layout = 'page' }
    Copy-SampleContent -Destination $sitePath -FileMap $docMap -FrontMatterKeys $pageFM

    # Blog post gets layout: post and Jekyll date-prefix convention
    $blogMap = @{
        'blog/morning-coffee.md' = '_posts/2026-02-15-morning-coffee.md'
    }
    $postFM = [ordered]@{ layout = 'post' }
    Copy-SampleContent -Destination $sitePath -FileMap $blogMap -FrontMatterKeys $postFM

    # Images (no front-matter injection)
    $assetMap = @{
        'images' = 'images'
    }
    Copy-SampleContent -Destination $sitePath -FileMap $assetMap

    Write-Host "[ScaffoldJekyll] Done."
}

# ---------- MkDocs --------------------------------------------------------

Task ScaffoldMkDocs -Depends Init -Description 'Scaffold an MkDocs site and copy sample content' {
    $sitePath = Join-Path $script:DemoRoot 'mkdocs-demo'

    if (Test-Path $sitePath) {
        Write-Host "[ScaffoldMkDocs] $sitePath already exists — skipping scaffold."
    } else {
        Write-Host "[ScaffoldMkDocs] Running: mkdocs new $sitePath"
        Exec { mkdocs new $sitePath }
    }

    Write-Host "[ScaffoldMkDocs] Copying sample content..."

    $fileMap = @{
        'docs/index.md' = 'docs/index.md'
        'docs/getting-started.md' = 'docs/getting-started.md'
        'docs/showcase.md' = 'docs/showcase.md'
        'blog/morning-coffee.md' = 'docs/morning-coffee.md'
        'images' = 'docs/images'
    }
    Copy-SampleContent -Destination $sitePath -FileMap $fileMap

    # Update mkdocs.yml with navigation
    $mkdocsYml = Join-Path $sitePath 'mkdocs.yml'
    Write-Host "[ScaffoldMkDocs] Updating mkdocs.yml with nav section..."

    $yamlContent = @"
site_name: PowerShell Automation Hub
theme:
  name: material
nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - Showcase: showcase.md
  - Morning Coffee: morning-coffee.md
"@
    Set-Content -Path $mkdocsYml -Value $yamlContent
    Write-Host "[ScaffoldMkDocs] Done."
}

# ---------- Hugo ----------------------------------------------------------

Task ScaffoldHugo -Depends Init -Description 'Scaffold a Hugo site and copy sample content' {
    $sitePath = Join-Path $script:DemoRoot 'hugo-demo'

    if (Test-Path $sitePath) {
        Write-Host "[ScaffoldHugo] $sitePath already exists — skipping scaffold."
    } else {
        Write-Host "[ScaffoldHugo] Running: hugo new site $sitePath"
        Exec { hugo new site $sitePath }
    }

    # Install the hugo-book theme via git submodule
    $themePath = Join-Path $sitePath 'themes/hugo-book'
    if (-not (Test-Path $themePath)) {
        Write-Host "[ScaffoldHugo] Installing hugo-book theme via git submodule..."
        Exec {
            git -C $sitePath submodule add https://github.com/alex-shpak/hugo-book.git themes/hugo-book
        }
    } else {
        Write-Host "[ScaffoldHugo] Theme already installed."
    }

    Write-Host "[ScaffoldHugo] Copying sample content..."

    $fileMap = @{
        'docs/index.md' = 'content/_index.md'
        'docs/getting-started.md' = 'content/docs/getting-started.md'
        'docs/showcase.md' = 'content/docs/showcase.md'
        'blog/morning-coffee.md' = 'content/posts/morning-coffee.md'
        'images' = 'static/images'
    }
    Copy-SampleContent -Destination $sitePath -FileMap $fileMap

    # Update hugo.toml with theme setting
    $hugoToml = Join-Path $sitePath 'hugo.toml'
    Write-Host "[ScaffoldHugo] Updating hugo.toml..."

    $tomlContent = @"
baseURL = 'https://example.org/'
languageCode = 'en-us'
title = 'PowerShell Automation Hub'
theme = 'hugo-book'

[params]
  BookMenuBundle = '/menu'
  BookSection    = 'docs'
"@
    Set-Content -Path $hugoToml -Value $tomlContent
    Write-Host "[ScaffoldHugo] Done."
}

# ---------- Docusaurus ----------------------------------------------------

Task ScaffoldDocusaurus -Depends Init -Description 'Scaffold a Docusaurus site and copy sample content' {
    $sitePath = Join-Path $script:DemoRoot 'docusaurus-demo'

    if (Test-Path $sitePath) {
        Write-Host "[ScaffoldDocusaurus] $sitePath already exists — skipping scaffold."
    } else {
        Write-Host "[ScaffoldDocusaurus] Running: npx create-docusaurus@latest $sitePath classic"
        Exec { npx --yes create-docusaurus@latest $sitePath classic --skip-install }
    }

    Write-Host "[ScaffoldDocusaurus] Copying sample content..."

    $fileMap = @{
        'docs/index.md' = 'docs/intro.md'
        'docs/getting-started.md' = 'docs/getting-started.md'
        'docs/showcase.md' = 'docs/showcase.md'
        'blog/morning-coffee.md' = 'blog/2026-02-15-morning-coffee.md'
        'images' = 'static/img'
    }
    Copy-SampleContent -Destination $sitePath -FileMap $fileMap

    Write-Host "[ScaffoldDocusaurus] Done."
}

# ---------- Astro (Starlight) --------------------------------------------

Task ScaffoldAstro -Depends Init -Description 'Scaffold an Astro Starlight site and copy sample content' {
    $sitePath = Join-Path $script:DemoRoot 'astro-demo'

    if (Test-Path $sitePath) {
        Write-Host "[ScaffoldAstro] $sitePath already exists — skipping scaffold."
    } else {
        Write-Host "[ScaffoldAstro] Running: npm create astro@latest -- --template starlight"
        Exec {
            npm create astro@latest -- $sitePath --template starlight --no-install --no-git --yes
        }
    }

    Write-Host "[ScaffoldAstro] Copying sample content..."

    $fileMap = @{
        'docs/index.md' = 'src/content/docs/index.md'
        'docs/getting-started.md' = 'src/content/docs/getting-started.md'
        'docs/showcase.md' = 'src/content/docs/showcase.md'
        'blog/morning-coffee.md' = 'src/content/docs/blog/morning-coffee.md'
        'images' = 'public/images'
    }
    Copy-SampleContent -Destination $sitePath -FileMap $fileMap

    Write-Host "[ScaffoldAstro] Done."
}

# ---------- Meta-tasks ----------------------------------------------------

Task ScaffoldAll -Depends ScaffoldJekyll, ScaffoldMkDocs, ScaffoldHugo, ScaffoldDocusaurus, ScaffoldAstro `
    -Description 'Scaffold all five static site generators'

Task BuildContainers -Depends Init -Description 'Build Docker containers for offline demo backup' {
    $composePath = Join-Path $script:ContentRoot 'docker-compose.yml'

    if (-not (Test-Path $composePath)) {
        Write-Warning "[BuildContainers] docker-compose.yml not found at: $composePath"
        Write-Warning "[BuildContainers] Skipping container build. Create docker-compose.yml first."
        return
    }

    Write-Host "[BuildContainers] Running: docker compose build"
    Exec { docker compose -f $composePath build }
    Write-Host "[BuildContainers] Container build complete."
}
