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
Set-Location $demoFolder
# gh repo create choco-psake-demo --public
# I'm sort of cheating since I prestaged a readme and a build.ps1.
gh repo clone choco-psake-demo
Set-Location choco-psake-demo
#endregion Create a Github Repo

##region Create new package
choco new mypackage

Get-ChildItem -Recurse mypackage
#endregion Create new package

#region Create tests
New-Item -Path "Tests" -ItemType Directory -Force
Set-Location "Tests"
New-Item -Path "Test-PackageMetadata.Tests.ps1" -ItemType File -Force
Add-Content -Path "Test-PackageMetadata.Tests.ps1" -Value @'
BeforeDiscovery {
  # FYI this is a naive approach since this would test every package every time
  $nonPackageFolders = @(
    'Tests',
    'Docs',
    '.github',
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
  It 'should have a valid nuspec file' -ForEach $script:packages {
    $nuspecPath = Join-Path -Path $_.FullName -ChildPath "$script:packageName.nuspec"
    Test-Path -Path $nuspecPath | Should -BeTrue -Because "The package should have a nuspec file at $nuspecPath"
  }
}
'@
Pop-Location
code Test-PackageMetadata.Tests.ps1

Invoke-Pester -Path ".\Tests\" -Output Detailed
#endregion Create tests

#region Psake
New-Item -Path "psakefile.ps1" -ItemType File -Force
Add-Content -Path "psakefile.ps1" -Value @'
Version 5
FormatTaskName {
    param($taskName)
    # Calculate the maximum length of task names for padding
    $maxLength = 80
    $padding = '=' * (($maxLength - $taskName.Length) / 2)
    Write-Host "$padding $taskName $padding" -ForegroundColor Blue
}
Properties {
    # All properties/parameters are available to each task. $Script: makes PSScriptAnalyzer happy.
    $script:PackageName = $null
    $script:OutputFolder = "$PSScriptRoot\output"
    $script:ExcludedFolders = @('Tests', 'Docs', '.github', '.vscode', 'output')
}

Task Default -Depends Test

Task Clean -Description "Clean the output directory before building packages" {
    Write-Host "Cleaning output directory..."
    if (Test-Path -Path $script:OutputFolder) {
        Remove-Item -Path $script:OutputFolder -Recurse -Force
        Write-Host "Output directory cleaned."
    } else {
        Write-Host "Output directory does not exist, nothing to clean."
    }
    New-Item -Path $script:OutputFolder -ItemType Directory -Force | Out-Null
}

Task DeterminePackages -Description "Determine which package folders to process based on the provided PackageName or by scanning the current directory" {
    $script:packageFolders = @()
    if ($script:PackageName) {
        $script:packageFolders += Get-Item -Path $script:PackageName
    } else {
        $script:packageFolders += Get-ChildItem -Directory |
            Where-Object { $script:ExcludedFolders -notcontains $_.Name }
    }
    foreach ($folder in $script:packageFolders) {
        Write-Host "Found package folder: $($folder.FullName)"
    }
}

Task Test -Description "Run Pester tests to validate package metadata and structure" {
    Write-Host "Running Pester tests..."
    Invoke-Pester -Path "$PSScriptRoot\Tests\" -Output Detailed
}

Task Pack -Depends Clean, DeterminePackages, Test -Description "Pack the Chocolatey packages using choco pack" {
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
                choco pack $nuspec.Name --output-directory $script:OutputFolder
            }
            Write-Host "Successfully packed $($folder.Name)."
        } finally {
            Pop-Location
        }
    }
}

Task VerifyNupkg -Depends Pack -Description "Verify that .nupkg files were created for each package" {
    # Check that each .nupkg corresponds to a package folder
    foreach ($folder in $script:packageFolders) {
        $name = $folder.Name
        # Getting the version from the nuspec
        $nuspec = Get-Item -Path "$($folder.FullName)\$($name).nuspec" -ErrorAction Stop
        $version = ([xml](Get-Content $nuspec.FullName)).package.metadata.version

        $expectedNupkgName = "$name-$version.nupkg"
        Test-Path -Path (Join-Path $script:OutputFolder $expectedNupkgName) -ErrorAction Stop
        Write-Host "Verified: $expectedNupkgName exists."
    }
}

Task Publish -Depends VerifyNupkg -Description "Publish the .nupkg files to Chocolatey" {
    $nupkgFiles = Get-ChildItem -Path $script:OutputFolder -Filter '*.nupkg'
    foreach ($nupkg in $nupkgFiles) {
        Write-Host "Publishing: $($nupkg.Name)"
        Exec {
            choco push $nupkg.Name --source https://push.chocolatey.org/ --api-key YOUR_API_KEY
        }
        Write-Host "Successfully published: $($nupkg.Name)"
    }
}
'@

# Test!
Invoke-Psake .\psakefile.ps1 -task Test

# Build them all!
Invoke-Psake .\psakefile.ps1 -task Pack

# Fix the nuspec file so the test passes
code .\mypackage\mypackage.nuspec

# Or maybe just one?
Invoke-Psake .\psakefile.ps1 -task Pack -Properties @{ PackageName = 'mypackage' }
#endregion Psake

#region Create GitHub Actions
New-Item -Path ".github\workflows" -ItemType Directory -Force
New-Item -Path ".github\workflows\ci.yml" -ItemType File -Force
Add-Content -Path ".github\workflows\ci.yml" -Value @'
name: CI
on:
  pull_request:
    branches: [ main ]
steps:
  - uses: actions/checkout@v3
  - name: Run psake tests
    run: Invoke-Psake .\psakefile.ps1 -task Test
'@
New-Item -Path ".github\workflows\publish.yml" -ItemType File -Force
Add-Content -Path ".github\workflows\publish.yml" -Value @'
name: Publish
on:
  push:
    branches: [ main ]
steps:
  - uses: actions/checkout@v3
  - name: Run psake pack
    run: Invoke-Psake .\psakefile.ps1 -task Publish
'@
#endregion Create GitHub Actions