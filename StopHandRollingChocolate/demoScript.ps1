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

<# Workflow

#>

<# Psake File
```powershell

```
#>