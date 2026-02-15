---
title: Getting Started with PowerShell
date: 2026-02-15
weight: 1
sidebar_position: 1
tags:
  - powershell
  - beginner
---

# Getting Started with PowerShell

## Prerequisites

Before you begin, make sure you have the following:

- [ ] PowerShell 7.5 or later installed
- [ ] A code editor (VS Code recommended)
- [ ] A terminal you're comfortable with
- [x] A burning desire to automate things

## Installation

### Windows

PowerShell 7 is available via `choco`:

```powershell
choco install powershell-core
```

### macOS

```bash
brew install powershell/tap/powershell
```

### Linux

```bash
# Ubuntu / Debian
sudo apt-get install -y powershell
```

## Your First Script

Create a file called `hello.ps1`:

```powershell
# hello.ps1 - Your first PowerShell script
param(
    [string]$Name = 'World'
)

$greeting = "Hello, $Name!"
Write-Output $greeting

# Bonus: Get some system info
$info = [ordered]@{
    User      = $env:USERNAME ?? $env:USER
    OS        = $PSVersionTable.OS
    PSVersion = $PSVersionTable.PSVersion
    Date      = Get-Date -Format 'yyyy-MM-dd'
}

[PSCustomObject]$info | Format-List
```

> **Tip**: Use `pwsh` to launch PowerShell 7, not `powershell`
> (which launches Windows PowerShell 5.1).

## Common Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `Get-ChildItem` | `ls`, `dir` | List files and folders |
| `Set-Location` | `cd`, `sl` | Change directory |
| `Get-Content` | `cat`, `type` | Read file contents |
| `Select-Object` | `select` | Pick specific properties |
| `Where-Object` | `where`, `?` | Filter pipeline objects |

## Next Steps

Once you have PowerShell installed, check out the
[Markdown Feature Showcase](showcase.md) to see what your
static site generator can do.
