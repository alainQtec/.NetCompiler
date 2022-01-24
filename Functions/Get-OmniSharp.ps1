function Get-OmniSharpRoslyn {
  <#
  .SYNOPSIS
    Gets/download the latest version of OmniSharp-roslyn
  .DESCRIPTION
    scraps:
    # https://github.com/OmniSharp/omnisharp-roslyn/releases
    
    # OmniSharp-roslyn Management tool
    #
    # Works on: Microsoft Windows

    # Usage Options / Paameters:
    # -v | version to use (otherwise use latest)
    # -l | where to install the server
    # -u | help / usage info
    # -H | install the HTTP version of the server
  .EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
  .INPUTS
    Inputs (if any)
  .OUTPUTS
    Output (if any)
  .NOTES
    General notes
  #>
  [CmdletBinding()]
  Param(
    [Parameter()][Alias('v')][string]$version,
    [Parameter()][Alias('l')][string]$location = "$($env:USERPROFILE)\.omnisharp\",
    [Parameter()][Alias('u')][switch]$usage,
    [Parameter()][Alias('H')][switch]$http_check
  )
  
  begin {
    
  }
  
  process {        
    if ($usage) {
      Write-Host "usage:" $MyInvocation.MyCommand.Name "[-Hu] [-v version] [-l location]"
      exit
    }
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    function get_latest_version() {
      # The output should be minimal:
      # EXAMPLE Downloading package 'OmniSharp for Windows (.NET 4.6 / x64)' 	
      # Retrying from 'https://roslynomnisharp.blob.core.windows.net/releases/1.37.16/omnisharp-win-x64-1.37.16.zip'
      $tmp = Invoke-RestMethod -Uri "https://api.github.com/repos/OmniSharp/omnisharp-roslyn/releases/latest"
      return $tmp.tag_name
    }
    
    if ([string]::IsNullOrEmpty($version)) {
      $version = get_latest_version
    }
    
    if ($http_check) {
      $http = ".http"
    }
    else {
      $http = ""
    }
    
    if ([Environment]::Is64BitOperatingSystem) {
      $machine = "x64"
    }
    else {
      $machine = "x86"
    }
    
    $url = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/$($version)/omnisharp$($http)-win-$($machine).zip"
    $out = "$($location)\omnisharp$($http)-win-$($machine).zip"
    
    if (Test-Path -Path $location) {
      Remove-Item $location -Force -Recurse
    }
    New-Item -ItemType Directory -Force -Path $location | Out-Null
    
    #Run as SilentlyContinue to avoid progress bar that can't be seen
    $ProgressPreference = 'SilentlyContinue'
    try {
      Invoke-WebRequest -Uri $uri -OutFile $out
    }
    catch {
      $errorDetails = $null
      $response = $_.Exception | Select-Object -ExpandProperty 'Response' -ErrorAction Ignore
      if ( $response ) {
        $errorDetails = $_.ErrorDetails
      }
      # Not an exception making the request or the failed request didn't have a response body.
      if ($null -eq $errorDetails) {
        Write-Error -ErrorRecord $_
      }
      else {
        Write-Error -Message ('Request to "{0}" failed: {1}' -f $uri, $errorDetails)
      }
    }
    
    #Run Expand-Archive in versions that support it
    if ($PSVersionTable.PSVersion.Major -gt 4) {
      Expand-Archive $out -DestinationPath $location -Force
    }
    else {
      Add-Type -AssemblyName System.IO.Compression.FileSystem
      [System.IO.Compression.ZipFile]::ExtractToDirectory( $out, $location )
    }
    
    #Check for file to confirm download and unzip were successful
    if (Test-Path -Path "$($location)\OmniSharp.Roslyn.dll") {
      Set-Content -Path "$($location)\OmniSharpInstall-version.txt" -Value "OmniSharp $($version)"
      exit 0
    }
    else {
      exit 1
    }
  }
  
  end {
    [gc]::Collect()
  }
}