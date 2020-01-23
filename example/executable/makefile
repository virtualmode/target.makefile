# Executable example makefile.

DEBUG := 1

# Prepare some macroses before include.
# Optionally set the paths for Viual Studio IntelliSense.
override INCLUDE_PATH := $(INCLUDE_PATH):../static/
override LIBRARY_PATH := $(LIBRARY_PATH):../static/bin/$(CONFIGURATION)/
LIBRARY_NAME := static

TARGET_ENTRY := main
TARGET_PCH_C_HEADER := globalc.h
TARGET_PCH_C_SOURCE := globalc.c
TARGET_PCH_CPP_HEADER := globalcpp.h
TARGET_PCH_CPP_SOURCE := globalcpp.cpp

include ../../target.makefile # Global makefile with common functional.

# Default phony target of copying builded files to output directory:
.PHONY: all
all: $(OUTPUT_PATH)executable
	@echo "Executable done." >&2

# Rebuild target (build dependencies):
.PHONY: rebuild
rebuild: all

# Cleaning target:
.PHONY: clean
clean:
	@cd $(OUTPUT_PATH) && $(RM) * || true
	@cd $(INTERMEDIATE_PATH) && $(RM) * || true


# End of makefile.
# Конец файла сборки.
