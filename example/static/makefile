# Static library example makefile.

DEBUG := 1

# Prepare some macroses before include:
TARGET_PATHS := Core/ Threading/
TARGET_INTERMEDIATE_PATH := obj/$(CONFIGURATION)/
TARGET_OUTPUT_PATH := bin/$(CONFIGURATION)/
#TARGET_INCLUDE_PATHS :=
#TARGET_LIB_PATHS := $(TARGET_INTERMEDIATE_PATH)
#TARGET_LIB_NAMES := example1 example2 example3

#TARGET_PCH_C_HEADER := Core/cglobalc.h
#TARGET_PCH_C_SOURCE := Core/cglobalc.c
#TARGET_PCH_CPP_HEADER := Core/cglobalcpp.h
#TARGET_PCH_CPP_SOURCE := Core/cglobalcpp.cpp

#TARGET_ENTRY := main

include ../../target.makefile # Global makefile with common functional.


#BUILD_PATH = ../../cl/build/
#BUILD_OUTPUT_PATH = ../../cl/bin/
#SRC_TARGET_NAME = clib
#SRC_TARGET_TYPE = static
#SRC_PATHS = ./ Core/ Threading/
#SRC_INCLUDE_PATHS = ./
#SRC_PCH_C_HEADER = Core/cglobalc.h
#SRC_PCH_C_SOURCE = Core/cglobalc.c
#SRC_PCH_CPP_HEADER = Core/cglobalcpp.h
#SRC_PCH_CPP_SOURCE = Core/cglobalcpp.cpp
# Project specified macroses:
#SRC_BIN_TARGET = $(BUILD_OUTPUT_PATH)$(SRC_TARGET)

#clib$(EXT_LIB): $(TARGET_OBJECTS)
#	$(LD) $(LDFLAGS)

## Prepare some macroses before include:
#BUILD_PATH = ../build/
#BUILD_OUTPUT_PATH = ../bin/

#SRC_TARGET_NAME = clib
#SRC_TARGET_TYPE = static
#SRC_PATHS = ./ Core/ Threading/
#SRC_INCLUDE_PATHS = ./
#SRC_PCH_C_HEADER = Core/cglobalc.h
#SRC_PCH_C_SOURCE = Core/cglobalc.c
#SRC_PCH_CPP_HEADER = Core/cglobalcpp.h
#SRC_PCH_CPP_SOURCE = Core/cglobalcpp.cpp
#include ../../build.makefile # Global makefile with common functional.

## Project specified macroses:
#SRC_BIN_TARGET = $(BUILD_OUTPUT_PATH)$(SRC_TARGET)


## Default phony target of copying builded files to output directory:
#.PHONY: all
#all: $(SRC_OUTPUT_TARGET)
#clean: #@rm -f $(addsuffix *,$(addprefix $(BUILD_INTERMEDIATE_PATH),$(SRC_PATHS))) 2> /dev/null || true

static$(LIB):
	@echo stub static > $(TARGET_INTERMEDIATE_PATH)static$(LIB)

# Default phony target of copying builded files to output directory:
.PHONY: all
all: static$(LIB)
	@echo "Static library done." >&2

# Rebuild target (build dependencies):
.PHONY: rebuild
rebuild: all

# Cleaning target:
.PHONY: clean
clean:
	@cd $(TARGET_OUTPUT_PATH) && $(RM) * | true
	@cd $(TARGET_INTERMEDIATE_PATH) && $(RM) * | true


# End of makefile.
# Конец файла сборки.
