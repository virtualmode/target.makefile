# Executable example makefile.

DEBUG := 1

# Prepare some macroses before include.
# Optionally set the paths for Viual Studio IntelliSense.
TARGET_INCLUDE_PATHS := ./ ../static/
TARGET_LIB_PATHS := ../static/bin/$(CONFIGURATION)/
TARGET_LIB_NAMES := static
TARGET_PCH_C_HEADER := globalc.h
TARGET_PCH_C_SOURCE := globalc.c
TARGET_PCH_CPP_HEADER := globalcpp.h
TARGET_PCH_CPP_SOURCE := globalcpp.cpp
TARGET_ENTRY := main

include ../../target.makefile # Global makefile with common functional.

# Default phony target of copying builded files to output directory:
.PHONY: all
all: $(TARGET_OUTPUT_PATH)executable
	@echo "Executable done." >&2

#	@cp "$?" "$(BUILD_OUTPUT_PATH)"

# Cleaning target:
.PHONY: clean
clean:
	@cd $(TARGET_OUTPUT_PATH) && $(RM) * || true
	@cd $(TARGET_INTERMEDIATE_PATH) && $(RM) * || true


# End of makefile.
# Конец файла сборки.
