function Get-RoslynCompiler {
  <#
  .SYNOPSIS
    Install roslyn compiler package
  .DESCRIPTION
    Installs the latest .NET Compilers package.
    Referencing this package will cause the project to be built using the C# and Visual Basic compilers contained in the package, as opposed to the version installed with MSBuild.
    The tools in this package require .NET Framework 4.7.2+ 
  .EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
  .INPUTS
    Inputs (if any)
  .OUTPUTS
    Output (if any)
  .NOTES
    Dependencies: .NETFramework4.7.2
    Note: The roslyn package is deprecated. Please use Microsoft.Net.Compilers.Toolset instead
  .LINK
    https://github.com/dotnet/roslyn
  #>
  [CmdletBinding()]
  param (
    
  )
  
  begin {
    # $Params = @{
    #   InstallCommad  = "Install-Package Microsoft.CodeDom.Providers.DotNetCompilerPlatform -Version 3.6.0"
    #   GitHubRepo     = "https://github.com/aspnet/RoslynCodeDomProvider"
    #   GithubReleases = "https://github.com/aspnet/RoslynCodeDomProvider/releases"
    #   ProjectSite    = "https://www.asp.net/"
    # }
    # $params
  }
  
  process {
    
  }
  
  end {
    
  }
}