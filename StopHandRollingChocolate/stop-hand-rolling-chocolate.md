---
marp: true
theme: summit-2026
paginate: false
title: Stop Hand-Rolling Chocolate
author: Gilbert Sanchez
---

<!-- _class: title -->
# Stop Hand-Rolling Chocolate

## Automating Chocolatey with psake

<p class="name">Gilbert Sanchez</p>
<p class="handle">@HeyItsGilbert</p>

<!---
2pm Monday
---->

---

<!-- _class: sponsors -->
<!-- _paginate: skip -->

# Thanks

---

<!-- _class: centered -->

# Hey! It's Gilbert

<!-- Author slide -->

- Staff Software Development Engineer
- ADHD 🌶️🧠
- [Links.GilbertSanchez.com](https://links.gilbertsanchez.com)

![bg right](profile.jpg)

---
<!-- _class: centered -->
# <!-- fit --> Hands Up ✋

<!--
Speaker notes:
Welcome everyone. Quick show of hands — who here manages Chocolatey packages? 
Who's done it by hand? Keep that hand up if you've ever said "just run this script 
and then run that one." Yeah. That's what we're fixing today.
-->

---

<!-- class: centered -->
# "Back in my day..."

## The year is 2013

<!--
Panning shot to a young and eager Gilbert ripsticking down the hallway....
Responsible for lots of things.
Patching, vmware, etc.
--->
---

## The Build Process

### _"The ticket queue **was** the build process."_

* Teams needed a Windows packages built and deployed.
* They filed a ticket
* Someone (eventually) hand-crafted it
* That someone was the only one who knew how

<!-- 
Speaker notes:
At Meta we had hundreds of apps running across 30,000 Windows machines.
The "build process" for Chocolatey packages was: file a ticket, wait, hope.
The person who built your package kept the knowledge in their head.
Then they left. Or got pulled onto something else. And you were stuck.
That doesn't scale. It barely works at 10 packages.
-->

---

<!-- _class: big-statement -->

# "It Works on My Machine"

---

## Except your devs are on **Macs**

* File locking differently
* Windows-specific paths, encodings, behaviors
* Packaging Windows software felt like a **foreign language**

_Extra friction became an extra excuse._

<!-- 
Speaker notes:
This was a real pattern. Teams building cross-platform software would just skip 
Windows packaging because it felt hard and alien. The file locking bugs alone 
were a constant source of tickets. POSIX vs Windows file locking semantics 
bite you in ways you don't expect until a machine at 2am tells you about it.
If the tooling makes it hard, people won't do it. Simple as that.
-->

---
<!-- _class: big-statement -->
# Chocolatey is just PowerShell

### _If you can write a script, you can ship a package._

<!-- 
Speaker notes:
This is the core insight I want you to leave with, even if you forget everything else.
There's no magic. No proprietary format. No arcane knowledge required.
A Chocolatey package is a nuspec file and a PowerShell script.
That's it. We're going to prove it in about 10 minutes.
Side note for consumers: choco install mypackage is all they ever see.
Your packaging work is invisible to them — which is the goal.
-->

---

## Scaffolding a Package

<!-- Act 2: Chocolatey Crash Course -->
`choco new mypackage`

```
mypackage/
├── mypackage.nuspec           ← package metadata
└── tools/
    ├── chocolateyInstall.ps1  ← runs on install
    ├── chocolateyUninstall.ps1
    └── LICENSE.txt
```

<br>

_That's the whole package._

<!--
7m mark - 2:07p
choco new scaffolds everything for you. The nuspec is your package manifest —
name, version, dependencies. The install script is PowerShell that runs when
someone does choco install. Two files that matter. That's the whole mental model.
-->

---

## The Two Files That Matter: Metadata

**mypackage.nuspec** — _what_ the package is

```xml
<metadata>
  <id>mypackage</id>
  <version>1.0.0</version>
  <description>Does a thing.</description>
</metadata>
```
<!--
The nuspec is just XML. The install script is just PowerShell.
-->
---

## The Two Files That Matter: Installer

**tools/chocolateyInstall.ps1** — _how_ it installs

```powershell
$packageArgs = @{
  packageName = 'mypackage'
  url         = 'https://example.com/installer.exe'
  checksum    = 'ABC123...'
}
Install-ChocolateyPackage @packageArgs
```

<!--
Install-ChocolateyPackage handles downloads, checksums, and silent installs.
If you know PowerShell, you already know how to write this.
No Chocolatey-specific magic. Just PowerShell with convenience functions on top.
-->

---

## Extensions

Add new functions to any package

```
mycompany-chocolatey-extension/
└── extensions/
    └── mycompany-helpers.psm1  ← imported automatically
```

---

## Hooks

Run logic around every install

```
mycompany-hooks/
└── hooks/
    ├── pre-install-all.ps1     ← before any package installs
    └── post-install-all.ps1    ← after any package installs
```

<!--
Speaker notes:
<pre|post>-<install|beforemodify|uninstall>-<packageID>.ps1
Hooks fire around every single install without the package author doing anything.
Install your hook package once, and it runs everywhere.
We'll come back to this with a real example in a minute.
-->

---
<!-- _class: big-statement -->

![bg right contain](psake-logo.svg)

# psake

### _Tasks with dependencies_

That's it. PowerShell Tasks.

<!--
13-15m mark ~ 2:15pm
Speaker notes:
psake — pronounced "sake" like the Japanese rice wine, not "p-sake" —
is a build automation tool written in PowerShell. Think Make or Rake,
but for PowerShell people. You declare tasks, you declare what each task
depends on, psake runs them in the right order and stops loudly if something fails.
I maintain psake, which is either a great reason to trust me on this
or a great reason to be suspicious. I'll let you decide.
The reason I keep coming back to it for Chocolatey work is the same reason
I fell for it in the first place: it's the language you're already writing.
No context switch. No new mental model. Just PowerShell.
-->

---

## Your Build Process is a README and Hope

<br>

```
# HOW TO RELEASE (don't forget these steps)
1. Validate the nuspec manually
2. Run choco pack
3. Run the tests (yes, before you push JOHN!)
4. Push to the feed — but only on main!
```

<br>

_Every step is a chance for someone to skip it._

<!--
Show of hands — who has a README like this?

The problem isn't the steps. The steps are fine. The problem is that
the steps live in a document nobody reads until something breaks.

That's not a people problem. That's an automation problem.
-->

---

## Manual Steps → Declared Tasks

```powershell
Task Default -depends Pack

Task Test -depends -description "Run Pester tests" {
    Invoke-Pester .\Tests\
}

Task Pack -depends Test -description "Build the .nupkg" {
    exec { choco pack }
}

Task Push -depends Pack -precondition { $env:GITHUB_REF -eq 'refs/heads/main' } {
    exec { choco push mypackage.nupkg --source $env:CHOCO_FEED }
}
```

<!--
Every "don't forget" becomes a dependency.

The precondition on Push means
it simply won't run unless you're on main — no human judgement required.

Notice the descriptions — that's what shows up in Invoke-psake -docs.
Your build script is now self-documenting. Sarah doesn't need to read the README.
-->

---

## The Task Graph

```
Push  (only on main)
 └── Pack
      └── Test
```

Run everything: `Invoke-psake`

Run just tests: `Invoke-psake -taskList Test`

<br>

_Same command. Local or CI. No surprises._

<!--
The dependency graph means you never think about order again.

Want to just repack without re-running tests? Invoke-psake -taskList Pack.
The exact same command you just ran at your desk is what GitHub Actions will run.
No drift. If it passes locally, it passes in CI.

Now — let me show you why this matters when your infrastructure
is more complicated than a single package. The Brazil story.
-->

---

<!-- _class: big-statement -->

# The Brazil Story

<!---
Small office. Bad connection. 200mb Office Killed.

CDN was in DC's.

--->

---

## The Brazil Story

Extensions put your org's knowledge in one place.

```powershell
# mycompany-chocolatey-extension/extensions/mycompany-helpers.psm1
function Get-PackageFromCDN {
    param($PackageName, $Version)

    $node   = Resolve-NearestCDNNode          # ← finds São Paulo, not Virginia
    $cached = Test-CDNCache -Node $node -Package $PackageName

    if ($cached) { Get-FromCache  -Node $node -Package $PackageName }
    else         { Get-FromOrigin -Package $PackageName -Version $Version }
}
```

_Every package calls `Get-PackageFromCDN`. Nobody hard-codes the CDN._

<!--

We put all of that CDN routing logic into an extension.
One module. One place to fix. One place to improve.
Teams writing packages didn't need to know any of it existed.
They called Get-PackageFromCDN and it did the right thing for their location.
That's what extensions are for: your org's infrastructure knowledge
in one module, not scattered across hundreds of install scripts.
-->

---
<!-- _class: big-statement -->

<!-- Act 4: Live Demo -->

# Let's build it

<br>

_Blank repo → published, tested, CI-backed package._

<!--
25-30m - 2:30

Here's what we're going to build in the next 20 minutes:
A GitHub repo with a Chocolatey package, a psakefile that validates,
tests, and packs it, and GitHub Actions workflows that run CI on PRs
and auto-publish when we merge to main.
If you want to follow along, the repo will be linked at the end.
[SWITCH TO TERMINAL]

Demo script:
1. gh repo create choco-psake-demo --public
2. choco new mypackage — show the generated structure
3. Write psakefile.ps1 with Test, Pack, Push tasks
4. Add nuspec XML schema validation task
5. Add Pester test for package metadata
6. Run Invoke-psake locally — watch it pass
7. Add .github/workflows/ci.yml — test on PR
8. Add .github/workflows/publish.yml — push on merge to main
9. Push, open a PR, watch CI go green
10. Merge, watch the package publish
-->

---

<!-- Act 5: Payoff -->

## What We Just Built

| Step | What it does |
|---|---|
| `.\build.ps1 -Task Test` | Runs Pester tests against the package |
| `.\build.ps1 -Task Pack` | Builds the `.nupkg` |
| `.\build.ps1 -Task Push` | Publishes — but only from main |
| CI workflow | Validates + tests every PR |
| Publish workflow | Auto-publishes on merge |

_Same psakefile. Local and CI. No surprises._

<!--
Goal: 40m
Speaker notes:
Here's what we just wired together. The key insight is the bottom row —
none of this required separate scripts for local vs CI.
One psakefile. Everywhere.
-->

---

## "I Only Have 5 Packages"

You still get:

<div class="checklist">

- Auto-publish on merge
- Validated nuspec XML
- Pester tests
- Extensions & Hooks

</div>

_Automation that reduces toil scales down just as well as it scales up._

<!--
Speaker notes:
I want to kill a misconception before you leave. This is not enterprise-only tooling.
The patterns we used today — declared tasks, validated XML, tested packages,
auto-publishing — these pay off at 5 packages just as much as 500.
You get your Saturday afternoons back. You stop being the person
who has to manually push a release because nobody else knows how.
That's worth it at any scale.

- Auto-publish on merge — no manual push steps
- Validated nuspec XML — catch errors before they ship
- Pester tests — know it works before your users find out it doesn't
- Extensions — your org's logic in one place, not copy-pasted everywhere
- Hooks — compliance, logging, CDN routing — free for every package
-->

---

## Your Mac Dev Just Shipped a Windows Package

<br>

They didn't touch a Windows machine.

They didn't learn Chocolatey internals.

They opened a PR. CI went green. They merged.

<br>

_The packaging knowledge lives in the psakefile — not in someone's head._

<!--
Speaker notes:
This is the Meta story, but it's also your story if you want it to be.
The developer who doesn't "do Windows" can still contribute because
the process is encoded, tested, and automated.
The person who built the psakefile doesn't need to be in the loop for every release.
That's what good tooling does — it transfers knowledge from people into systems.
-->

---
<!-- _class: big-statement -->

# Boring is good

### _Predictable. Auditable. Repeatable._

_The best build pipeline is the one you forget about._

<!--
Speaker notes:
I want to leave you with this. The goal was never "cool automation."
The goal was never to impress anyone with your psakefile.
The goal is a build pipeline so reliable, so boring,
that you stop thinking about it entirely — and just ship packages.
That's what we built today.
Demo repo is at the link. psake is open source and always looking for contributors.
I'm around for questions — thank you.
-->

---

<!-- _class: title -->
# <span class="gradient-text">THANK YOU</span>

## <span class="primary">Feedback</span> is a <span class="quaternary">gift</span>

<p class="name">Please review this session via the mobile app</p>
<p class="handle">Questions? Find me @heyitsgilbert</p>
