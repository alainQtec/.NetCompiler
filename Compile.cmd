@echo off
pushd .& setlocal

set dotNetBase=%SystemRoot%\Microsoft.NET\Framework\
rem get latest .net path containing csc.exe:
set dotNet20=%dotNetBase%v2.0.50727\
set dotNet35=%dotNetBase%v3.5\
set dotNet40=%dotNetBase%v4.0.30319\
if exist %dotNet20%nul set dotNet=%dotNet20%
if exist %dotNet35%nul set dotNet=%dotNet35%
if exist %dotNet40%nul set dotNet=%dotNet40%
set msbuildDir=%ProgramFiles(x86)%\MSBuild\14.0\Bin\
set cscExe="%msbuildDir%csc.exe"
if not exist %cscExe% set cscExe="%dotNet%csc.exe"
::echo %cscExe%

set assemblies=
REM reference required assemblies here, copy them to the output directory after the colon (:), separated by comma
REM set assemblies=-reference:.\PresentationCore.Dll,.\WindowsBase.dll

set runArgs=%3 %4 %5 %6 %7 %8 %9 
if not "%1"=="/run" (set outPath=%~DP1& set outFileName=%~n1& CALL :Compile) else (set outPath=%~DP2& set outFileName=%~n2& CALL :CompileAndRun)
GOTO :End

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