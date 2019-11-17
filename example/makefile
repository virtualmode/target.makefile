# Example of solution makefile.
# Пример файла сборки всего решения.
# Можно не использовать этот проект в Visual Studio, а
# написать отдельные сборочные файлы для каждого из проектов.

# Include target.makefile to use $(RM) macros:
include ../target.makefile

# Набор целей:
usage:
	@echo " " >&2
	@echo "Solution makefile example." >&2
	@echo " " >&2
	@echo "Usage:" >&2
	@echo "	make all       # Builds all example projects." >&2
	@echo "	make rebuild   # Rebuilds all targets." >&2
	@echo "	make clean     # Removes all output and intermediate results." >&2
	@echo " " >&2
	@echo " " >&2

.PHONY: binary
binary:
	@echo "Building binary example..." >&2
	cd binary && $(MAKE) all # Here you can write current target also by specifying $@ after $(MAKE).

.PHONY: executable
executable:
	@echo "Building executable example..." >&2
	cd executable && $(MAKE) all

.PHONY: static
static:
	@echo "Building static library example..." >&2
	cd static && $(MAKE) all

.PHONY: all
all: binary executable static
	@echo "Example ready." >&2

# Rebuild target (build dependencies):
.PHONY: rebuild
rebuild: all

# Change directory -C and run clean for each target (like cd ./target && $(MAKE) $@):
.PHONY: clean
clean:
	$(MAKE) $(MAKECMDGOALS) -C binary
	$(MAKE) $(MAKECMDGOALS) -C executable
	$(MAKE) $(MAKECMDGOALS) -C static
	cd bin && $(RM) "bin/*"

# End of makefile.
# Конец файла сборки.
