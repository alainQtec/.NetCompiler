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
                # & $CSc -optimize+ -lib:"$dotNetRD" %assemblies% /t:exe /out:"$OutFile" "$($file.FullName)"
            }
        }
        else {
            foreach ($file in $CSfiles) {
                [System.Console]::Write('Compiling'); Write-Host $file.Name -ForegroundColor Cyan
                $OutFile = $([System.IO.Path]::Combine($Outpath, "$($file.BaseName).exe"))
                if ([bool]$(try { Test-Path $OutFile }catch { $false })) { Remove-Item $OutFile -Force }
                # & $CSc -optimize+ -lib:"$dotNetRD" %assemblies% /t:exe /out:"$OutFile" "$($file.FullName)"
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