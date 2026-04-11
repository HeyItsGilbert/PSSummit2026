@{
  PSDependOptions = @{
    Target = 'CurrentUser'
  }
    
  'psake' = @{
    Version = 'latest'
    Parameters = @{
      AllowPrerelease = $true
    }
  }
}