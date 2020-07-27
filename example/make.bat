@echo off

rem Configure Windows environment to use target.makefile with Visual Studio C/C++ toolchain and make.
rem @param %1 Platform for VsDevCmd.bat.
rem @param %n Make parameters.

rem Prepare parameters and skip first:
FOR /f "tokens=1*" %%x IN ("%*") DO set argv=%%y

rem Current directory of Visual Studio Code workspace:
set currentDir=%CD%\
set vsDir=%programfiles(x86)%\Microsoft Visual Studio\

rem Check debug configuration:
IF %2 == clean GOTO MAKE

rem Setup environment variables:
FOR /l %%i in (2017, 1, 2019) DO IF exist "%vsDir%%%i\" set vsVersionDir=%vsDir%%%i\
IF exist "%vsVersionDir%Professional\" set vsEditionDir=%vsVersionDir%Professional\
IF exist "%vsVersionDir%Enterprise\" set vsEditionDir=%vsVersionDir%Enterprise\
set vsDir=%vsEditionDir%Common7\Tools\
cd /d %vsDir%
rem Use CALL to prevent this script termination after VsDevCmd.bat finishes.
CALL VsDevCmd.bat -arch=%1
echo.

rem Prepare variables:
set vctools=%VCToolsInstallDir%lib\%VSCMD_ARG_TGT_ARCH%
set um=%WindowsSdkDir%lib\%UCRTVersion%\um\%VSCMD_ARG_TGT_ARCH%
set ucrt=%WindowsSdkDir%lib\%UCRTVersion%\ucrt\%VSCMD_ARG_TGT_ARCH%

:MAKE

rem Make program:
make %argv% LIBRARY_PATH='%vctools%:%um%:%ucrt%'
echo.
