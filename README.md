# Summit 2026 Marp Theme

A custom Marp theme for building consistent, branded slide decks for the PowerShell + DevOps Global Summit 2026. This repo ships the theme stylesheet `summit-2026.css` plus example decks like `sample-presentation.md`.

- Theme file: `./summit-2026.css`
- Samples: `./sample-presentation.md` (+ HTML export), `./Burnout/Burnout.md`, `./MarkdownMadness/MarkdownMadness.md`
- Full usage guide: see `AGENTS.md`

## Quick Start

- Install the Marp for VS Code extension OR the CLI: `npm i -g @marp-team/marp-cli`.
- Add this front‑matter at the very top of your deck:

```yaml
---
marp: true
theme: summit-2026
paginate: true
---
```

- If using VS Code, point Marp at the local theme (User or Workspace `settings.json`):

```json
"marp.themes": [
  "./summit-2026.css"
]
```

## Use in VS Code

1) Open your `.md` deck with the front‑matter above.
2) Use "Open Preview to the Side" to see slides.
3) Export via the Command Palette: "Marp: Export Slide Deck…" and choose HTML / PDF / PPTX.

## Use the CLI (PowerShell)

From the repo root:

```powershell
# HTML
marp .\sample-presentation.md --theme-set .\summit-2026.css --html --output .\sample-presentation.html

# PDF (needs Chromium; add --allow-local-files for images like Background.jpg)
marp .\sample-presentation.md --theme-set .\summit-2026.css --pdf --allow-local-files --output .\sample-presentation.pdf

# PPTX
marp .\sample-presentation.md --theme-set .\summit-2026.css --pptx --allow-local-files --output .\sample-presentation.pptx
```

Key flags:

- `--theme-set` bundles the local CSS theme.
- `--allow-local-files` lets Chromium access local assets during PDF/PPTX export.

## Features at a Glance

- Title slide layout: `<!-- _class: title -->` with styled `.name` and `.handle`
- Toggle background per slide: `<!-- _class: no_background -->`
- Brand utilities: `.primary`, `.secondary`, `.tertiary`, `.quaternary` and `*-bg` fills
- Callouts: `<div class="callout primary|secondary|tertiary|quaternary|gradient">`
- Gradient text: `<span class="gradient-text">`
- Lists with brand markers: wrap in `.primary-list` / `.secondary-list` / `.tertiary-list` / `.quaternary-list`
- Checklist bullets: `<ul class="checklist">`
- Enhanced tables and pagination (`paginate: true`)
- Header/footer via front‑matter `header:` and `footer:`

See `AGENTS.md` for examples and screenshots you can copy/paste.

## Automate Exports (PowerShell)

Export all decks in the folder to PPTX:

```powershell
Get-ChildItem -Filter *.md | ForEach-Object {
  marp $_.FullName --theme-set .\summit-2026.css --allow-local-files --pptx --output ("$($_.BaseName).pptx")
}
```

Modify output flags to export HTML or PDF instead.

## Build Automation (build.ps1)

This repository includes a **`build.ps1`** script powered by [psake](https://github.com/psake/psake) that automates exporting all your presentation decks. It discovers all `.md` files with `marp: true` in their front-matter and exports them to HTML, PDF, and PPTX formats in the `dist/` folder.

### Prerequisites

Install the Marp CLI globally:

```powershell
npm i -g @marp-team/marp-cli
```

### First-Time Setup

Bootstrap build dependencies (psake and PSDepend):

```powershell
.\build.ps1 -Bootstrap
```

### List Available Tasks

View all available build tasks:

```powershell
.\build.ps1 -Help
```

Available tasks include:
- **default** / **ExportAll** - Export all decks to HTML, PDF, and PPTX
- **ExportHtml** - Export all decks to HTML only
- **ExportPdf** - Export all decks to PDF only
- **ExportPptx** - Export all decks to PPTX only
- **CopyTheme** - Copy theme CSS and background assets to `dist/`
- **Clean** - Remove the `dist/` directory

### Common Usage

Run the default task (exports everything):

```powershell
.\build.ps1
```

Export to a specific format:

```powershell
# HTML only
.\build.ps1 -Task ExportHtml

# PDF only
.\build.ps1 -Task ExportPdf

# PPTX only
.\build.ps1 -Task ExportPptx
```

Clean and rebuild everything:

```powershell
.\build.ps1 -Task Clean, ExportAll
```

### How It Works

1. **Discovery**: Scans for all `*.md` files with `marp: true` in their YAML front-matter
2. **Asset Handling**: Automatically copies referenced images and `Background.jpg` to the output folder
3. **Export**: Runs `marp` CLI with the correct flags (`--theme-set`, `--allow-local-files`, etc.)
4. **Output**: Places all exports in the `dist/` folder, preserving subfolder structure

All decks are exported using the `summit-2026.css` theme automatically.

## Customize

Edit `summit-2026.css` to change fonts, colors, or layout. The CSS includes:

- CSS custom properties (`:root`) for brand colors and typography
- Title slide styles and utility classes
- Header/footer and pagination controls

Deep dive and additional tips: see `AGENTS.md`.

## Contributing

PRs welcome! When changing `summit-2026.css`, please include before/after screenshots (HTML export) and a short rationale (accessibility, consistency, performance). Avoid breaking existing class names.

## License / Usage

Intended for internal Summit use. If publishing externally, retain attribution or reference the PowerShell + DevOps Global Summit branding where appropriate.

## References

- Full theme guide in this repo: [`AGENTS.md`](./AGENTS.md)
- Official Marp / Marpit theme authoring guide: [marpit.marp.app/theme-css](https://marpit.marp.app/theme-css)
