# Binary example makefile.


DEBUG := 1

# Prepare some macroses before include.
# Optionally set the paths for Viual Studio IntelliSense.
# AS := c:/bin/vc152/ml.exe
TARGET_ENTRY := main

include ../../target.makefile

.PHONY: all
all: $(OUTPUT_PATH)binary$(COM)
	@echo "Binary done." >&2

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
