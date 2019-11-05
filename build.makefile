# Tiny build makefile.


# Rule struct:
# target: prerequisites
# 	recipe


# Define these macroses before include makefile:
#	BUILD_PATH - relative path to the root directory of the intermediate data.
#	BUILD_OUTPUT_PATH - path with executables and other output files.


#	BUILD_TARGET_NAME - name of the build target. Used to name intermediate directory and binary file.


#	SRC_TARGET_NAME - name of the project.
#	SRC_TARGET_TYPE - type of output binary file.
#	SRC_PATHS - all paths that contains sources for assembling.
#	SRC_INCLUDE_PATHS - paths with additional headers.
#	SRC_LIB_DEPENDENCIES - static library names used in build.
#	SRC_PCH_C_HEADER - C header relative path for PCH.
#	SRC_PCH_C_SOURCE - relative path of the C source file to compile as PCH.
#	SRC_PCH_CPP_HEADER - CPP header relative path for PCH.
#	SRC_PCH_CPP_SOURCE - relative path of the CPP source file to compile as PCH.
#	SRC_ENTRY - entry point name for executable binaries.


# Output macroses:
#	BUILD_INTERMEDIATE_PATH - path to the temporary build files.


#	SRC_TARGET - output binary file name with extension.
#	SRC_OUTPUT_TARGET_PREFIX - $(SRC_OUTPUT_TARGET) without extension.
#	SRC_OUTPUT_TARGET - full path with target binary file with extension.


# Default target:
.DEFAULT_GOAL = all


# Disable implicit rules to speedup build:
# TODO: Crutches.
include $(BUILD_PATH)../../suffixes.makefile


# Custom definitions:
#	SRC_ARCHITECTURE - supported architectures:
#		generic - unknown architecture.
#		arm
#		x86
#		amd64
#	SRC_PLATFORM - additional architecture features:
#		generic - default general platform.
SRC_ARCHITECTURE = generic
SRC_PLATFORM = generic


# Parse make arguments:
#	DEBUG - build configuration (SRC_CONFIGURATION):
#		debug
#		release
ifeq ($(DEBUG),1)
	SRC_CONFIGURATION = debug
else
	SRC_CONFIGURATION = release
endif


# Windows family:
ifeq ($(OS),Windows_NT)
	# File targets:
	#	SRC_EXE_EXT - executable file extension.
	#	SRC_OBJ_EXT - object file extension.
	#	SRC_DLL_EXT - dynamic link library extension.
	#	SRC_LIB_EXT - static library extension.
	#	SRC_PCH_EXT - precompiled header file extension.
	#	SRC_ASM_EXT - assembler listing file extension.
	#	SRC_BIN_EXT - unknown binary file extension.
	SRC_EXE_EXT = .exe
	SRC_OBJ_EXT = .obj
	SRC_DLL_EXT = .dll
	SRC_LIB_EXT = .lib
	SRC_PCH_EXT = .pch
	SRC_ASM_EXT = .asm
	SRC_BIN_EXT = .bin
	# Check architecture:
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		SRC_ARCHITECTURE = amd64
	else ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		SRC_ARCHITECTURE = amd64
	else ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		SRC_ARCHITECTURE = x86
	endif
	# Check operating system name:
	#	windows
	#	linux
	#	osx - modern version of Mac OS.
	#	unix
	SRC_OS = windows
	# Default compiler alias:
	#	msc - Microsoft cl compiler.
	#	gcc - GNU Compiler Collection.
	SRC_CC = msc

# Not Windows operating system:
else
	# File targets:
	SRC_EXE_EXT =
	SRC_OBJ_EXT = .o
	SRC_DLL_EXT = .so
	SRC_LIB_EXT = .a
	SRC_PCH_EXT = .gch
	SRC_ASM_EXT = .s
	SRC_BIN_EXT = .bin
	# Check architecture:
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		SRC_ARCHITECTURE = amd64
	else ifneq ($(filter %86, $(UNAME_P)),)
		SRC_ARCHITECTURE = x86
	else ifneq ($(filter arm%,$(UNAME_P)),)
		SRC_ARCHITECTURE = arm
	endif
	# Check operating system name:
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		SRC_OS = linux
	else ifeq ($(UNAME_S),Darwin)
		SRC_OS = osx
	else
		SRC_OS = unix
	endif
	# Default compiler alias:
	SRC_CC = gcc

endif


# Build path prefix for macroses:
BUILD_INTERMEDIATE_PATH_PREFIX = $(BUILD_PATH)$(SRC_ARCHITECTURE)-$(SRC_OS)-$(SRC_CC)-$(SRC_CONFIGURATION)-
# Full build path for temporary files:
BUILD_INTERMEDIATE_PATH = $(BUILD_INTERMEDIATE_PATH_PREFIX)$(SRC_TARGET_NAME)/
# Solution output path:
#SRC_OUTPUT_PATH = $(BUILD_PATH)bin/


# Determine output target:
ifeq ($(SRC_TARGET_TYPE),exec)
	SRC_TARGET = $(SRC_TARGET_NAME)$(SRC_EXE_EXT)
	LFLAGS = $(SRC_LD_EXEC_FLAGS)
else ifeq ($(SRC_TARGET_TYPE),static)
	SRC_TARGET = $(SRC_TARGET_NAME)$(SRC_LIB_EXT)
	ARFLAGS = $(SRC_LD_STATIC_FLAGS)
else ifeq ($(SRC_TARGET_TYPE),dynamic)
	SRC_TARGET = $(SRC_TARGET_NAME)$(SRC_DLL_EXT)
	LFLAGS = $(SRC_LD_SHARED_FLAGS)
else ifeq ($(SRC_TARGET_TYPE),shared)
	SRC_TARGET = $(SRC_TARGET_NAME)$(SRC_DLL_EXT)
	LFLAGS = $(SRC_LD_SHARED_FLAGS)
else
	SRC_TARGET = $(SRC_TARGET_NAME)$(SRC_BIN_EXT)
	LFLAGS = $(SRC_LD_EXEC_FLAGS)
endif
SRC_OUTPUT_TARGET_PREFIX = $(BUILD_INTERMEDIATE_PATH)$(SRC_TARGET_NAME)
SRC_OUTPUT_TARGET = $(BUILD_INTERMEDIATE_PATH)$(SRC_TARGET)


# Prepare C precompiled header variables:
ifneq ($(SRC_PCH_C_SOURCE),)
SRC_PCH_C_OBJ := $(BUILD_INTERMEDIATE_PATH)$(basename $(SRC_PCH_C_SOURCE))$(SRC_OBJ_EXT)
SRC_PCH_C_PREREQUISITE = $(BUILD_INTERMEDIATE_PATH)$(basename $(SRC_PCH_C_SOURCE))$(SRC_PCH_EXT)
SRC_PCH_C_USE_MACROS := $(SRC_PCH_C_USE_FLAGS)
endif

# Prepare CPP precompiled header variables:
ifneq ($(SRC_PCH_CPP_SOURCE),)
SRC_PCH_CPP_OBJ := $(BUILD_INTERMEDIATE_PATH)$(basename $(SRC_PCH_CPP_SOURCE))$(SRC_OBJ_EXT)
SRC_PCH_CPP_PREREQUISITE = $(BUILD_INTERMEDIATE_PATH)$(basename $(SRC_PCH_CPP_SOURCE))$(SRC_PCH_EXT)
SRC_PCH_CPP_USE_MACROS := $(SRC_PCH_CPP_USE_FLAGS)
endif


# Setup compilers:
# Microsoft C/C++ compiler:
ifeq ($(SRC_CC),msc)
	# Used standard definitions:
	#	CC - program for compiling C sources.
	#	AR - archive-maintaining program.
	#	LD - program for objects linking.
	CC := cl
	LD := link
	AR := lib
	# Include paths (initially was $(SRC_PATHS), but it's redundantly):
	SRC_INCLUDE_FLAGS = $(addsuffix ",$(addprefix /I",$(SRC_INCLUDE_PATHS)))
	SRC_LD_LIB_FLAGS = $(addsuffix $(SRC_LIB_EXT)",$(addprefix ",$(SRC_LIB_DEPENDENCIES)))
	SRC_LD_LIB_PATHS = $(addsuffix ",$(addprefix /LIBPATH:"$(BUILD_INTERMEDIATE_PATH_PREFIX),$(SRC_LIB_DEPENDENCIES)))
	SRC_LD_LIB_DEBUG_FLAGS = $(SRC_LD_LIB_PATHS) $(SRC_LD_LIB_FLAGS) "ucrtd.lib" "vcruntimed.lib" "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib"
	SRC_LD_LIB_RELEASE_FLAGS = $(SRC_LD_LIB_PATHS) $(SRC_LD_LIB_FLAGS) "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib"
	# Configuration-dependent compiler flags:
	#	CFLAGS - default extra flags to give to the C compiler.
	#	CPPFLAGS - default c++ compiler flags.
	#	LFLAGS - default linker flags.
	#	ARFLAGS - object archiving flags.
	SRC_LD_FLAGS := /OUT:"$(SRC_OUTPUT_TARGET)" /ERRORREPORT:PROMPT /NOLOGO /SUBSYSTEM:WINDOWS
	ifeq ($(SRC_CONFIGURATION),debug)
		CFLAGS := /c $(SRC_INCLUDE_FLAGS) /GS /W3 /Zc:wchar_t /ZI /Od /Fd"$(BUILD_INTERMEDIATE_PATH)vc141.pdb" /Zc:inline /fp:precise /D "_DEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /errorReport:prompt /WX- /Zc:forScope /RTC1 /Gd /Oy- /MDd /EHsc /nologo /diagnostics:classic
		CPPFLAGS := $(CFLAGS)
		SRC_LD_FLAGS := $(SRC_LD_FLAGS)
		SRC_LD_EXEC_FLAGS := $(SRC_LD_LIB_DEBUG_FLAGS) /INCREMENTAL /DEBUG:FASTLINK
	else
		CFLAGS := /c $(SRC_INCLUDE_FLAGS) /GS- /GL /W3 /Gy /Zc:wchar_t /Zi /O2 /Fd"$(BUILD_INTERMEDIATE_PATH)vc141.pdb" /Zc:inline /fp:precise /D "NDEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /errorReport:prompt /WX- /Zc:forScope /Gd /Oy- /Oi /MD /EHsc /nologo /diagnostics:classic
		CPPFLAGS := $(CFLAGS)
		SRC_LD_FLAGS := $(SRC_LD_FLAGS) /LTCG:incremental /NODEFAULTLIB
		SRC_LD_EXEC_FLAGS := $(SRC_LD_LIB_RELEASE_FLAGS) /INCREMENTAL:NO /OPT:REF /SAFESEH:NO /OPT:ICF
	endif
	# Architecture-dependent compiler flags:
	ifeq ($(SRC_ARCHITECTURE),x86)
		CFLAGS := $(CFLAGS)
		CPPFLAGS := $(CPPFLAGS)
		SRC_LD_FLAGS := $(SRC_LD_FLAGS) /MACHINE:X86
	else ifeq ($(SRC_ARCHITECTURE),amd64)
		CFLAGS := $(CFLAGS)
		CPPFLAGS := $(CPPFLAGS)
		SRC_LD_FLAGS := $(SRC_LD_FLAGS) /MACHINE:X64
		# Special for AMD64 release:
		ifeq ($(SRC_CONFIGURATION),release)
			SRC_LD_EXEC_FLAGS := $(SRC_LD_EXEC_FLAGS) /ALIGN:16 /DRIVER
		endif
	endif
	# Target type specific flags:
	SRC_LD_EXEC_FLAGS := $(SRC_LD_FLAGS) $(SRC_LD_EXEC_FLAGS) /MANIFEST:NO /NXCOMPAT /PDB:"$(BUILD_INTERMEDIATE_PATH)src.pdb" /DYNAMICBASE /ENTRY:"$(SRC_ENTRY)" /MERGE:".rdata=.text" /TLBID:1
	SRC_LD_STATIC_FLAGS := $(SRC_LD_FLAGS)
	# Platform dependent macroses:
	# HACK: Triple slash is used instead of double, because shell escapes characters (in not Cygwin windows environment).
	#SRC_DEPENDENCIES_RECIPE_ORIGINAL = $(CC) $(SRC_INCLUDE_FLAGS) /E /showIncludes $< 2> $@.$$$$ > /dev/null; sed -n 's,^Note: including file: *\(.*\),$*.obj	$*.d:\1,gp' < $@.$$$$ | sed 's,\\\,/,g;s, ,\\\ ,gp' > $@; rm -f $@.$$$$
	SRC_DEPENDENCIES_RECIPE = $(CC) $(SRC_INCLUDE_FLAGS) /E /showIncludes $< 2> $@.$$$$ > /dev/null; sed -n 's,^Note: including file: *\(.*\),$(BUILD_INTERMEDIATE_PATH)$*.obj	$(BUILD_INTERMEDIATE_PATH)$*.d:\1,gp' < $@.$$$$ | sed 's,\\,/,g;s, ,\\ ,gp' > $@; rm -f $@.$$$$
	# Additional defines:
	SRC_PCH_C_USE_FLAGS = /Yu"$(SRC_PCH_C_HEADER)" /Fp"$(SRC_PCH_C_PREREQUISITE)"
	SRC_PCH_CPP_USE_FLAGS = /Yu"$(SRC_PCH_CPP_HEADER)" /Fp"$(SRC_PCH_CPP_PREREQUISITE)"
	SRC_CC_ASM_FLAG = /Fa"$(basename $@)$(SRC_ASM_EXT)"
	# Precompiled header macroses:
	SRC_PCH_CXX_MACROS = /Yc /Fp"$@" /Fo"$(basename $@)$(SRC_OBJ_EXT)" "$<"
	SRC_PCH_CXX_OBJ_MACROS = /Yc /Fp"$(basename $@)$(SRC_PCH_EXT)" /Fo"$@" $(SRC_CC_ASM_FLAG) "$<"
	# Common C/C++ compiler macroses:
	SRC_CC_C_MACROS = $(SRC_PCH_C_USE_MACROS) /Fo"$@" $(SRC_CC_ASM_FLAG) "$<"
	SRC_CC_CPP_MACROS = $(SRC_PCH_CPP_USE_MACROS) /Fo"$@" $(SRC_CC_ASM_FLAG) "$<"

# GNU Compiler Collection:
else ifeq ($(SRC_CC),gcc)
	# Used standard definitions:
	CC = gcc
	LD := gcc
	AR := ar
	# Include paths:
	SRC_INCLUDE_FLAGS = $(addsuffix ",$(addprefix -I",$(SRC_INCLUDE_PATHS)))
	SRC_LD_LIB_FLAGS = $(addprefix -l,$(SRC_LIB_DEPENDENCIES))
	SRC_LD_LIB_PATHS = $(addprefix -L$(BUILD_INTERMEDIATE_PATH_PREFIX),$(SRC_LIB_DEPENDENCIES))
	SRC_LD_LIB_DEBUG_FLAGS = $(SRC_LD_LIB_PATHS) $(SRC_LD_LIB_FLAGS) -lpthread
	SRC_LD_LIB_RELEASE_FLAGS = $(SRC_LD_LIB_PATHS) $(SRC_LD_LIB_FLAGS) -lpthread
	# Configuration-dependent compiler flags:
	SRC_LD_FLAGS := -o "$(SRC_OUTPUT_TARGET)"
	ifeq ($(SRC_CONFIGURATION),debug)
		CFLAGS := -c $(SRC_INCLUDE_FLAGS)
		CPPFLAGS := $(CFLAGS)
		SRC_LD_FLAGS := $(SRC_LD_FLAGS)
		SRC_LD_EXEC_FLAGS := $(SRC_LD_LIB_DEBUG_FLAGS)
	else
		CFLAGS := -c $(SRC_INCLUDE_FLAGS)
		CPPFLAGS := $(CFLAGS)
		SRC_LD_FLAGS := $(SRC_LD_FLAGS)
		SRC_LD_EXEC_FLAGS := $(SRC_LD_LIB_RELEASE_FLAGS)
	endif
	# Architecture-dependent compiler flags:
	ifeq ($(SRC_ARCHITECTURE),x86)
		CFLAGS := $(CFLAGS)
		CPPFLAGS := $(CPPFLAGS)
		SRC_LD_FLAGS := $(SRC_LD_FLAGS)
	else ifeq ($(SRC_ARCHITECTURE),amd64)
		CFLAGS := $(CFLAGS)
		CPPFLAGS := $(CPPFLAGS)
		SRC_LD_FLAGS := $(SRC_LD_FLAGS)
	endif
	# Target type specific flags:
	SRC_LD_EXEC_FLAGS := $(SRC_LD_FLAGS) $(SRC_LD_EXEC_FLAGS) -e $(SRC_ENTRY)
	SRC_LD_STATIC_FLAGS := rsv "$(SRC_OUTPUT_TARGET)"
	# Platform dependent macroses:
	SRC_DEPENDENCIES_RECIPE = $(CC) $(SRC_INCLUDE_FLAGS) -M -c $< > $@.$$$$; sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; rm -f $@.$$$$
	# Additional defines:
	SRC_PCH_C_USE_FLAGS = -include "$(SRC_PCH_C_HEADER)"
	SRC_PCH_CPP_USE_FLAGS = -include "$(SRC_PCH_CPP_HEADER)"
	SRC_CC_C_ASM_MACROS = $(CC) $(CFLAGS) -S -o "$(basename $@)$(SRC_ASM_EXT)" "$<"
	SRC_CC_CPP_ASM_MACROS = $(CC) $(CPPFLAGS) -S -o "$(basename $@)$(SRC_ASM_EXT)" "$<"
	# Precompiled header flags macroses:
	SRC_PCH_CXX_MACROS = "$<" -o "$@"
	SRC_PCH_CXX_OBJ_MACROS = "$<" -o "$@"
	# Common C/C++ compiler flags macroses:
	SRC_CC_C_MACROS = "$<" $(SRC_PCH_C_USE_MACROS) -o "$@"
	SRC_CC_CPP_MACROS = "$<" $(SRC_PCH_CPP_USE_MACROS) -o "$@"

endif


# Default targets and prerequisites:
# NOTE: %.obj and %.c patterns can contains subpaths.


# BUILD_PATHS = $(subst ./,,$(wildcard $(addsuffix *.c, $(SRC_PATHS))))


# Determine all source files in project directories:
SRC_C_FILES = $(subst ./,,$(wildcard $(addsuffix *.c, $(SRC_PATHS))))
SRC_CPP_FILES = $(subst ./,,$(wildcard $(addsuffix *.cpp, $(SRC_PATHS))))


# Binary objects pattern target with prefix relative path (%.obj file in intermediate directory):
SRC_OBJS_TARGET = $(BUILD_INTERMEDIATE_PATH)%$(SRC_OBJ_EXT)


# General prerequisites:
SRC_OBJS := $(patsubst %.c,$(SRC_OBJS_TARGET),$(SRC_C_FILES))
SRC_OBJS := $(SRC_OBJS) $(patsubst %.cpp,$(SRC_OBJS_TARGET),$(SRC_CPP_FILES))


# Objects to exclude from regular build:
SRC_OBJS := $(filter-out $(SRC_PCH_C_OBJ) $(SRC_PCH_CPP_OBJ),$(SRC_OBJS))


# Special dependency target to rebuild sources when headers changes (%.d file in intermediate directory):
SRC_DEPENDENCIES_TARGET = $(BUILD_INTERMEDIATE_PATH)%.d

# Dependencies for sources rebuilding after headers changes:
SRC_DEPENDENCIES := $(patsubst %.c,$(SRC_DEPENDENCIES_TARGET),$(SRC_C_FILES))
SRC_DEPENDENCIES := $(SRC_DEPENDENCIES) $(patsubst %.cpp,$(SRC_DEPENDENCIES_TARGET),$(SRC_CPP_FILES))


# Prevent automatical removing some files by make:
.SECONDARY:


# Generate dependencies of source files on header files:
ifneq ($(MAKECMDGOALS),clean)
-include $(SRC_DEPENDENCIES)
endif

# Don't build dependencies in usual builds:
# Use automatic variables without := operator!
SRC_DEPENDENCIES_ECHO =
ifneq ($(MAKECMDGOALS),rebuild)
SRC_DEPENDENCIES_RECIPE = touch -a $@
else
SRC_DEPENDENCIES_ECHO = (echo "Updating $< dependencies...");
endif

# Targets to generate dependencies:
$(SRC_DEPENDENCIES_TARGET): %.c
	@$(SRC_DEPENDENCIES_ECHO)($(SRC_DEPENDENCIES_RECIPE))

$(SRC_DEPENDENCIES_TARGET): %.cpp
	@$(SRC_DEPENDENCIES_ECHO)($(SRC_DEPENDENCIES_RECIPE))


# Rule for C precompiled header:
ifneq ($(SRC_PCH_C_SOURCE),)
$(SRC_PCH_C_PREREQUISITE): $(SRC_PCH_C_SOURCE) $(SRC_PCH_C_HEADER)
	@$(CC) $(CFLAGS) $(SRC_PCH_CXX_MACROS)
	@echo Precompiled C header was created.

$(SRC_PCH_C_OBJ): $(SRC_PCH_C_SOURCE) $(SRC_PCH_C_HEADER) $(SRC_PCH_C_PREREQUISITE)
	@$(CC) $(CFLAGS) $(SRC_PCH_CXX_OBJ_MACROS)
	@$(SRC_CC_C_ASM_MACROS)
	@echo Precompiled C object was created.
endif

# Rule for CPP precompiled header:
ifneq ($(SRC_PCH_CPP_SOURCE),)
$(SRC_PCH_CPP_PREREQUISITE): $(SRC_PCH_CPP_SOURCE) $(SRC_PCH_CPP_HEADER)
	@$(CC) $(CPPFLAGS) $(SRC_PCH_CXX_MACROS)
	@echo Precompiled CPP header was created.

$(SRC_PCH_CPP_OBJ): $(SRC_PCH_CPP_SOURCE) $(SRC_PCH_CPP_HEADER) $(SRC_PCH_CPP_PREREQUISITE)
	@$(CC) $(CPPFLAGS) $(SRC_PCH_CXX_OBJ_MACROS)
	@$(SRC_CC_CPP_ASM_MACROS)
	@echo Precompiled CPP object was created.
endif


# Regular source rules (dependencies are used by rebuild target to rebuild sources after usual build):
$(SRC_OBJS_TARGET): %.c $(SRC_DEPENDENCIES_TARGET) $(SRC_PCH_C_OBJ)
	@$(CC) $(CFLAGS) $(SRC_CC_C_MACROS)
	@$(SRC_CC_C_ASM_MACROS)

$(SRC_OBJS_TARGET): %.cpp $(SRC_DEPENDENCIES_TARGET) $(SRC_PCH_CPP_OBJ)
	@$(CC) $(CPPFLAGS) $(SRC_CC_CPP_MACROS)
	@$(SRC_CC_CPP_ASM_MACROS)


# Static library rule:
$(SRC_OUTPUT_TARGET_PREFIX)$(SRC_LIB_EXT): $(SRC_OBJS) $(SRC_PCH_C_OBJ) $(SRC_PCH_CPP_OBJ)
	@$(AR) $(addprefix ",$(addsuffix ",$^)) $(ARFLAGS)


# Generic linker rules:
SRC_LD_EXTS := $(SRC_EXE_EXT) $(SRC_DLL_EXT)
$(addprefix $(SRC_OUTPUT_TARGET_PREFIX),$(SRC_LD_EXTS)): $(SRC_OBJS) $(SRC_PCH_C_OBJ) $(SRC_PCH_CPP_OBJ)
	@$(LD) $(LFLAGS) $(addprefix ",$(addsuffix ",$^))


# Default rule for unknown binary target type. To extend rule and allow binary extension usage,
# add rule with same target and additional prerequisites:
$(SRC_OUTPUT_TARGET_PREFIX)$(SRC_BIN_EXT):
	$(error Can't assembly binary file of unknown type)


# End of makefile.
