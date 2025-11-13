# Summit 2026 Marp Theme (AGENTS Guide)

This repository contains the **Summit 2026** custom Marp theme (`summit-2026.css`) for building consistent, branded slide decks (HTML, PDF, PPTX) for the PowerShell + DevOps Global Summit 2026.

## Quick Start

- Install the Marp for VS Code extension OR `npm i -g @marp-team/marp-cli`.
- Place `summit-2026.css` in your project root (already here).
- Add front‑matter to your Markdown deck:

```yaml
---
marp: true
theme: summit-2026
paginate: true
---
```

- (Optional) Add a title slide:

```markdown
<!-- _class: title -->
# PowerShell + DevOps <br/>Global Summit

## Building Better Scripts for the Future

<p class="name">Your Name</p>
<p class="handle">@your.handle</p>
```

- Export (examples below).

## Using in VS Code (Marp Extension)

Add this to your VS Code `settings.json` (User or Workspace):

```json
"marp.themes": [
  "./summit-2026.css"
]
```

Then open a Markdown file with the front‑matter shown above. Use the Marp preview ("Open Preview to the Side") and export via the command palette: `Marp: Export Slide Deck...` selecting HTML / PDF / PPTX.

## Using marp-cli (PowerShell examples)

From the repo root (ensure the CLI is installed globally):

```powershell
# HTML
marp .\sample-presentation.md --theme-set .\summit-2026.css --html --output .\sample-presentation.html

# PDF (needs Chromium; add --allow-local-files for images)
marp .\sample-presentation.md --theme-set .\summit-2026.css --pdf --allow-local-files --output .\sample-presentation.pdf

# PPTX
marp .\sample-presentation.md --theme-set .\summit-2026.css --pptx --allow-local-files --output .\sample-presentation.pptx
```

Key flags:

- `--theme-set` ensures the local theme is bundled.
- `--allow-local-files` lets Chromium access local images (e.g., `Background.jpg`).
- `--html`, `--pdf`, `--pptx` choose output format.

## Theme Features (CSS utilities)

Use the following classes and patterns to leverage built‑in styling:

| Feature | How to Use | Notes |
|---------|------------|-------|
| Title slide | `<!-- _class: title -->` | Centers heading; special name/handle styling |
| No background | `<!-- _class: no_background -->` | Removes hero background image |
| Pagination | `paginate: true` in front-matter | Shows `current / total` bottom-right |
| Callouts | `<div class="callout primary">...</div>` | Variants: primary, secondary, tertiary, quaternary, gradient |
| Brand colors | `<span class="primary">Text</span>` | Also `.secondary`, `.tertiary`, `.quaternary` |
| Color backgrounds | `<span class="primary-bg">` | Filled pill styles |
| Gradient text | `<span class="gradient-text">` | For emphasis headings |
| Lists w/ markers | Wrap list in `<div class="primary-list">` | Also `secondary-list`, `tertiary-list`, `quaternary-list` |
| Checklist | `<ul class="checklist">` | Renders ✔ markers |
| Name/handle sizes | `.wide`, `.compact`, `.auto-width` | Apply to `<p class="name wide">` etc. |
| Layout utilities | `.center`, `.right`, `.muted`, `.accent` | Text alignment + color helpers |
| Size utilities | `.small`, `.large`, `.xlarge` | Adjust font scale |

## Example: Callout

```html
<div class="callout gradient">
  <h3>✨ Tip</h3>
  Use gradient callouts for high‑impact highlights.
</div>
```

## Example: Enhanced Table

```markdown
| Feature | Class | Example |
|---------|-------|---------|
| Primary | .primary | <span class="primary">Cyan</span> |
| Secondary | .secondary | <span class="secondary">Blue</span> |
```

## Header / Footer Slots

Use Marp's `header:` and `footer:` directives in front‑matter or per-slide:

```yaml
---
marp: true
theme: summit-2026
header: PowerShell Summit 2026
footer: '@your.handle'
---
```

## Fonts

The theme imports Google Fonts (`Play`, `Space Grotesk`). If offline, those fall back to system fonts. For strict brand typography you can embed custom @font-face blocks (see commented section in CSS).

## Images & Background

The theme references `Background.jpg` for the default slide background. Provide your own file or remove/change that line in `summit-2026.css` if not desired. You can disable the background per slide with the `no_background` class.

## Accessibility & Readability Tips

- Keep text lines under ~90 characters (the base font-size is large; reduce with `.small` if needed).
- Use high‑contrast combinations; avoid putting small text over gradients.
- Prefer semantic Markdown (headings, lists) over raw HTML for easier maintenance.

## Common Gotchas

| Issue | Cause | Fix |
|-------|-------|-----|
| Theme not applied | Missing `theme: summit-2026` | Ensure front‑matter block is at very top |
| Local images missing in PDF | Chromium sandbox restriction | Add `--allow-local-files` flag |
| Fonts not loading | Offline environment | Package fonts locally via `@font-face` |
| Pagination missing | `paginate: true` omitted | Add to front‑matter |
| Callout styling broken in PDF | Cached old CSS | Re-run export with `--theme-set` |

## Automating Exports

Example PowerShell script snippet to export all decks:

```powershell
Get-ChildItem -Filter *.md | ForEach-Object {
  marp $_.FullName --theme-set .\summit-2026.css --allow-local-files --pptx --output ("$($_.BaseName).pptx")
}
```

Modify output flags (`--pdf`, `--html`) as needed.

## Contributing Improvements

Open a PR adjusting `summit-2026.css` and include before/after screenshots (HTML export) plus a rationale (accessibility, consistency, performance). Keep selectors additive; avoid breaking existing class names to prevent slide drift.

## License / Usage

Assumed internal Summit usage. If publishing externally, retain attribution or mention the PowerShell + DevOps Global Summit branding where appropriate.

---
Made with ❤️ for Summit presenters. Questions? Open an issue or add a note to this file.

## References

Official Marp / Marpit theme authoring guide: [marpit.marp.app/theme-css](https://marpit.marp.app/theme-css)

Use it for deeper customization (advanced selectors, scoped theming, @import nuances, pagination variables) beyond what this quick guide covers.
