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
# Flow:
#   1. Use psake tasks (./build.ps1) to scaffold each site and copy content
#   2. Use Docker containers to serve the scaffolded sites (volume mounts)
#
# Prerequisites:
#   Docker Desktop (or Docker Engine + Compose plugin)
# ============================================================================

# ---------------------------------------------------------------------------
# Setup - paths and common variables
# ---------------------------------------------------------------------------

# Source content lives next to this script
$contentRoot = $PSScriptRoot
$docsSource  = Join-Path $contentRoot 'docs'
$blogSource  = Join-Path $contentRoot 'blog'
$sitesRoot   = Join-Path $contentRoot 'sites'

Write-Host "Content root: $contentRoot" -ForegroundColor Cyan


#region Sample Content
# ============================================================================
# First, let's look at the markdown we'll feed to every generator.
# Same files, five different outputs!
# ============================================================================

# What markdown files do we have?
Get-ChildItem -Path $docsSource, $blogSource -Recurse -Filter '*.md' |
    Select-Object FullName, Length

# Open the showcase file to see what features we're testing
code (Join-Path $docsSource 'showcase.md')

# >>> Walk through the front matter - notice the superset of keys
# >>> (weight for Hugo, sidebar_position for Docusaurus)
# >>> Show mermaid diagram, math, footnotes, tables, task lists
# >>> Point out: generators ignore keys they don't understand

#endregion


#region Build Tasks
# ============================================================================
# Let's look at how psake automates the scaffolding.
# Each task scaffolds a generator and copies our markdown into it.
# ============================================================================

# Show available build tasks
./build.ps1 -Help

# >>> Walk through the task list
# >>> Each ScaffoldXxx task creates a site and copies our sample content
# >>> The Copy-SampleContent helper injects front matter when needed

#endregion


#region Jekyll
# ============================================================================
# Jekyll (Ruby)
# "The OG of static site generators. GitHub Pages runs on this."
# ============================================================================

# Scaffold the Jekyll site with our psake task
./build.ps1 ScaffoldJekyll

# Let's see what was created
Get-ChildItem -Path (Join-Path $sitesRoot 'jekyll-demo')

# Notice the _posts/ directory with the date-prefixed blog post
Get-ChildItem -Path (Join-Path $sitesRoot 'jekyll-demo' '_posts')

# Check the injected front matter - layout: post was added
Get-Content -Path (Join-Path $sitesRoot 'jekyll-demo' '_posts' '2026-02-15-morning-coffee.md') |
    Select-Object -First 15

# Now serve it with Docker (the container just mounts our scaffolded site)
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') up -d jekyll

# >>> Open http://localhost:4000
# >>> Check the homepage, then navigate to /showcase and /getting-started
# >>> Look at the blog post - note the date-based URL
# >>> Mermaid and math don't render - Jekyll needs plugins for those!

# Stop Jekyll when done
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') stop jekyll

#endregion


#region MkDocs
# ============================================================================
# MkDocs (Python)
# "The Python community's favorite. MkDocs Material is gorgeous."
# ============================================================================

# Scaffold the MkDocs site
./build.ps1 ScaffoldMkDocs

# Let's see the structure - everything under docs/
Get-ChildItem -Path (Join-Path $sitesRoot 'mkdocs-demo') -Recurse

# Check the mkdocs.yml our psake task generated
Get-Content -Path (Join-Path $sitesRoot 'mkdocs-demo' 'mkdocs.yml')

# Serve with Docker
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') up -d mkdocs

# >>> Open http://localhost:4001
# >>> Notice the Material theme - clean nav sidebar from mkdocs.yml
# >>> Tables and code blocks render nicely out of the box
# >>> Mermaid diagrams work thanks to pymdownx.superfences
# >>> Compare the same showcase.md to Jekyll - big difference!

docker compose -f (Join-Path $contentRoot 'docker-compose.yml') stop mkdocs

#endregion


#region Hugo
# ============================================================================
# Hugo (Go)
# "The fastest static site generator. Written in Go, blazingly quick."
# ============================================================================

# Scaffold the Hugo site (includes theme via git submodule)
./build.ps1 ScaffoldHugo

# Hugo has a specific content structure
Get-ChildItem -Path (Join-Path $sitesRoot 'hugo-demo') -Recurse -Depth 3 |
    Select-Object FullName

# Check the hugo.toml config
Get-Content -Path (Join-Path $sitesRoot 'hugo-demo' 'hugo.toml')

# Serve with Docker
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') up -d hugo

# >>> Open http://localhost:4002
# >>> Hugo is FAST - check the build time in the container logs
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') logs hugo --tail 5

# >>> Navigate to /docs/showcase/ to see feature rendering
# >>> Hugo-book theme gives a clean docs layout

docker compose -f (Join-Path $contentRoot 'docker-compose.yml') stop hugo

#endregion


#region Docusaurus
# ============================================================================
# Docusaurus (React / Node)
# "Built by Meta. The gold standard for open-source project docs."
# ============================================================================

# Scaffold the Docusaurus site
./build.ps1 ScaffoldDocusaurus

# Docusaurus has docs/ and blog/ directories
Get-ChildItem -Path (Join-Path $sitesRoot 'docusaurus-demo')

# Our index.md became intro.md (Docusaurus convention)
Get-ChildItem -Path (Join-Path $sitesRoot 'docusaurus-demo' 'docs')

# Serve with Docker (npm install happens inside the container)
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') up -d docusaurus

# >>> Open http://localhost:4003
# >>> Docusaurus has the most polished out-of-box experience
# >>> Check /docs/showcase - notice the sidebar and breadcrumbs
# >>> The blog at /blog has author cards and tag pages
# >>> Dark mode toggle and search bar come for free!

docker compose -f (Join-Path $contentRoot 'docker-compose.yml') stop docusaurus

#endregion


#region Astro
# ============================================================================
# Astro (Node)
# "The new kid. Starlight template is purpose-built for documentation."
# ============================================================================

# Scaffold the Astro Starlight site
./build.ps1 ScaffoldAstro

# Starlight puts docs in src/content/docs/
Get-ChildItem -Path (Join-Path $sitesRoot 'astro-demo' 'src' 'content' 'docs')

# Serve with Docker (npm install happens inside the container)
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') up -d astro

# >>> Open http://localhost:4004
# >>> Starlight is built for docs - sidebar, search, i18n support
# >>> Check /showcase/ - Starlight has first-class feature support
# >>> Clean, modern design out of the box

docker compose -f (Join-Path $contentRoot 'docker-compose.yml') stop astro

#endregion


#region All At Once
# ============================================================================
# Run all five side by side!
# "Same markdown, five different sites."
# ============================================================================

# Scaffold everything at once
./build.ps1 ScaffoldAll

# Start all containers
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') up -d

# Check the status
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') ps

# >>> Open all five in browser tabs:
# >>>   http://localhost:4000  (Jekyll)
# >>>   http://localhost:4001  (MkDocs)
# >>>   http://localhost:4002  (Hugo)
# >>>   http://localhost:4003  (Docusaurus)
# >>>   http://localhost:4004  (Astro)

# Open all five at once
'http://localhost:4000',
'http://localhost:4001',
'http://localhost:4002',
'http://localhost:4003',
'http://localhost:4004' | ForEach-Object { Start-Process $_ }

#endregion


#region Cleanup
# ============================================================================
# Cleanup
# "Always clean up after your demos. Future-you will thank present-you."
# ============================================================================

# Stop and remove all containers
docker compose -f (Join-Path $contentRoot 'docker-compose.yml') down

# Remove the scaffolded sites
./build.ps1 Clean

Write-Host 'All containers stopped and sites cleaned up!' -ForegroundColor Green

#endregion
