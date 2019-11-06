# Makefile for the virtual machines system assembling.

# Default target:
# TODO: Только для отладки.
#.DEFAULT_GOAL = all

#override CC = mytest
#CC = test3

# Можно выполнить @echo $(ex1):
#ex1 := $(shell link)

DEBUG := 1

include include/target.makefile # Global makefile with common functional.

#AR := ar
#AS := ml
#CC := cl
#CXX := gcc
#LD := link



# $(eval RESULT := $(call UPPERCASE,$(CASE_TABLE),$(TEXT)))
#$(eval $(call CheckTool,001,$(CC_VERSION),CC_PREFIX) $(call CheckTool,005,$(CC_VERSION),CC_PREFIX) $(call CheckTool,010,$(CC_VERSION),CC_PREFIX))
#CC_PREFIX := $(basename $(notdir $(CC)))$(CC_PREFIX)
#$(eval TEST:=$(call UPPERCASE,$(CASE_TABLE),$(CC_PREFIX)))

#$(eval CC_PREFIX := $(call CHECK_TOOL,$(CC),c2l,030 008 002) $(call CHECK_TOOL,$(CC),cl,020 005 001))
#CC_PREFIX := $(call CHECK_TOOL,CC,c2l,030 008 002)$(call CHECK_TOOL,CC,cl,020 005 001)



# 1) определяется или устанавливается название утилиты (+путь опционально). SetTool
# 2) определяется её версия.
# 3) в зависимости от имени утилиты, цепочкой вычисляется версия флагов утилиты для полученной версии.
# 4) комбинируется префикс.

# Перенаправление ввода:
# man bash, раздел pipelines.
# Одинарный > перенаправляет стандартный вывод в файл, перезаписывая его.
# Двойной дописывает в конец.
# 2> перенаправляет стандартный поток ошибок.

usage:
	@echo " " >&2
	@echo "First version of makefile." >&2
	@echo " " >&2
	@echo "Usage:" >&2
	@echo "	make clean   # Remove all assembling results." >&2
	@echo " " >&2
	@echo " " >&2
	@echo $(CC)
	$(info TARGETS = $@)

bios:
	@echo "BIOS or its UEFI version is not implemented yet. Used only for debug." >&2
	cd bios && $(MAKE) $@ # Here you can write target also.

loader:
	cd loader && $(MAKE) $@

kernel:
	@echo "Kernel is not implemented yet." >&2

#.PHONY: all
all: kernel loader bios
	@echo "Test!"

# Rebuild target (build dependencies):
.PHONY: rebuild # .PHONY цель 
rebuild: all

# Change directory -C and run clean for each target (like cd ./target && $(MAKE) $@):
.PHONY: clean
clean:
	$(MAKE) $(MAKECMDGOALS) -C kernel
	$(MAKE) $(MAKECMDGOALS) -C loader
	$(MAKE) $(MAKECMDGOALS) -C bios

# TODO: Надо разобраться, можно ли получить расширение:
$(info TARGETS = $(MAKECMDGOALS))


## Makefile example dor debug purposes.
#cl:
#	@echo "Making cl"
#	cd cl && $(MAKE) # Here you can write target also.
#clib:
#	@echo "Making clib"
#	cd clib && $(MAKE)
#.PHONY: all
#all: cl clib
#	@echo "Making bios all"
#.PHONY: clean
#clean:
#	cd cl && $(MAKE) $@
#	cd clib && $(MAKE) $@
# End of makefile.


# Конец файла сборки.
