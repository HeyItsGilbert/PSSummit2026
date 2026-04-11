<#
1. gh repo create choco-psake-demo --public
2. choco new mypackage — show the generated structure
3. Write psakefile.ps1 with Validate, Test, Pack, Push tasks
4. Add nuspec XML schema validation task
5. Add Pester test for package metadata
6. Run Invoke-psake locally — watch it pass
7. Add .github/workflows/ci.yml — test on PR
8. Add .github/workflows/publish.yml — push on merge to main
9. Push, open a PR, watch CI go green
10. Merge, watch the package publish
#>
ConvertTo-Sixel -Url "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExbHN6eWo3ZjYwdjJieHNwdGRmd2ZuODIzNDR4cmVteG1sbGI4NXp3biZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3ohzdQ1IynzclJldUQ/giphy.gif"
return

# Launch the slides
# $PSScriptRoot won't work since we're running since I'm running in shell
$root = "D:\summit2026\StopHandRollingChocolate"
Set-Location $root
Invoke-Item "..\dist\StopHandRollingChocolate\stop-hand-rolling-chocolate.html"

<# Workflow
Demo script:
1. gh repo create choco-psake-demo --public
2. choco new mypackage — show the generated structure
3. Write psakefile.ps1 with Validate, Test, Pack, Push tasks
4. Add nuspec XML schema validation task
5. Add Pester test for package metadata
6. Run Invoke-psake locally — watch it pass
7. Add .github/workflows/ci.yml — test on PR
8. Add .github/workflows/publish.yml — push on merge to main
9. Push, open a PR, watch CI go green
10. Merge, watch the package publish
#>

#region Create a Github Repo
$demoFolder = "$root\DemoFolder"
New-Item -Path $demoFolder -ItemType Directory -Force
Push-Location $demoFolder
# gh repo create choco-psake-demo --public
# I'm sort of cheating since I pre-staged a readme and a build.ps1.
gh repo clone choco-psake-demo
Push-Location choco-psake-demo
#endregion Create a Github Repo

#region Create new package
choco new mypackage

Get-ChildItem -Recurse mypackage
#endregion Create new package

#region Create tests
New-Item -Path "Tests" -ItemType Directory -Force
Push-Location "Tests"
New-Item -Path "Test-PackageMetadata.Tests.ps1" -ItemType File -Force
Add-Content -Path "Test-PackageMetadata.Tests.ps1" -Value @'
BeforeDiscovery {
  # FYI this is a naive approach since this would test every package every time
  $nonPackageFolders = @(
    'Tests',
    'Docs',
    '.github',
    '.psake',
    '.vscode',
    'output'
  )
  $parentFolder = Split-Path -Path $PSScriptRoot -Parent
  $script:packages = Get-ChildItem -Path $parentFolder -Directory | Where-Object { $nonPackageFolders -notcontains $_.Name }
}
Describe 'Package Tests <_.BaseName>' -ForEach $script:packages {
  BeforeAll {
    $script:packageName = $_.BaseName
  }
  It 'should have a valid nuspec file' {
    $nuspecPath = Join-Path -Path $_.FullName -ChildPath "$script:packageName.nuspec"
    Test-Path -Path $nuspecPath | Should -BeTrue -Because "The package should have a nuspec file at $nuspecPath"
  }
}
'@

# Let's check it out
code Test-PackageMetadata.Tests.ps1

Pop-Location

Invoke-Pester -Path ".\Tests\" -Output Detailed
#endregion Create tests

#region Psake
New-Item -Path "psakefile.ps1" -ItemType File -Force
Add-Content -Path "psakefile.ps1" -Value @'
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments',
    '',
    Justification = 'These variables are used implicitly by psake tasks and should not be flagged as unused.'
)]
param()
# spell-checker:ignore psake psakefile choco

# A Sneak Peek!
Version 5

# Change how the task names are formatted in the console output
FormatTaskName {
    param($taskName)
    # Calculate the maximum length of task names for padding
    $maxLength = 80
    $padding = '=' * (($maxLength - $taskName.Length) / 2)
    Write-Host "$padding $taskName $padding" -ForegroundColor Blue
}

# All properties/parameters are available to each task.
Properties {
    $PackageName = $null
    $OutputFolder = "$PSScriptRoot\output"
    $ExcludedFolders = @(
        'Tests',
        'Docs',
        '.github',
        '.psake',
        '.vscode',
        'output'
    )
}

Task 'Default' @{
    DependsOn = @('Test')
}

Task 'Clean' @{
    Description = 'Clean the output directory before building packages'
    Action = {
        Write-Host "Cleaning output directory..."
        if (Test-Path -Path $OutputFolder) {
            Remove-Item -Path $OutputFolder -Recurse -Force
            Write-Host "Output directory cleaned."
        } else {
            Write-Host "Output directory does not exist, nothing to clean."
        }
        New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
    }
}

Task 'DeterminePackages' @{
    Description = 'Determine which package folders to process based on the provided PackageName or by scanning the current directory'
    Action = {
        $script:packageFolders = @()
        if ($PackageName) {
            $script:packageFolders += Get-Item -Path $PackageName
        } else {
            $script:packageFolders += Get-ChildItem $PSScriptRoot -Directory |
                Where-Object { $_.BaseName -notin $ExcludedFolders } |
                Where-Object { Test-Path -Path (Join-Path $_.FullName "$($_.Name).nuspec") }
        }
        foreach ($folder in $script:packageFolders) {
            Write-Host "Found package folder: $($folder.FullName)"
        }
    }
}

Task 'Test' @{
    Description = 'Run Pester tests to validate package metadata and structure'
    Inputs = { Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.nuspec, *.ps1 -Exclude psakefile.ps1, build.ps1 }
    Outputs = { Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.nuspec, *.ps1 -Exclude psakefile.ps1, build.ps1 }
    Action = {
        Write-Host "Running Pester tests..."
        Invoke-Pester -Path "$PSScriptRoot\Tests\" -Output Detailed
    }
}

Task 'Pack' @{
    DependsOn = @('Clean', 'DeterminePackages', 'Test')
    Description = 'Pack the Chocolatey packages using choco pack'
    Inputs = { Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.nuspec, *.ps1 -Exclude psakefile.ps1, build.ps1 }
    Outputs = { Get-ChildItem -Path $OutputFolder -Filter *.nupkg -ErrorAction SilentlyContinue }
    Action = {
        foreach ($folder in $script:packageFolders) {
            $nuspec = Get-ChildItem -Path $folder.FullName -Filter '*.nuspec' | Select-Object -First 1
            if (-not $nuspec) {
                Write-Warning "No .nuspec found in '$($folder.Name)', skipping."
                continue
            }

            Write-Host "Packing: $($nuspec.FullName)"
            Push-Location -Path $folder.FullName
            try {
                Exec {
                    choco pack $nuspec.Name --output-directory $OutputFolder
                }
                Write-Host "Successfully packed $($folder.Name)."
            } finally {
                Pop-Location
            }
        }
    }
}

Task 'VerifyNupkg' @{
    DependsOn = 'Pack'
    Description = 'Verify that .nupkg files were created for each package'
    Action = {
        # Check that each .nupkg corresponds to a package folder
        foreach ($folder in $script:packageFolders) {
            # Getting the version from the nuspec
            $nuspec = Get-Item -Path "$($folder.FullName)\$($folder.BaseName).nuspec" -ErrorAction Stop
            $version = ([xml](Get-Content $nuspec.FullName)).package.metadata.version
            Assert ($version) "Version not found in nuspec for package '$($folder.Name)'."

            $expectedNupkgName = "$($folder.BaseName).$($version).nupkg"
            Assert (Test-Path -Path (Join-Path $OutputFolder $expectedNupkgName)) "Expected .nupkg file '$expectedNupkgName' was not found in the output directory."
            Test-Path -Path (Join-Path $OutputFolder $expectedNupkgName) -ErrorAction Stop
            Write-Host "Verified: $expectedNupkgName exists."
        }
    }
}

Task 'Publish' @{
    DependsOn = 'VerifyNupkg'
    Description = 'Publish the .nupkg files to Chocolatey'
    Action = {
        $nupkgFiles = Get-ChildItem -Path $OutputFolder -Filter '*.nupkg'
        foreach ($nupkg in $nupkgFiles) {
            Write-Host "Publishing: $($nupkg.Name)"
            Exec {
                choco push $nupkg.Name --source https://push.chocolatey.org/ --api-key YOUR_API_KEY
            }
            Write-Host "Successfully published: $($nupkg.Name)"
        }
    }
}
'@

# Test!
Invoke-Psake .\psakefile.ps1 -task Test

# Fix the tests!
# Oh yea... what's this psake ext?

# Build them all!
Invoke-Psake .\psakefile.ps1 -task Pack

# Fix the nuspec file so the test passes
code .\mypackage\mypackage.nuspec
#endregion Psake

#region Build.ps1
New-Item -Path "build.ps1" -ItemType File -Force
Add-Content -Path "build.ps1" -Value @'
[CmdletBinding(DefaultParameterSetName = 'Task')]
param(
  # Build task(s) to execute
  [parameter(ParameterSetName = 'task', position = 0)]
  [ArgumentCompleter( {
      param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
      try {
        Get-PSakeScriptTasks -BuildFile './build.psake.ps1' -ErrorAction 'Stop' |
          Where-Object { $_.Name -like "$WordToComplete*" } |
          Select-Object -ExpandProperty 'Name'
      } catch {
        @()
      }
    })]
  [string[]]$Task = 'default',

  # A Package to build
  [parameter()]
  [ArgumentCompleter( {
      param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
      Get-ChildItem -Directory -Path .\* -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "$WordToComplete*" } |
        Select-Object -ExpandProperty 'Name'
    })]
  [ValidateScript( {
      if (Test-Path -Path $_ -PathType Container) {
        $true
      } else {
        throw "Package path '$_' does not exist."
      }
    })]
  [string]$Package,

  # Bootstrap dependencies
  [switch]$Bootstrap,

  # List available build tasks
  [parameter(ParameterSetName = 'Help')]
  [switch]$Help,

  # Optional properties to pass to psake
  [hashtable]$Properties,

  # Optional parameters to pass to psake
  [hashtable]$Parameters
)
# spell-checker:ignore psake psakefile

$ErrorActionPreference = 'Stop'

# Bootstrap dependencies
if ($Bootstrap.IsPresent) {
  Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
  if ((Test-Path -Path ./requirements.psd1)) {
    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
      Install-Module -Name PSDepend -Repository PSGallery -Scope CurrentUser -Force
    }
    Import-Module -Name PSDepend -Verbose:$false
    Invoke-PSDepend -Path './requirements.psd1' -Install -Import -Force -WarningAction SilentlyContinue
  } else {
    Write-Warning 'No [requirements.psd1] found. Skipping build dependency installation.'
  }
}

# Execute psake task(s)
$psakeFile = './psakefile.ps1'
if ($PSCmdlet.ParameterSetName -eq 'Help') {
  Get-PSakeScriptTasks -BuildFile $psakeFile |
    Format-Table -Property Name, Description, Alias, DependsOn
} else {
  if ($Package) {
    # Merge the hashtable
    if ($Properties) {
      $Properties = @($Properties) + @{ PackageName = $Package }
    } else {
      $Properties = @{ PackageName = $Package }
    }
  }
  $invokePsakeSplat = @{
    BuildFile = $psakeFile
    TaskList = $Task
    NoLogo = $true
    Properties = $Properties
    Parameters = $Parameters
    Debug = $PSBoundParameters['Debug'] -or $DebugPreference -eq 'Continue'
    Verbose = $PSBoundParameters['Verbose'] -or $VerbosePreference -eq 'Continue'
  }
  if ($env:GITHUB_ACTIONS) {
    $invokePsakeSplat['OutputFormat'] = 'GitHubActions'
  }
  Invoke-Psake @invokePsakeSplat
  exit ([int](-not $psake.build_success))
}
'@
# Build.ps1 is the handy wrapper!
code .\build.ps1

# Don't forget your dependencies!
New-Item -Path 'requirements.psd1' -ItemType File -Force
Add-Content -Path 'requirements.psd1' -Value @'
@{
  PSDepend = @{
    Version = '0.3.8'
  }
  PSDependOptions = @{
    Target = 'CurrentUser'
  }
  'Pester' = @{
    Version = '5.7.1'
    Parameters = @{
      SkipPublisherCheck = $true
    }
  }
  'psake' = @{
    Version = 'latest'
    Parameters = @{
      AllowPrerelease = $true
    }
  }
}
'@
code .\requirements.psd1

# Or maybe just one?
Invoke-Psake .\build.ps1 -task Pack -Package mypackage
#endregion Build.ps1

#region Create GitHub Actions
New-Item -Path ".github\workflows" -ItemType Directory -Force
New-Item -Path ".github\workflows\ci.yml" -ItemType File -Force
Add-Content -Path ".github\workflows\ci.yml" -Value @'
name: CI
on:
  pull_request:
    branches: [main]
jobs:
  Test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run psake tests
        run: .\build.ps1 -Task VerifyNupkg -Bootstrap
'@
New-Item -Path ".github\workflows\publish.yml" -ItemType File -Force
Add-Content -Path ".github\workflows\publish.yml" -Value @'
name: Publish
on:
  push:
    branches: [main]
jobs:
  Publish:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run psake publish
        run: .\build.ps1 -Task Publish -Bootstrap
'@
#endregion Create GitHub Actions


#region Extension!
New-Item -Path ".\acmeco.extension" -ItemType Directory -Force
New-Item -Path ".\acmeco.extension\extensions" -ItemType Directory -Force
New-Item -Path ".\acmeco.extension\extensions\acmeco.Extension.psm1" -ItemType File -Force
Add-Content -Path ".\acmeco.extension\extensions\acmeco.Extension.psm1" -Value @'
function Get-AcmeCoChocolate {
    return "Here's some chocolate from AcmeCo!"
}
'@
New-Item -Path ".\acmeco.extension\acmeco.Extension.nuspec" -ItemType File -Force
Add-Content -Path ".\acmeco.extension\acmeco.Extension.nuspec" -Value @'
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>acmeco.extension</id>
    <version>0.1.0</version>
    <title>Example Extension</title>
    <authors>Joe Mama</authors>
    <description>A super cool extension package!</description>
    <summary>Extension package for testing.</summary>
    <tags>extension chocolatey package</tags>
  </metadata>
  <files>
    <file src="extensions\**" target="extensions" />
  </files>
</package>
'@

# Pack it!

# Add it as a dependency
code .\mypackage\tools\chocolateyinstall.ps1
code .\mypackage\mypackage.nuspec
#endregion Extension!