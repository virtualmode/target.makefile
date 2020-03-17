# Static library example makefile.

DEBUG := 1

# Default target:
.DEFAULT_GOAL = all

# Prepare some macroses before include.
# Optionally set the paths for Viual Studio IntelliSense.
TARGET_PCH_C_HEADER := Core/globalc.h
TARGET_PCH_C_SOURCE := Core/globalc.c
TARGET_PCH_CPP_HEADER := Core/globalcpp.h
TARGET_PCH_CPP_SOURCE := Core/globalcpp.cpp

include ../../target.makefile # Global makefile with common functional.

.PHONY: all
all: $(OUTPUT_PATH)static$(LIB)
	@echo "Static library done." >&2

.PHONY: rebuild
rebuild: all

.PHONY: clean
clean:
	@cd $(OUTPUT_PATH) && $(RM) * || true
	@cd $(INTERMEDIATE_PATH) && $(RM) * || true

# End of makefile.
# Конец файла сборки.
