# Binary example makefile.

TARGET_INTERMEDIATE_PATH := obj/$(CONFIGURATION)/
TARGET_OUTPUT_PATH := bin/$(CONFIGURATION)/

include ../../target.makefile

.PHONY: all
all:
	@echo "Binary done." >&2

# Cleaning target:
.PHONY: clean
clean:
	@cd $(TARGET_OUTPUT_PATH) && $(RM) * | true
	@cd $(TARGET_INTERMEDIATE_PATH) && $(RM) * | true


# End of makefile.
# Конец файла сборки.
