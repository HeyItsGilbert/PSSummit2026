@{
  PSDependOptions = @{
    Target = 'CurrentUser'
  }
    
  'psake' = @{
    Version = '5.0.0'
    Parameters = @{
      AllowPrerelease = $true
    }
  }
}