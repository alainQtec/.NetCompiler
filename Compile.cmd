@(echo off% <#%) &color 07 & title C# Compiler & mode 100,30 & pushd %~dp0 >nul
set runArgs=%*& set "0=%~f0"& powershell -nop -executionpolicy unrestricted -command "iex ([io.file]::ReadAllText($env:0))"
:: Get-Item $env:1 | Unblock-File
popd & exit /b ||#>)[1];
<#
# Copyright (c) Alain Herve.
# Licensed under the MIT License.
#=======================================================================================#

    FileName     : C# Compiler
    Author       : @alainQtec
    Version      : 1.0
    Date         : Monday, January 17, 2022 8:17:45 PM
    Link         : https://raw.githubusercontent.com/alainQtec/.files/functions/Main.ps1
    More info    : https://alainQtec.com/

#=======================================================================================#

:Compile
    echo Compiling "%outPath%%outFileName%.cs"
    if exist "%outPath%%outFileName%.exe" del /F "%outPath%%outFileName%.exe" 
    %cscExe% -optimize+ -lib:"%dotNet%\" %assemblies% /t:exe /out:"%outPath%%outFileName%.exe" %outFileName%.cs
exit /B

:CompileAndRun
    echo Compiling "%outPath%%outFileName%.cs"
    if exist "%outPath%%outFileName%.exe" del /F "%outPath%%outFileName%.exe" 
    %cscExe% -optimize+ -lib:"%dotNet%\" %assemblies% /t:exe /out:"%outPath%%outFileName%.exe" %outFileName%.cs >nul
    echo Running "%outPath%%outFileName%.exe"
    "%outPath%%outFileName%.exe" %runArgs%
exit /B
    
:End 
::::
#>
function Invoke-CSCompiler {
    [CmdletBinding()]
    param (
        # Path cs file to compile
        [Parameter(Mandatory = $false)]
        [string]$Path,
        # Outpath
        [Parameter(Mandatory = $false)]
        [string]$Outpath
    )
    
    begin {
        $OldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'silentlyContinue'
        $IsLinuxEnv = (Get-Variable -Name "IsLinux" -ErrorAction Ignore) -and $IsLinux
        $IsMacOSEnv = (Get-Variable -Name "IsMacOS" -ErrorAction Ignore) -and $IsMacOS
        $script:IsWinEnv = !$IsLinuxEnv -and !$IsMacOSEnv
        # Load functions
        try {
            $script:thisfile = Get-Item $env:0
            $script:ScriptRoot = $thisfile.Directory
        }
        catch {
            $Error.exception.message
            exit
        }
        [System.IO.Directory]::SetCurrentDirectory($ScriptRoot)
        [string]$runArgs = $env:runArgs
        # [string]$dotNetBase = "$env:SystemRoot\Microsoft.NET\Framework"
        # [string]$CSc = [System.IO.Path]::Combine($([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()), 'csc.exe');
        # [bool]$CompileAndRun = [bool]$env:CompileAndRun
        Write-Output $($runArgs.ToString().Split(''))
        Pause
        exit
        Get-Item "Functions\*.ps1" | ForEach-Object {
            . "$($_.FullName)"
            [System.Console]::Write('Loaded'); Write-Host "`t$($_.BaseName)" -ForegroundColor Cyan
        }
    }
    
    process {
        
    }
    
    end {
        $ErrorActionPreference = $OldErrorActionPreference
        [gc]::Collect()
    }
}
Invoke-CSCompiler