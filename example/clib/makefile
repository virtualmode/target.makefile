# Project makefile.

# Prepare some macroses before include:
BUILD_PATH = ../build/
BUILD_OUTPUT_PATH = ../bin/

SRC_TARGET_NAME = clib
SRC_TARGET_TYPE = static
SRC_PATHS = ./ Core/ Threading/
SRC_INCLUDE_PATHS = ./
SRC_PCH_C_HEADER = Core/cglobalc.h
SRC_PCH_C_SOURCE = Core/cglobalc.c
SRC_PCH_CPP_HEADER = Core/cglobalcpp.h
SRC_PCH_CPP_SOURCE = Core/cglobalcpp.cpp
include ../../build.makefile # Global makefile with common functional.

# Project specified macroses:
SRC_BIN_TARGET = $(BUILD_OUTPUT_PATH)$(SRC_TARGET)


# Default phony target of copying builded files to output directory:
.PHONY: all
all: $(SRC_OUTPUT_TARGET)

# Cleaning target:
# NOTE: Additional /dev/null redirection and true flag is used for hiding and ignoring return errors.
.PHONY: clean
clean:
	@rm -f $(addsuffix *,$(addprefix $(BUILD_INTERMEDIATE_PATH),$(SRC_PATHS))) 2> /dev/null || true

# Rebuild target (build dependencies):
.PHONY: rebuild
rebuild: all

# Installation target:
.PHONY: install
install:
	@echo "Installation target isn't implemented."

# Uninstall target:
.PHONY: uninstall
uninstall:
	@echo "Uninstall target isn't implemented."


# End of makefile.
