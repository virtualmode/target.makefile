# Binary example makefile.


DEBUG := 1

# Prepare some macroses before include.
# Optionally set the paths for Viual Studio IntelliSense.
# AS := c:/bin/vc152/ml.exe
TARGET_ENTRY := main

include ../../target.makefile

.PHONY: all
all: $(TARGET_OUTPUT_PATH)binary$(COM)
	@echo "Binary done." >&2

# Cleaning target:
.PHONY: clean
clean:
	@cd $(TARGET_OUTPUT_PATH) && $(RM) * || true
	@cd $(TARGET_INTERMEDIATE_PATH) && $(RM) * || true


# End of makefile.
# Конец файла сборки.
