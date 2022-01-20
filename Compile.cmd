@(echo off% <#%) &color 07 & title C# Compiler & mode 100,30 >nul
setlocal enabledelayedexpansion
if [%1]==[] goto :Help
set C=0
for %%x in (%*) do (
    set /A C+=1
    set "argc[!C!]=%%~x"
)
::[int]$processedargs = %C%
for /L %%i in (1,1,%C%) do (
    if "!argc[%%i]!" == "/h" goto :Help
    if "!argc[%%i]!" == "-h" goto :Help
    if "!argc[%%i]!" == "/help" goto :Help
    if "!argc[%%i]!" == "-help" goto :Help
    if "!argc[%%i]!" == "--help" goto :Help
)
pushd %~dp0 >nul2>&1
set runArgs=%*& set "0=%~f0"& powershell -nop -executionpolicy unrestricted -command "iex ([io.file]::ReadAllText($env:0))"
endlocal
popd & goto :end
:Help
@echo C# Compiler Script [Version 1.0.0.1]
@echo By Alain @ https://alainQtec.com
@echo Licensed under the Coffee-WARE LICENSE
@echo.&echo Syntax   
@echo       Compile.cmd param1 param2 param3 
@echo.
@echo Key
@echo     param1      : The first parameter
@echo     param2      : The secnd parameter
@echo.
:end
exit /b ||#>)[1];
function Invoke-CSCompiler {
    <#
    .SYNOPSIS
        Compile CS stuff
    .DESCRIPTION
        USES THE BUILTIN csc.exe
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
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
    #>
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
        [string]$dotNetRD = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
        [string]$script:CSc = [System.IO.Path]::Combine($dotNetRD, 'csc.exe');
        if (-not [bool]$(try { Test-Path $CSc }catch { $false })) {
            Write-Host -NoNewline 'The CSc file: '; Write-Host -NoNewline $CSc -ForegroundColor Cyan; " was not found!`nAborting ..."; Start-Sleep -Seconds 2
            break script
        }
        # [bool]$CompileAndRun = [bool]$env:CompileAndRun
        # [System.Collections.ArrayList]$arrl = $($runArgs.ToString().Split(''))
        $arrl = $($runArgs.Split('')).ForEach([string])
        # parse args
        for ($i = 0; $i -lt $arrl.Count; $i++) {
            if ($arrl[$i] -eq '/f') { [int]$fa = $i }
            if ($arrl[$i] -eq '/o') { [int]$oa = $i }
        }
        $filenames = $arrl[($fa + 1)..($oa - 1)]
        $script:CSfiles = [System.Collections.ArrayList]::new()
        foreach ($name in $filenames) {
            if ([bool]$(try { Test-Path $file }catch { $false })) { $CSfiles.Add($(Get-Item $name)) }
        }
        $script:Outpath = $arrl[$oa + 1]
        #  Load functions
        # Get-Item "Functions\*.ps1" | ForEach-Object {
        #     . "$($_.FullName)"
        #     [System.Console]::Write('Loaded'); Write-Host "`t$($_.BaseName)" -ForegroundColor Cyan
        # }
    }
    
    process {
        # Path to assemblies
        $assemblieNames = @("PresentationCore.Dll", "WindowsBase.dll")
        $assemblies = [System.Collections.ArrayList]::new(); foreach ($name in $assemblieNames) {
            [string[]]$dlla = $(Get-ChildItem -Recurse C:/Windows/Microsoft.Net/assembly/ | Where-Object { $_.Name -like "*$name*" }).FullName
            $(if ($dlla.Count -gt 1) { $assemblies.Add($dlla[1]) }else { $assemblies.Add($dlla[0]) } ) | Out-Null
        }
        # Another way to find each their fullpath:
        # $([System.UriBuilder]::new($([TypeKnownToBeInTheDesiredAssembly]::new()).GetType().Assembly.CodeBase)).Path
        # Example:
        # $([System.UriBuilder]::new($([System.Xml.XmlDocument]::new()).GetType().Assembly.CodeBase)).Path

        # /nologo                        Suppress compiler copyright message
        # /win32icon:<file>              Use this icon for the output
        # /reference:<file list>         Reference metadata from the specified assembly files (Short form: /r)
        # /platform:<string>             Limit which platforms this code can run on: x86, Itanium, x64, arm, anycpu32bitpreferred, or anycpu. The default is anycpu.
        if (($CSfiles.count -gt 1) -and ($null -ne $Outpath)) {
            if ([bool]$(try { Test-Path $Outpath }catch { $false }) -and ($(Get-Item -Path $Outpath).Attributes -eq 'Directory')) {
                Write-Warning "Directory $outpath already exist"
                Start-Sleep -Seconds 2
                exit
            }
            else {
                New-Item -Path $Outpath -ItemType Directory | Out-Null
            }
        }
        if (($CSfiles.count -gt 1) -and ($null -eq $Outpath)) {
            foreach ($file in $CSfiles) {
                [System.Console]::Write('Compiling'); Write-Host $file.Name -ForegroundColor Cyan
                $OutFile = "$($file.Directory)$($file.BaseName).exe"
                if ([bool]$(try { Test-Path $OutFile }catch { $false })) { Remove-Item $OutFile -Force }
                & $CSc -nologo -optimize+ -lib:"$dotNetRD" -reference:$assemblies /t:exe /out:"$OutFile" "$($file.FullName)"
            }
        }
        else {
            foreach ($file in $CSfiles) {
                [System.Console]::Write('Compiling'); Write-Host $file.Name -ForegroundColor Cyan
                $OutFile = $([System.IO.Path]::Combine($Outpath, "$($file.BaseName).exe"))
                if ([bool]$(try { Test-Path $OutFile }catch { $false })) { Remove-Item $OutFile -Force }
                & $CSc -nologo -optimize+ -lib:"$dotNetRD" -reference:$assemblies /t:exe /out:"$OutFile" "$($file.FullName)"
            }
        }
        try { Remove-Variable filenames , CSfiles }catch { $null }
        Pause
    }
    
    end {
        $ErrorActionPreference = $OldErrorActionPreference
        [gc]::Collect()
    }
}
Invoke-CSCompiler

<#
https://msdn.microsoft.com/en-us/library/ms379563(v=vs.80).aspx
c:\windows\Microsoft.NET\Framework\v3.5\bin\csc.exe /t:exe /out:MyApplication.exe MyApplication.cs

Another Option:
For the latest version, first open a Powershell window, go to any folder (e.g. c:\projects\) and run the following

# Get nuget.exe command line
wget https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile nuget.exe

# Download the C# Roslyn compiler (just a few megs, no need to 'install')
.\nuget.exe install Microsoft.Net.Compilers

# Compiler, meet code
.\Microsoft.Net.Compilers.1.3.2\tools\csc.exe .\HelloWorld.cs

# Run it
.\HelloWorld.exe

# You can also try the new C# interpreter ;)
.\Microsoft.Net.Compilers.1.3.2\tools\csi.exe
> Console.WriteLine("Hello world!");
Hello world!
#>