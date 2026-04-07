---
marp: true
theme: summit-2026
paginate: true
---

<!-- _class: title -->
# PowerShell + Devops <br/>Global Summit

## Building Better Scripts for the Future

<p class="name">Alexandra Johnson</p>
<p class="handle">@alex.powershell</p>

---
<!-- _class: title -->
# <span class="gradient-text">PowerShell</span> Automation Excellence

## Building Better Scripts for the Future

<p class="name">Alexandra Johnson</p>
<p class="handle">@alex.powershell</p>

---

<!-- _class: sponsors -->
<!-- _paginate: skip -->

# Thanks!

<!--
Gotta thank the sponsors!
-->

---

<!-- _class: title -->
# Brand Color <span class="primary">Showcase</span>

## <span class="secondary">All Official</span> <span class="tertiary">PowerShell</span> <span class="quaternary">Colors</span>

<p class="name wide">Christopher Alexander Richardson-Smith</p>
<p class="handle wide">@christopher.richardson.powershell.expert</p>

---

# Brand Color Utilities

You can use all official PowerShell Summit colors:

- <span class="primary">Primary cyan</span> for main highlights
- <span class="secondary">Secondary blue</span> for supporting content
- <span class="tertiary">Tertiary navy</span> for professional accents
- <span class="quaternary">Quaternary purple</span> for special emphasis

---

# Brand Color Utilities Backgrounds

<span class="primary-bg">Primary background</span>

<span class="secondary-bg">Secondary background</span>

<span class="tertiary-bg">Tertiary background</span>

<span class="quaternary-bg">Quaternary background</span>

---

# Enhanced Lists with Brand Colors

<div class="primary-list">

## Primary Cyan Lists

- PowerShell automation best practices
- Script optimization techniques
- Error handling strategies

</div>

---

# Enhanced Lists with Brand Colors

<div class="quaternary-list">

## Purple Numbered Lists

1. Plan your automation strategy
2. Design robust error handling
3. Test thoroughly before deployment
4. Document everything clearly

</div>

---

# Callout Variations

<div class="callout primary">

### 💡 Primary Tip

Use the **primary callout** for main tips and important information that should stand out prominently.

</div>

<div class="callout secondary">

### ℹ️ Secondary Info

The **secondary callout** works great for supporting information and additional context.

</div>

---

# More Callout Colors

<div class="callout tertiary">

### 🚨 Tertiary Warning

**Navy callouts** are perfect for warnings, cautions, or professional notices that need attention.

</div>

<div class="callout quaternary">

### ⭐ Quaternary Special

**Purple callouts** are ideal for special notes, pro tips, or highlighting unique features.

</div>

---

# Gradient Effects

<div class="callout gradient">

### 🌟 Gradient Callout

This **gradient callout** combines multiple brand colors for maximum visual impact and professional appearance.

</div>

## <span class="gradient-text">Gradient Text Effects</span>

Use gradient text for <span class="gradient-text">special emphasis</span> and <span class="gradient-text">brand consistency</span> throughout your presentations.

---

# Enhanced Tables

| Feature | Primary Use | Color Class | Example |
|---------|-------------|-------------|---------|
| Primary | Main highlights | `.primary` | <span class="primary">Cyan text</span> |
| Secondary | Supporting content | `.secondary` | <span class="secondary">Blue text</span> |
| Tertiary | Professional accents | `.tertiary` | <span class="tertiary">Navy text</span> |
| Quaternary | Special emphasis | `.quaternary` | <span class="quaternary">Purple text</span> |

*Table headers use the secondary brand color with white text*

---

# Code Examples with Styling

Here's PowerShell code with the enhanced styling:

```powershell
# Get all running processes and sort by CPU usage
$processes = Get-Process | 
    Where-Object { $_.CPU -gt 0 } |
    Sort-Object CPU -Descending |
    Select-Object Name, CPU, @{n='WorkingSetMB';e={$_.WorkingSet/1MB}}

# Display results with formatting
$processes | Format-Table -AutoSize
```

The <span class="tertiary">**Space Grotesk**</span> font makes code very readable with the gradient background!

---

# Enhanced Blockquotes

> **PowerShell Best Practice**: Always use proper error handling in your automation scripts. The `try-catch-finally` pattern ensures robust script execution.

> **Performance Tip**: Use `Where-Object` filtering early in your pipeline to reduce the amount of data processed in subsequent commands.

> **Security Note**: Never hardcode credentials in scripts. Use secure methods like `Get-Credential` or Azure Key Vault integration.

---

# Visual Hierarchy Example

# <span class="gradient-text">Main Heading</span>

## <span class="primary">Section Heading</span>

### <span class="secondary">Subsection</span>

**Bold text** uses <span class="quaternary">quaternary purple</span> for emphasis.

*Italic text* uses <span class="primary">primary cyan</span> for highlights.

<div class="small muted">Small muted text for footnotes and references</div>

<div class="large tertiary">Large tertiary text for important statements</div>

---

# List Style Variations

<div class="secondary-list">

## Secondary Blue Lists

- Project planning essentials
- Code review guidelines  
- Deployment strategies

</div>

<div class="tertiary-list">

## Tertiary Navy Lists

- Security considerations
- Performance optimization
- Best practice guidelines

</div>

---

# Mixed Content Showcase

## <span class="primary">Performance</span> <span class="secondary">Monitoring</span> <span class="tertiary">Script</span>

<div class="callout primary">

### 🚀 Performance Tip

Always measure before optimizing. Use `Measure-Command` to baseline your scripts.

</div>

```powershell
# Measure script execution time
$executionTime = Measure-Command {
    Get-Service | Where-Object Status -eq "Running" | 
    Sort-Object Name | Export-Csv -Path "services.csv"
}
Write-Host "Execution time: $($executionTime.TotalSeconds) seconds" -ForegroundColor Green
```

---

<div class="quaternary-list">

1. **Baseline** your current performance
2. **Identify** bottlenecks and inefficiencies  
3. **Optimize** critical code paths
4. **Measure** improvements and validate gains

</div>

---

<!-- _class: title -->
# <span class="gradient-text">THANK YOU</span>

## <span class="primary">Feedback</span> is a <span class="quaternary">gift</span>

<p class="name">Please review this session via the mobile app</p>
<p class="handle">Questions? Find me @alex.powershell</p>

---

<!-- _class: no_background -->

# No Background

You can set up slides without the background.

---

# Appendix: All Brand Features

This presentation demonstrated:

<div class="callout gradient">

### ✨ Complete Feature Set

1. **Title slides** with flexible name/handle sizing
2. **Brand color utilities** for all official colors
3. **Enhanced callouts** in all brand color variations
4. **Gradient text effects** for visual impact
5. **Enhanced tables** with brand color headers

</div>

---

# Appendix: All Brand Features

This presentation demonstrated:

<div class="callout gradient">

### ✨ Complete Feature Set Cont

1. **Styled lists** with colored markers
2. **Professional blockquotes** with brand styling
3. **Code highlighting** with gradient backgrounds
4. **Typography hierarchy** using brand colors

</div>

<div class="small muted center">
Created with the Summit 2026 Marp theme • <span class="primary">PowerShell Summit 2026</span>
</div>
