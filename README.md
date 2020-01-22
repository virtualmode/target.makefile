# Tiny cross-platform target.makefile for [GNU Make](https://www.gnu.org/software/make/)
Extensible tiny makefile is used to simplify assembling tasks of different binary files.

## Features
* Supports Windows and POSIX operation systems.
* Supports GCC, Microsoft C/C++ toolchain and MASM out of the box.
* Contains cross-platform macroses for basic file system operations.
* Ability to compile multiple binary files with different types at same time.
* Automatically finds and compiles all supported source files within the selected directories.
* Generates C/C++ dependecies and recompiles only changed code.
* Includes debug and release configurations suitable for GDB and Visual Studio Debugger.

## Limitations
* Requires [GNU make](https://www.gnu.org/software/make/), sed and grep.

## Usage
Add *target.makefile* to your solution directory or subdirectory as you wish and create *makefile* with code like this:
```make
include target.makefile # Global makefile with common functional.

# Default phony target of copying builded files to output directory:
.PHONY: all
all: $(TARGET_OUTPUT_PATH)static$(LIB)
	@echo "Static library done." >&2

# Cleaning target:
.PHONY: clean
clean:
	@cd $(TARGET_OUTPUT_PATH) && $(RM) * || true
	@cd $(TARGET_INTERMEDIATE_PATH) && $(RM) * || true
```

## License
```
MIT License

Copyright (c) 2019 virtualmode

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
