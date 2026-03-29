---
layout: post
title: "Automating Your Morning Coffee"
date: 2026-02-15
author: Gilbert Sanchez
description: >-
  How I used PowerShell to automate my morning routine,
  one cmdlet at a time.
tags:
  - automation
  - powershell
  - lifestyle
draft: false
---

# Automating Your Morning Coffee

Every morning, I ~~manually checked~~ *used to* manually check a dozen things
before starting work. Now PowerShell does it for me.

## The Problem

My morning routine looked like this:

1. Check if VPN is connected
2. Open the right browser tabs
3. Check the build pipeline status
4. Review overnight alerts
5. ***Realize I forgot to start the coffee maker***

## The Solution

```powershell
function Start-MorningRoutine {
    [CmdletBinding()]
    param(
        [switch]$IncludeCoffee
    )

    # Check VPN status
    $vpn = Get-NetAdapter | Where-Object {
        $_.InterfaceDescription -like '*VPN*'
    }
    if (-not $vpn) {
        Write-Warning "VPN is not connected!"
    }

    # Open daily tabs
    $tabs = @(
        'https://github.com/notifications'
        'https://dev.azure.com'
    )
    $tabs | ForEach-Object { Start-Process $_ }

    if ($IncludeCoffee) {
        # TODO: IoT integration left as exercise
        Write-Output "☕ Go make coffee, human."
    }
}

Start-MorningRoutine -IncludeCoffee
```

## Lessons Learned

> Automation doesn't have to be serious.
> Sometimes the best scripts are the ones that make you smile.
>
> > "Any sufficiently advanced PowerShell script is
> > indistinguishable from magic."

The key takeaway [^1] is that PowerShell isn't just for sysadmin tasks. It's a
*lifestyle* tool.

---

## What's Next?

I'm working on automating my ~~entire life~~ afternoon routine too. Stay tuned
for part two.

[^1]: Also the actual coffee. Don't forget the coffee.
