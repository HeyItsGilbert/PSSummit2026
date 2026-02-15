# Exit the script immediately in case of accidental run
return

# ============================================================================
# Markdown Madness - PS Summit 2026
# Presenter: Gilbert Sanchez
#
# This demo script walks through five static site generators, each building
# the same set of markdown files into a live site. Run sections with F8 in
# VS Code or by selecting lines and pressing F8.
#
# Prerequisites:
#   Ruby + Bundler (Jekyll)
#   Python + pip   (MkDocs)
#   Go / Hugo CLI  (Hugo)
#   Node.js + npm  (Docusaurus, Astro)
# ============================================================================

# ---------------------------------------------------------------------------
# Setup - paths and common variables
# ---------------------------------------------------------------------------

# Where we'll scaffold all our demo sites
$demoRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'MarkdownMadness'

# Source content lives next to this script
$contentRoot = $PSScriptRoot
$docsSource  = Join-Path $contentRoot 'docs'
$blogSource  = Join-Path $contentRoot 'blog'
$imageSource = Join-Path $contentRoot 'images'

# Today's date for Jekyll blog post naming convention
$today = Get-Date -Format 'yyyy-MM-dd'

# Create the demo root if it doesn't exist
if (-not (Test-Path $demoRoot)) {
    New-Item -Path $demoRoot -ItemType Directory | Out-Null
}

Write-Host "Demo root: $demoRoot" -ForegroundColor Cyan
Write-Host "Content:   $contentRoot" -ForegroundColor Cyan

# First let's look at the markdown content we'll be feeding to each generator
Get-ChildItem -Path $docsSource, $blogSource -Recurse -Filter '*.md' |
    Select-Object FullName, Length

# Open the showcase file to see what features we're testing
code (Join-Path $docsSource 'showcase.md')


#region Jekyll
# ============================================================================
# Jekyll (Ruby)
# "The OG of static site generators. GitHub Pages runs on this."
# ============================================================================

$jekyllDir = Join-Path $demoRoot 'jekyll-demo'

# Scaffold a new Jekyll site (--skip-bundle so we can inspect before install)
jekyll new $jekyllDir --skip-bundle

# Let's look at what Jekyll created
Get-ChildItem -Path $jekyllDir

# Copy our doc pages into the Jekyll site root (Jekyll serves root .md as pages)
Copy-Item -Path (Join-Path $docsSource 'index.md')           -Destination $jekyllDir -Force
Copy-Item -Path (Join-Path $docsSource 'getting-started.md') -Destination $jekyllDir -Force
Copy-Item -Path (Join-Path $docsSource 'showcase.md')        -Destination $jekyllDir -Force

# Copy images
$jekyllImages = Join-Path $jekyllDir 'images'
New-Item -Path $jekyllImages -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $imageSource 'ps_black_128.svg') -Destination $jekyllImages -Force

# Copy the blog post into _posts with the required date-prefixed filename
# Jekyll requires: YYYY-MM-DD-title.md
$jekyllPosts = Join-Path $jekyllDir '_posts'
if (-not (Test-Path $jekyllPosts)) {
    New-Item -Path $jekyllPosts -ItemType Directory -Force | Out-Null
}

$blogContent = Get-Content -Path (Join-Path $blogSource 'morning-coffee.md') -Raw
# Add layout: post to the front matter so Jekyll renders it correctly
$blogContent = $blogContent -replace '(---\r?\n)', "`$1layout: post`n"
$blogContent | Set-Content -Path (Join-Path $jekyllPosts "$today-morning-coffee.md") -Force

# Let's see what the blog post looks like now
Get-Content -Path (Join-Path $jekyllPosts "$today-morning-coffee.md") | Select-Object -First 20

# Install gems and serve
Push-Location $jekyllDir
bundle install
bundle exec jekyll serve

# >>> Open http://localhost:4000
# >>> Check the homepage, then navigate to /showcase and /getting-started
# >>> Look at the blog post - note the date-based URL
# >>> Show the mermaid diagram and math - Jekyll doesn't support these by
#     default without plugins!
# >>> Ctrl+C to stop the server when done

Pop-Location

#endregion


#region MkDocs
# ============================================================================
# MkDocs (Python)
# "The Python community's favorite. MkDocs Material is gorgeous."
# ============================================================================

$mkdocsDir = Join-Path $demoRoot 'mkdocs-demo'

# Scaffold a new MkDocs site
mkdocs new $mkdocsDir

# Let's see the structure
Get-ChildItem -Path $mkdocsDir -Recurse

# MkDocs keeps everything under docs/ - copy our content there
$mkdocsDocs = Join-Path $mkdocsDir 'docs'

Copy-Item -Path (Join-Path $docsSource 'index.md')           -Destination $mkdocsDocs -Force
Copy-Item -Path (Join-Path $docsSource 'getting-started.md') -Destination $mkdocsDocs -Force
Copy-Item -Path (Join-Path $docsSource 'showcase.md')        -Destination $mkdocsDocs -Force
Copy-Item -Path (Join-Path $blogSource 'morning-coffee.md')  -Destination $mkdocsDocs -Force

# Copy images
$mkdocsImages = Join-Path $mkdocsDocs 'images'
New-Item -Path $mkdocsImages -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $imageSource 'ps_black_128.svg') -Destination $mkdocsImages -Force

# Update mkdocs.yml with a navigation structure
$mkdocsYml = Join-Path $mkdocsDir 'mkdocs.yml'
@"
site_name: PowerShell Automation Hub
nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - Showcase: showcase.md
  - Blog - Morning Coffee: morning-coffee.md
"@ | Set-Content -Path $mkdocsYml -Force

# Show the config
Get-Content -Path $mkdocsYml

# Serve the site
Push-Location $mkdocsDir
mkdocs serve

# >>> Open http://localhost:8000
# >>> Notice the clean nav sidebar auto-generated from mkdocs.yml
# >>> MkDocs renders tables and code blocks nicely out of the box
# >>> Mermaid and math need plugins (mkdocs-mermaid2-plugin, pymdown-extensions)
# >>> Ctrl+C to stop the server when done

Pop-Location

#endregion


#region Hugo
# ============================================================================
# Hugo (Go)
# "The fastest static site generator. Written in Go, blazingly quick."
# ============================================================================

$hugoDir = Join-Path $demoRoot 'hugo-demo'

# Scaffold a new Hugo site
hugo new site $hugoDir

# Hugo REQUIRES a theme - let's add one
# Using hugo-book, a clean documentation theme
Push-Location $hugoDir
git init
git submodule add https://github.com/alex-shpak/hugo-book.git themes/hugo-book
Pop-Location

# Update hugo.toml to use the theme
$hugoConfig = Join-Path $hugoDir 'hugo.toml'
@"
baseURL = 'http://localhost:1313/'
languageCode = 'en-us'
title = 'PowerShell Automation Hub'
theme = 'hugo-book'

[params]
  BookMenuBundle = '/menu'
  BookSection    = 'docs'

[markup]
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = true
  [markup.highlight]
    style = 'monokai'
"@ | Set-Content -Path $hugoConfig -Force

# Hugo content goes in content/ with subdirectories
$hugoContent = Join-Path $hugoDir 'content'
$hugoDocs    = Join-Path $hugoContent 'docs'
$hugoBlog    = Join-Path $hugoContent 'posts'

New-Item -Path $hugoDocs -ItemType Directory -Force | Out-Null
New-Item -Path $hugoBlog -ItemType Directory -Force | Out-Null

# Copy doc pages into content/docs/
Copy-Item -Path (Join-Path $docsSource 'getting-started.md') -Destination $hugoDocs -Force
Copy-Item -Path (Join-Path $docsSource 'showcase.md')        -Destination $hugoDocs -Force

# Hugo uses content/_index.md for section homepages
Copy-Item -Path (Join-Path $docsSource 'index.md') -Destination (Join-Path $hugoContent '_index.md') -Force

# Copy blog post
Copy-Item -Path (Join-Path $blogSource 'morning-coffee.md') -Destination $hugoBlog -Force

# Copy images into static/images (Hugo serves static/ at the root)
$hugoImages = Join-Path $hugoDir 'static' 'images'
New-Item -Path $hugoImages -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $imageSource 'ps_black_128.svg') -Destination $hugoImages -Force

# Let's see the full structure
Get-ChildItem -Path $hugoDir -Recurse -Depth 3 | Select-Object FullName

# Serve the site
Push-Location $hugoDir
hugo server

# >>> Open http://localhost:1313
# >>> Hugo is FAST - watch the build time in the terminal (usually < 100ms)
# >>> Navigate to /docs/showcase/ to see feature rendering
# >>> Hugo-book theme gives a clean docs layout
# >>> Ctrl+C to stop the server when done

Pop-Location

#endregion


#region Docusaurus
# ============================================================================
# Docusaurus (React / Node)
# "Built by Meta. The gold standard for open-source project docs."
# ============================================================================

$docusaurusDir = Join-Path $demoRoot 'docusaurus-demo'

# Scaffold a new Docusaurus site with the classic preset
npx create-docusaurus@latest $docusaurusDir classic

# Docusaurus already has docs/ and blog/ directories in its scaffold
Get-ChildItem -Path $docusaurusDir

# Copy our doc pages into docs/ (overwrite the generated samples)
$docusaurusDocs = Join-Path $docusaurusDir 'docs'
$docusaurusBlog = Join-Path $docusaurusDir 'blog'

Copy-Item -Path (Join-Path $docsSource 'getting-started.md') -Destination $docusaurusDocs -Force
Copy-Item -Path (Join-Path $docsSource 'showcase.md')        -Destination $docusaurusDocs -Force

# Docusaurus uses docs/intro.md or similar for the docs landing page
# Copy index.md as intro.md to match the default sidebar
Copy-Item -Path (Join-Path $docsSource 'index.md') -Destination (Join-Path $docusaurusDocs 'intro.md') -Force

# Copy blog post - Docusaurus supports date in front matter, no filename prefix needed
# But a date prefix in the filename works too for ordering
Copy-Item -Path (Join-Path $blogSource 'morning-coffee.md') `
    -Destination (Join-Path $docusaurusBlog "$today-morning-coffee.md") -Force

# Copy images into static/img/
$docusaurusImages = Join-Path $docusaurusDir 'static' 'img'
New-Item -Path $docusaurusImages -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $imageSource 'ps_black_128.svg') -Destination $docusaurusImages -Force

# Install dependencies and serve
Push-Location $docusaurusDir
npm install
npm start

# >>> Open http://localhost:3000
# >>> Docusaurus has the most polished out-of-box experience
# >>> Check /docs/showcase - Docusaurus supports mermaid via a plugin
# >>> The blog at /blog has nice author cards and tag pages
# >>> Notice the search bar, dark mode toggle, and versioning support
# >>> Ctrl+C to stop the server when done

Pop-Location

#endregion


#region Astro
# ============================================================================
# Astro (Node)
# "The new kid. Starlight template is purpose-built for documentation."
# ============================================================================

$astroDir = Join-Path $demoRoot 'astro-demo'

# Scaffold a new Astro site with the Starlight docs template
npm create astro@latest $astroDir -- --template starlight

# Starlight puts docs in src/content/docs/
Get-ChildItem -Path $astroDir -Recurse -Depth 3 | Where-Object { $_.Extension -eq '.md' -or $_.Extension -eq '.mdx' }

# Copy our content into Starlight's expected structure
$astroDocs = Join-Path $astroDir 'src' 'content' 'docs'
New-Item -Path $astroDocs -ItemType Directory -Force | Out-Null

Copy-Item -Path (Join-Path $docsSource 'index.md')           -Destination $astroDocs -Force
Copy-Item -Path (Join-Path $docsSource 'getting-started.md') -Destination $astroDocs -Force
Copy-Item -Path (Join-Path $docsSource 'showcase.md')        -Destination $astroDocs -Force
Copy-Item -Path (Join-Path $blogSource 'morning-coffee.md')  -Destination $astroDocs -Force

# Copy images into public/images/ (Astro serves public/ at the root)
$astroImages = Join-Path $astroDir 'public' 'images'
New-Item -Path $astroImages -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $imageSource 'ps_black_128.svg') -Destination $astroImages -Force

# Install dependencies and serve
Push-Location $astroDir
npm install
npm run dev

# >>> Open http://localhost:4321
# >>> Starlight is built for docs - notice the sidebar, search, and i18n support
# >>> Check /showcase/ - Starlight has first-class support for many features
# >>> The design is clean and modern out of the box
# >>> Ctrl+C to stop the server when done

Pop-Location

#endregion


#region Cleanup
# ============================================================================
# Cleanup
# "Always clean up after your demos. Future-you will thank present-you."
# ============================================================================

# Show what we created
Get-ChildItem -Path $demoRoot -Directory | Select-Object Name, LastWriteTime

# Remove all demo sites
Remove-Item -Path $demoRoot -Recurse -Force -Confirm

Write-Host 'Demo sites cleaned up!' -ForegroundColor Green

#endregion
