# Binary example makefile.

DEBUG := 1

# Prepare some macroses before include.
# Optionally set the paths for Viual Studio IntelliSense.
TARGET_ENTRY := main

include ../../target.makefile

.PHONY: all
all: $(OUTPUT_PATH)binary$(COM)
	@echo "Binary done." >&2

.PHONY: rebuild
rebuild: all

.PHONY: clean
clean:
	@cd $(OUTPUT_PATH) && $(RM) * || true
	@cd $(INTERMEDIATE_PATH) && $(RM) * || true

# End of makefile.
# Конец файла сборки.
