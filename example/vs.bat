@echo off

rem Prepare environment to use target.makefile in Windows with Visual Studio C/C++ toolchain.
rem @param %1 Visual Studio version (for example 2019).
rem @param %2 Configuration (debug or release).
rem @param %3 Platform (x86 or amd64).

rem Current directory of Visual Studio Code workspace:
set currentDir=%CD%

echo Setting up Visual C/C++ environment...
set vspath=%programfiles(x86)%\Microsoft Visual Studio\%1\Professional\Common7\Tools
rem set vspath=%programfiles(x86)%\Microsoft Visual Studio\%1\Enterprise\Common7\Tools
cd /d %vspath%
rem Use CALL to prevent this script termination after VsDevCmd.bat finishes.
CALL VsDevCmd.bat -arch=%3
echo.

rem Prepare variables:
rem https://renenyffenegger.ch/notes/Windows/development/Visual-Studio/environment-variables/index
set vctools=%VCToolsInstallDir%lib\%VSCMD_ARG_TGT_ARCH%
set um=%WindowsSdkDir%lib\%UCRTVersion%\um\%VSCMD_ARG_TGT_ARCH%
set ucrt=%WindowsSdkDir%lib\%UCRTVersion%\ucrt\%VSCMD_ARG_TGT_ARCH%

echo Cleaning intermediate files...
cd /d %currentDir%\project\
make clean CONFIGURATION=%2 PLATFORM=%3
echo.

echo Building...
cd /d %currentDir%\project\
make all CONFIGURATION=%2 PLATFORM=%3 TARGET_ENTRY=main LIBRARY_PATH='%vctools%:%um%:%ucrt%' -C %currentDir%\project --no-print-directory
echo.

rem echo Copying binaries to output folder...
rem cd %currentDir%
rem mkdir bin\%1
rem Copying script example: for /r %%i in (*.dll) do xcopy "%%i" "%currentDir%\bin\%1\"
rem Manual copying:
rem xcopy project\example.dll bin\%1\

rem End of vs.bat file.
