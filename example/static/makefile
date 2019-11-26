# Static library example makefile.

DEBUG := 1

# Prepare some macroses before include.
# Optionally set the paths for Viual Studio IntelliSense.
TARGET_PCH_C_HEADER := Core/globalc.h
TARGET_PCH_C_SOURCE := Core/globalc.c
TARGET_PCH_CPP_HEADER := Core/globalcpp.h
TARGET_PCH_CPP_SOURCE := Core/globalcpp.cpp

include ../../target.makefile # Global makefile with common functional.

#$(info DEBUG = $(TARGET_INTERMEDIATE_PATH)static$(LIB))

# Default phony target of copying builded files to output directory:
.PHONY: all
all: $(TARGET_OUTPUT_PATH)static$(LIB)
	@echo "Static library done." >&2

# Rebuild target (build dependencies):
.PHONY: rebuild
rebuild: all

# Cleaning target:
.PHONY: clean
clean:
	@cd $(TARGET_OUTPUT_PATH) && $(RM) * || true
	@cd $(TARGET_INTERMEDIATE_PATH) && $(RM) * || true


# End of makefile.
# Конец файла сборки.
