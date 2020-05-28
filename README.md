# Extensible cross-platform tiny makefile for [GNU Make](https://www.gnu.org/software/make/)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/virtualmode/target.makefile/blob/master/LICENSE)  
Tiny target.makefile is used to simplify assembling tasks of different binary files.

## Features
* Supports Windows and POSIX operating systems.
* Supports GCC, Microsoft C/C++ toolchain and MASM out of the box.
* Contains cross-platform macroses for basic file system operations.
* Compiles multiple binary files with different types at same time by one makefile.
* Automatically finds and compiles all supported source files within the selected directories.
* Generates C/C++ dependecies and recompiles only changed code.
* Includes debug and release configurations suitable for GDB and Visual Studio Debugger.

## Limitations
* Requires [GNU make](https://www.gnu.org/software/make/), sed and grep.

## Environment
Before use *target.makefile* you must prepare build environment any way you know. For example, if you prefer Visual Studio with C/C++ compilers, run *vs.bat* from *example* folder:
```bat
@echo off

rem Prepare environment to use target.makefile in Windows with Visual Studio C/C++ toolchain.
rem @param %1 Visual Studio version (for example 2019).
rem @param %2 Configuration (debug or release).
rem @param %3 Platform (x86 or amd64).

rem Current directory of Visual Studio Code workspace:
set currentDir=%CD%

echo Setting up Visual C/C++ environment...
set vspath=%programfiles(x86)%\Microsoft Visual Studio\%1\Professional\Common7\Tools
cd /d %vspath%
rem Use CALL to prevent this script termination after VsDevCmd.bat finishes.
CALL VsDevCmd.bat -arch=%3
echo.

rem Prepare variables:
set vctools=%VCToolsInstallDir%lib\%VSCMD_ARG_TGT_ARCH%
set um=%WindowsSdkDir%lib\%UCRTVersion%\um\%VSCMD_ARG_TGT_ARCH%
set ucrt=%WindowsSdkDir%lib\%UCRTVersion%\ucrt\%VSCMD_ARG_TGT_ARCH%

echo Cleaning intermediate files...
cd /d %currentDir%\project\
make clean CONFIGURATION=%2 PLATFORM=%3
echo.

echo Building...
cd /d %currentDir%\project\
make all CONFIGURATION=%2 PLATFORM=%3 TARGET_ENTRY=main LIBRARY_PATH='%vctools%:%um%:%ucrt%' -C %currentDir%\project
echo.
```
Then follow instructions below.

## Usage
Add *target.makefile* to your solution directory or subdirectory as you wish and create *makefile* with code like this:
```make
include target.makefile # Makefile with common functional.

# Default phony target to create static library.
# Prerequisite extension is used to determine build chain:
.PHONY: all
all: $(OUTPUT_PATH)example$(LIB)
	@echo "Static library done." >&2

.PHONY: clean
clean:
	@cd $(OUTPUT_PATH) && $(RM) * || true
	@cd $(INTERMEDIATE_PATH) && $(RM) * || true
```
Then run `make all` to build static library within your current environment.

### Example with multiple standalone projects and its own makefiles
```make
include ../target.makefile

# Default target to use make without arguments:
.DEFAULT_GOAL = all

usage:
	@echo " " >&2
	@echo "Solution example." >&2
	@echo " " >&2
	@echo "Usage:" >&2
	@echo "	make all       # Builds all example projects." >&2
	@echo "	make rebuild   # Rebuilds all targets." >&2
	@echo "	make clean     # Removes all output and intermediate results." >&2
	@echo "	make install   # Installation target stub." >&2
	@echo "	make uninstall # Uninstallation stub." >&2
	@echo " " >&2

.PHONY: binary
binary:
	@echo "Building binary example..." >&2
	@cd binary && $(MAKE) all # Here you can write current target also by specifying $@ after $(MAKE).

.PHONY: executable
executable:
	@echo "Building executable example..." >&2
	@cd executable && $(MAKE) all

.PHONY: static
static:
	@echo "Building static library example..." >&2
	@cd static && $(MAKE) all

.PHONY: all
all: binary executable static
	@echo "Solution ready." >&2

.PHONY: rebuild
rebuild: all

# Changing directory with -C flag and running clean for each target are equal to "cd ./target && $(MAKE) $@".
# Additional "2> /dev/null || true" redirection and true flag can be used for hiding and ignoring return errors.
# But "| true" pipe will return result if the first command success.
.PHONY: clean
clean:
	$(MAKE) $(MAKECMDGOALS) -C binary
	$(MAKE) $(MAKECMDGOALS) -C executable
	$(MAKE) $(MAKECMDGOALS) -C static

# Installation target stub:
.PHONY: install
install:
	@echo "Installation target isn't implemented." >&2

# Uninstall target stub:
.PHONY: uninstall
uninstall:
	@echo "Uninstall target isn't implemented." >&2
```

### Example with one makefile for several projects
This build mode is still experimental feature with some limitations.
```make
# Enable debug information:
DEBUG := 1
# Entry point for executable target:
TARGET_ENTRY := main
# External static libraries:
LIBRARY_NAME := static

# Additional include and library paths:
override INCLUDE_PATH := $(INCLUDE_PATH):static/:executable/
override LIBRARY_PATH := $(LIBRARY_PATH):static/bin/$(CONFIGURATION)/

include ../target.makefile

.PHONY: executable
executable: static $(OUTPUT_PATH)executable$(EXE)
	@echo "Executable done." >&2

.PHONY: static
static: $(OUTPUT_PATH)static$(LIB)
	@echo "Static library done." >&2

.PHONY: all
all: executable
	@echo "Example ready." >&2

.PHONY: clean
clean:
	@cd $(OUTPUT_PATH) && $(RM) * || true
	@cd $(INTERMEDIATE_PATH) && $(RM) * || true
```
Run `make all CONFIGURATION=debug PLATFORM=amd64 INCLUDE_PATH="$(IncludePath)" LIBRARY_PATH="$(VC_LibraryPath_x64);$(WindowsSDK_LibraryPath_x64)"`, where *$* must be changed on your real environment paths.

## License
```
MIT License

Copyright (c) 2019 virtualmode <https://github.com/virtualmode>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
