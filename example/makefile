# Example of solution makefile.
# Пример файла сборки решения.

DEBUG := 1

include ../target.makefile # Global makefile with common functional.

usage:
	@echo " " >&2
	@echo "Example project makefile." >&2
	@echo " " >&2
	@echo "Usage:" >&2
	@echo "	make clean   # Remove all assembling results." >&2
	@echo " " >&2
	@echo " " >&2

command.com:
	@echo "Building command example..." >&2
	cd com && $(MAKE) $@ # Here you can write target also.

exec.exe:
	@echo "Building executable example..." >&2
	cd exec && $(MAKE) $@

static.lib:
	@echo "Building static library example..." >&2
	cd static && $(MAKE) $@

#.PHONY: all
all: command.com exec.exe static.lib
	@echo "Building example solution:" >&2

# Rebuild target (build dependencies):
.PHONY: rebuild
rebuild: all

# Change directory -C and run clean for each target (like cd ./target && $(MAKE) $@):
.PHONY: clean
clean:
	$(MAKE) $(MAKECMDGOALS) -C "com"
	$(MAKE) $(MAKECMDGOALS) -C "exec"
	$(MAKE) $(MAKECMDGOALS) -C "static"

# TODO: Надо разобраться, можно ли получить расширение:
$(info TARGETS = $(MAKECMDGOALS))

# End of makefile.
# Конец файла сборки.
