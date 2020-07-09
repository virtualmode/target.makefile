@echo off

rem Configure Windows environment to use target.makefile with Visual Studio C/C++ toolchain.
rem @param %1 Make target.
rem @param %2 Configuration (debug or release).
rem @param %3 Platform (x86 or amd64).

rem Current directory of Visual Studio Code workspace:
set currentDir=%CD%\
set vsDir=%programfiles(x86)%\Microsoft Visual Studio\

rem Setup environment variables:
FOR /l %%i in (2017, 1, 2019) DO IF exist "%vsDir%%%i\" set vsVersionDir=%vsDir%%%i\
IF exist "%vsVersionDir%Professional\" set vsEditionDir=%vsVersionDir%Professional\
IF exist "%vsVersionDir%Enterprise\" set vsEditionDir=%vsVersionDir%Enterprise\
set vsDir=%vsEditionDir%Common7\Tools\
cd /d %vsDir%
rem Use CALL to prevent this script termination after VsDevCmd.bat finishes.
CALL VsDevCmd.bat -arch=%3
echo.

rem Prepare variables:
set vctools=%VCToolsInstallDir%lib\%VSCMD_ARG_TGT_ARCH%
set um=%WindowsSdkDir%lib\%UCRTVersion%\um\%VSCMD_ARG_TGT_ARCH%
set ucrt=%WindowsSdkDir%lib\%UCRTVersion%\ucrt\%VSCMD_ARG_TGT_ARCH%

rem Make program:
cd /d %currentDir%
make %1 CONFIGURATION=%2 PLATFORM=%3 LIBRARY_PATH='%vctools%:%um%:%ucrt%' -C %currentDir% --no-print-directory
echo.
