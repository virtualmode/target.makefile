# MIT License
#
# Copyright (c) 2019 virtualmode <https://github.com/virtualmode>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Tiny build makefile.
# Файл сборки исходного кода в исполняемый машинный код.

# Задача данного файла выполнять кросс-компиляцию и компоновку с минимальным количеством зависимостей от внешних инструментов.
# Для использования на некоторых платформах появится необходимость реализовать используемый здесь функционал.


# Сборка происходит путём выполнения цепочек правил, состоящих из рецепта, файлов пререквизитов и цели. Если с момента выполнения
# предыдущей сборки хотя бы один из пререквизитов был изменён, или целевой файл не создан, выполняется рецепт для обновления цели.
# Если цель является специальной .PHONY, а не файлом, то рецепт будет выполняться каждый раз. Результатом рецепта будет файл,
# который также может являться пререквизитом для другого правила:
# .PHONY: all
# target: prerequisites
#	recipe


# Define these macroses before include makefile. If there is no value, it is calculated automatically by default:
#	CONFIGURATION - make argument to setup build configuration (default: release):
#		debug
#		release
#	PLATFORM - preferred platform to build output binary file (default: $(HOST_PLATFORM)):
#		amd64
#		arm
#		x86
#	ARCHITECTURE - processor architecture (optional and empty by default).
#	SYSTEM - operating system specific headers for target (default: $(HOST_SYSTEM)):
#		none - clean architecture code without headers.
#		windows - known operating system.
#		posix - POSIX-compatible operating system.
#	LIBRARY_PATH - paths with static libraries in PATH environment variable format. You can include intermediate path also.
#	LIBRARY_NAME - static library names used in build (optional and empty by default). Adjust to specific compiler.
#	INCLUDE_PATH - paths with additional headers in PATH environment variable format.

#	TARGET_ENTRY - optional variable with entry point name for executable binaries (optional and empty by default).
#	TARGET_PCH_C_HEADER - C header relative path for PCH.
#	TARGET_PCH_C_SOURCE - relative path of the C source file to compile as PCH.
#	TARGET_PCH_CPP_HEADER - CPP header relative path for PCH.
#	TARGET_PCH_CPP_SOURCE - relative path of the CPP source file to compile as PCH.


# You can define this macroses at any time:
#	SOURCE_PATHS - paths that contains sources for assembling.
#	INTERMEDIATE_PATH - target path with intermediate build data.
#	OUTPUT_PATH - output path with target and its resources.


# Automatically initialized macroses that can be used:
#	BIN - unknown binary file extension.
#	COM - simple executable file extension.
#	DEP - depend file extension.
#	DLL - dynamic link library extension.
#	EXE - executable file extension.
#	LIB - static library extension.
#	OBJ - object file extension.
#	PCH - precompiled header file extension.
#	SYS - system file extension.

#	HOST_PLATFORM - current platform (see $(PLATFORM)).
#	HOST_SYSTEM - current operating system (see $(SYSTEM)).

#	AR - archive-maintaining program.
#		ar - Unix archiver.
#		lib - Microsoft library manager.
#	ARFLAGS - object archiving flags.
#	AS - assembler program that converts the assembly language to object code.
#		as - GNU Assembler.
#		ml - MASM.
#	ASFLAGS - assembler flags.
#	CC - C/C++ compiler.
#		cl - Microsoft C/C++ compiler.
#		gcc - GNU Compiler Collection.
#	CFLAGS - flags that are passed to the C/C++ compiler.
#	CXX - name of the C++ compiler (default: g++).
#	CXXFLAGS - flags that are passed to the C++ compiler.
#	LD - program for object linking.
#		gcc - GNU Compiler Collection.
#		link - Microsoft linker.
#	LDFLAGS - common linker flags.
#	EXEFLAGS - extra linker flags for executable files.
#	DLLFLAGS - extra linker flags for dynamic link libraries.
#	RM - command to remove a file (default: rm -rf).
#	CP - file copy command (default: cp -f).


########################################################################################################################
#                                                Compilers configuration                                               #
########################################################################################################################


# Установка общих параметров:
ifdef TARGET_ENTRY
LINK_ENTRY_FLAGS := /ENTRY:$(TARGET_ENTRY)
GCC_ENTRY_FLAGS := -e $(TARGET_ENTRY)
endif


# Наборы инструментов по умолчанию для поддерживаемых платформ:
DEFAULT_TOOLS_WINDOWS := AR ARFLAGS lib AS ASFLAGS ml CC CFLAGS cl CXX CXXFLAGS cl LD LDFLAGS link LD EXEFLAGS link LD DLLFLAGS link
DEFAULT_TOOLS_POSIX := AR ARFLAGS ar AS ASFLAGS as CC CFLAGS gcc CXX CXXFLAGS gcc LD LDFLAGS gcc LD EXEFLAGS gcc LD DLLFLAGS gcc

# Макросы определения версий поддерживаемых утилит.
# AR программы обслуживания (сопровождения) архивов:
AR_VERSION = $(shell $(AR) --version 2>&1 | $(PARSE_MAJOR_VERSION))
AR_VERSIONS = 001
LIB_VERSION = $(shell $(AR) 2>&1 | $(PARSE_MAJOR_VERSION))
LIB_VERSIONS = 001 010
# AS ассемблеры:
AS_VERSION = $(shell $(AS) --version 2>&1 | $(PARSE_MAJOR_VERSION))
AS_VERSIONS = 001
ML_VERSION = $(shell $(AS) 2>&1 | $(PARSE_MAJOR_VERSION))
ML_VERSIONS = 001 010
ML64_VERSION = $(shell $(AS) 2>&1 | $(PARSE_MAJOR_VERSION))
ML64_VERSIONS = 001 010
# CC/CXX компиляторы C/C++:
GCC_VERSION = $(shell $(CC) --version 2>&1 | $(PARSE_MAJOR_VERSION))
GCC_VERSIONS = 001
CL_VERSION = $(shell $(CC) 2>&1 | $(PARSE_MAJOR_VERSION))
CL_VERSIONS = 001 010
# LD компоновщики:
LINK_VERSION = $(shell $(LD) /HELP 2>&1 | $(PARSE_MAJOR_VERSION))
LINK_VERSIONS = 001 010


# Общие флаги пакета компиляторов MSVC:
CL_ASM_FLAGS = /Fa"$(basename $@).asm"
CL_PCH_FLAGS = /Yc /Fp"$@"
CL_PCH_OBJ_FLAGS = /Yc /Fp"$(basename $@)$(PCH)"
CL_PCH_C_USE_FLAGS = /Yu"$(TARGET_PCH_C_HEADER)" /Fp"$(TARGET_PCH_C_PREREQUISITE)"
CL_PCH_CPP_USE_FLAGS = /Yu"$(TARGET_PCH_CPP_HEADER)" /Fp"$(TARGET_PCH_CPP_PREREQUISITE)"
CL_DEPEND_FLAGS = $(CL_INCLUDE_FLAGS) /E /showIncludes $< 2> $@.$$$$ > /dev/null; sed -n 's,^Note: including file: *\(.*\),$(INTERMEDIATE_PATH)$*.obj	$(INTERMEDIATE_PATH)$*.d:\1,gp' < $@.$$$$ | sed 's,$(BS),/,g;s, ,$(BS) ,gp' > $@; rm -f $@.$$$$


# Флаги компиляторов Microsoft Visual Studio 1.XX для сборки и в 16-битном режиме:
# Данные программы проверены, предсказуемы и наиболее оптимизированы в отличие от современных наборов.
ML001_ASFLAGS = /AT /c /Fo "$(basename $@)$(OBJ)" "$<"
ML64001_ASFLAGS = $(ML001_ASFLAGS)

CL001_PCH = $(CL_PCH_FLAGS)
CL001_PCH_OBJ = $(CL_PCH_OBJ_FLAGS)
CL001_PCH_C_USE = $(CL_PCH_C_USE_FLAGS)
CL001_PCH_CPP_USE = $(CL_PCH_CPP_USE_FLAGS)
CL001_DEPEND_RECIPE = $(CC) $(CL_DEPEND_FLAGS)
CL001_CFLAGS = /AT /G2 /Gs /Gx /c /Zl $(CL_INCLUDE_FLAGS) $(CL_ASM_FLAGS) /Fo"$(basename $@)$(OBJ)" "$<"
CL001_CXXFLAGS = $(CL001_CFLAGS)

LIB001_ARFLAGS = /OUT:"$@" $(addprefix ",$(addsuffix ",$^))

LINK001_LDFLAGS = /T /NOD $(addprefix ",$(addsuffix ",$^)) , "$@" , "$(INTERMEDIATE_PATH)$(basename $(notdir $@)).map" ,,,
LINK001_DLLFLAGS = /DLL
LINK001_EXEFLAGS = $(LINK_ENTRY_FLAGS)


# Флаги актуальной версии MSVC для сборки цели.
# Компиляторы Microsoft не поддерживают флаги для компиляции под определённую архитектуру процессора.
# Для сборки необходимо запустить определённый экземпляр компилятора, установив переменную окружения.
ML010_ASFLAGS = /AT /c /Fo "$(basename $@)$(OBJ)" "$<"
ML64010_ASFLAGS = $(ML010_ASFLAGS)

CL010_PCH = $(CL_PCH_FLAGS)
CL010_PCH_OBJ = $(CL_PCH_OBJ_FLAGS)
CL010_PCH_C_USE = $(CL_PCH_C_USE_FLAGS)
CL010_PCH_CPP_USE = $(CL_PCH_CPP_USE_FLAGS)
CL010_DEPEND_RECIPE = $(CC) $(CL_DEPEND_FLAGS)
CL010_CFLAGS = /c $(CL_INCLUDE_FLAGS) /W3 /Zc:wchar_t /Zc:inline /fp:precise /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /errorReport:prompt /WX- /Zc:forScope /Gd /Oy- /EHsc /nologo /diagnostics:classic $(CL_ASM_FLAGS) /Fo"$(basename $@)$(OBJ)" "$<"
CL010_CXXFLAGS = $(CL010_CFLAGS)
CL010_CFLAGS_DEBUG = /GS /ZI /Od /Fd"$(INTERMEDIATE_PATH)vc141.pdb" /D "_DEBUG" /RTC1 /MDd
CL010_CXXFLAGS_DEBUG = $(CL010_CFLAGS_DEBUG)
CL010_CFLAGS_RELEASE = /GS- /GL /Gy /Zi /Gm- /O2 /Fd"$(INTERMEDIATE_PATH)vc141.pdb" /D "NDEBUG" /Oi /MD
CL010_CXXFLAGS_RELEASE = $(CL010_CFLAGS_RELEASE)

LIB010_ARFLAGS = /OUT:"$@" $(addprefix ",$(addsuffix ",$^))

LINK010_LDFLAGS = /ERRORREPORT:PROMPT /NOLOGO /SUBSYSTEM:WINDOWS /OUT:"$@" $(addprefix ",$(addsuffix ",$^))
LINK010_LDFLAGS_DEBUG   = $(LINK_LIB_PATHS_FLAGS) $(LINK_LIB_NAMES_FLAGS) "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" "ucrtd.lib" "vcruntimed.lib" /INCREMENTAL /DEBUG:FASTLINK
LINK010_LDFLAGS_RELEASE = $(LINK_LIB_PATHS_FLAGS) $(LINK_LIB_NAMES_FLAGS) "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" /INCREMENTAL:NO /OPT:REF /SAFESEH:NO /OPT:ICF /LTCG:incremental /NODEFAULTLIB
LINK010_LDFLAGS_X86 = /MACHINE:X86
LINK010_LDFLAGS_AMD64 = /MACHINE:X64
LINK010_DLLFLAGS = /DLL
LINK010_EXEFLAGS = /MANIFEST:NO /NXCOMPAT /PDB:"$(INTERMEDIATE_PATH)src.pdb" /DYNAMICBASE $(LINK_ENTRY_FLAGS) /MERGE:".rdata=.text" /TLBID:1
LINK010_EXEFLAGS_AMD64 = /DRIVER


# Common GCC flags:
# Общие флаги пакета компиляторов GCC:
GCC_PCH_C_USE_FLAGS = -include "$(TARGET_PCH_C_HEADER)"
GCC_PCH_CPP_USE_FLAGS = -include "$(TARGET_PCH_CPP_HEADER)"
GCC_DEPEND_FLAGS = $(GCC_INCLUDE_FLAGS) -M -c $< > $@.$$$$; sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; rm -f $@.$$$$


# GNU Compiler Collection:
AS001_ASFLAGS = -c "$<" -o "$@"

GCC001_PCH = $(GCC_PCH_FLAGS)
GCC001_PCH_OBJ = $(GCC_PCH_OBJ_FLAGS)
GCC001_PCH_C_USE = $(GCC_PCH_C_USE_FLAGS)
GCC001_PCH_CPP_USE = $(GCC_PCH_CPP_USE_FLAGS)
GCC001_DEPEND_RECIPE = $(CC) $(GCC_DEPEND_FLAGS)
GCC001_CC_ASM_RECIPE = $(CC) $(GCC_INCLUDE_FLAGS) -S -o "$(basename $@).s" "$<"
GCC001_CXX_ASM_RECIPE = $(CXX) $(GCC_INCLUDE_FLAGS) -S -o "$(basename $@).s" "$<"
GCC001_CFLAGS = -c $(GCC_INCLUDE_FLAGS) "$<" -o "$@"
GCC001_CXXFLAGS = -c $(GCC_INCLUDE_FLAGS) "$<" -o "$@"

AR001_ARFLAGS = -crs $@ $^

GCC001_LDFLAGS = $(addprefix ",$(addsuffix ",$^)) -lpthread -o $@
GCC001_LDFLAGS_DEBUG = $(GCC_LIB_PATHS_FLAGS) $(GCC_LIB_NAMES_FLAGS)
GCC001_LDFLAGS_RELEASE = $(GCC_LIB_PATHS_FLAGS) $(GCC_LIB_NAMES_FLAGS)
GCC001_DLLFLAGS = -shared
GCC001_EXEFLAGS = $(GCC_ENTRY_FLAGS)


########################################################################################################################
#                                               Makefile common macroses                                               #
########################################################################################################################


# Определение define создаёт переменную из нескольких строк в отличии от обычного присваивания и символа переноса.
# Если требуется присвоить несколько строк, их можно разделять точкой с запятой, но это выглядит несколько необычно.
# Дополнительная пустая строка в конце даёт возможность запускать несколько макросов в одном $(eval).
# Вывод @echo работает с однострочными переменными, $(eval) работает с многострочными и является заменой := присвоения.
# Команду для оболочки можно вызвать через $(shell) функцию, @echo или обратные апострофы.

# Специальные символы для экранирования:
BLANK :=
SPACE :=
SPACE +=
COMMA := ,
COLON := :
SMCLN := ;
LPRNT := (
RPRNT := )

# Набор рекурсивных макросов для смены регистра.
# Пример использования: $(eval RESULT := $(call UPPERCASE,$(CASE_TABLE),$(TEXT)))
# @param $1 Таблица соответствия, сдвигающаяся каждую итерацию на одну пару влево.
# @param $2 Переменная с текстом для преобразования.
CASE_TABLE := a A b B c C d D e E f F g G h H i I j J k K l L m M n N o O p P q Q r R s S t T u U v V w W x X y Y z Z
LOWERCASE = $(if $1,$$(subst $(word 2,$1),$(word 1,$1),$(call LOWERCASE,$(wordlist 3,$(words $1),$1),$2)),$2)
UPPERCASE = $(if $1,$$(subst $(word 1,$1),$(word 2,$1),$(call UPPERCASE,$(wordlist 3,$(words $1),$1),$2)),$2)

# Проверка цепочки версий и возвращение минимальной поддерживаемой.
# @param $1 Множество поддерживаемых версий и требуемая в отсортированном виде.
# @param $2 Требуемая версия.
# @param #3 Имя проверяемой утилиты без пути и расширения для отладки.
# @return Минимальная поддерживаемая версия из множества. Пустое значение, если версия не поддерживается или не была корректно определена.
CHECK_VERSION = $(if $2,$(if $(filter $2,$(word 2,$1)),$(word 1,$1),$(call CHECK_VERSION,$(wordlist 2,$(words $1),$1),$2)),$(info Can't determine $3 version))

# Вычисление префикса флагов выбранной утилиты.
# @param $1 Имя проверяемой утилиты без пути и расширения.
# @return Префикс флагов, если проверяемая утилита соответствует выбранной.
GET_PREFIX = $1$(call CHECK_VERSION,$(sort $($1_VERSION) $($1_VERSIONS)),$($1_VERSION),$1)

# Упрощенное вычисление префикса флагов выбранной утилиты.
# @param $1 Название переменной утилиты.
# @param $2 Утилита по умолчанию.
CHECK_TOOL = $(eval $1_PREFIX:=$(call GET_PREFIX,$(eval $1_NAME:=$(call UPPERCASE,$(CASE_TABLE),$(basename $(notdir $($1)))))$(eval $($1_NAME)_VERSION:=$($($1_NAME)_VERSION))$($1_NAME)))

# Установка флагов по имени переменной.
# Сначала в $1 записываются имена переменных из $2 в верхнем регистре. Далее с помощью экранирования $$ имена переменных
# заменяются на ссылки, которые будут разыменованы в момент использования рецепта. Это необходимо для того,
# чтобы в правилах сборки можно было использовать автоматические переменные.
# @param $1 Общее имя переменной флагов (например ASFLAGS).
# @param $2 Список имён переменных, на которые будет ссылаться переменная $1 (например ML001_AS_debug ML_AS).
SET_FLAGS = $(eval $1:=$(call UPPERCASE,$(CASE_TABLE),$2))$(eval $1=$(addsuffix $(RPRNT),$(addprefix $$$(LPRNT),$($1))))

# Макрос выбора утилиты по умолчанию.
# Вычисляет версию утилиты только если она не была вычислена ранее.
# @param $1 Название переменной утилиты.
# @param $2 Название переменной флагов.
# @param $3 Утилита по умолчанию.
SET_TOOL = $(if $(filter file,$(origin $1)),,$(eval $1:=$3))$(if $($1_PREFIX),,$(call CHECK_TOOL,$1,$3))$(call SET_FLAGS,$2,$($1_PREFIX)_$2_$(CONFIGURATION) $($1_PREFIX)_$2_$(CONFIGURATION)_$(PLATFORM) $($1_PREFIX)_$2_$(PLATFORM) $($1_PREFIX)_$2)

# Общая команда получения старшей версии из стандартного вывода. Производится поиск версии,
# и дописываются ведущие ноли для последующей строковой сортировки из-за отсутствия числовой.
PARSE_MAJOR_VERSION := sed -ne 's/^[^0-9]*\([0-9]\+\)\..*/\1/g; s/\b[0-9]\b/00&/p; s/\b[0-9]\{2\}\b/0&/p'

# Выбор набора утилит и установка их флагов.
# @param $1 Множество с названием переменной утилиты, названием переменной флагов и значением по умолчанию.
SET_TOOLS = $(if $1,$(call SET_TOOL,$(word 1,$1),$(word 2,$1),$(word 3,$1))$(call SET_TOOLS,$(wordlist 4,$(words $1),$1)),)

# Рекурсивное получение списка каталогов проекта без временного и рабочего.
# @param $1 Корневой каталог для чтения.
GET_PATHS = $(foreach d,$(filter-out $1$(firstword $(subst /,$(SPACE),$(INTERMEDIATE_PATH)))% $1$(firstword $(subst /,$(SPACE),$(OUTPUT_PATH)))%,$(filter %/,$(wildcard $1*/))),$d $(call GET_PATHS,$d))

# Макрос получения флагов списка путей.
# @param $1 Множество нормализованных путей, разделённые точкой с запятой и пробелом.
# @param $2 Префикс флага пути.
# @param $3 Текущий результат, который будет возвращён после выполнения.
# @param $4 Текущий обрабатываемый флаг.
GET_NORMALIZED_PATHS_FLAGS = $(if $1,$(if $(filter %$(SMCLN),$(firstword $1)),$(call GET_NORMALIZED_PATHS_FLAGS,$(wordlist 2,$(words $1),$1),$2,$3$(if $(subst $(SMCLN),,$(firstword $1)), $2"$(strip $(subst $(SMCLN),,$4 $(firstword $1)))",$(if $4, $2"$(strip $4)",)),),$(call GET_NORMALIZED_PATHS_FLAGS,$(wordlist 2,$(words $1),$1),$2,$3,$4 $(firstword $1))),$3)

# Макрос получения флагов списка путей с учётом разделителей и пробелов.
# @param $1 Множество путей в формате переменной окружения PATH, разделённые двоеточием или точкой с запятой.
# @param $2 Префикс флага пути.
GET_PATHS_FLAGS = $(call GET_NORMALIZED_PATHS_FLAGS,$(subst _\,$(COLON)\,$(subst $(SMCLN),$(SMCLN) ,$(subst $(COLON),$(SMCLN),$(subst $(COLON)\,_\,$1))))$(SMCLN),$2)


########################################################################################################################
#                                             Platform-dependent parameters                                            #
########################################################################################################################


# Make использует свой $(SHELL) во время работы. Не важно, из какой оболочки при этом он был запущен.
# Т.к. команды на удаление и копирование могут отличаться, то лучше использовать универсальную запись:
# @cd folder && $(RM) * || true
# В данном случае отключается вывод в консоль, происходит переход в каталог для очистки, выполняется команда,
# актуальная и для POSIX-систем, и для Windows, и всегда возвращается положительный результат (при этом вариант с
# одиночным | каналом не будет выполнен, если первая команда завершится неудачно),
# что предотвращает завершение сборки из-за возможных ошибок.
AT := @
RM := rm -rf
CP := cp -f
MD := mkdir -p
# Triple slash is used instead of double, because some shells can additionally escape it:
BS := \\$(BLANK)

# Определение текущей операционной системы и архитектуры:
ifeq ($(OS),Windows_NT)
	HOST_SYSTEM := windows
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		HOST_PLATFORM := amd64
	else ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		HOST_PLATFORM := amd64
	else ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		HOST_PLATFORM := x86
	endif
	# Определение встроенных команд Windows:
	ifeq ($(findstring cmd.exe,$(SHELL)),cmd.exe)
		# TODO Не все команды Windows поддерживают UNIX-пути. Необходимо добавить какой-то флаг, определяющий синтаксис путей.
		RM := del /f /s /q
		CP := copy /y
		MD := mkdir
		BS := \\\$(BLANK)
	endif

# Операционная система POSIX:
else
	UNAME_S := $(shell uname -s)
	UNAME_P := $(shell uname -p)
	ifneq ($(filter Linux Darwin,$(UNAME_S)),)
		HOST_SYSTEM := posix
	endif
	ifeq ($(UNAME_P),x86_64)
		HOST_PLATFORM := amd64
	else ifneq ($(filter %86, $(UNAME_P)),)
		HOST_PLATFORM := x86
	else ifneq ($(filter arm%,$(UNAME_P)),)
		HOST_PLATFORM := arm
	endif
endif

# Setup default parameters:
ifeq ($(CONFIGURATION),)
	CONFIGURATION := release
endif
ifeq ($(SYSTEM),)
	SYSTEM := $(HOST_SYSTEM)
endif
ifeq ($(PLATFORM),)
	PLATFORM := $(HOST_PLATFORM)
endif

# Setup building paths by default:
# Определение каталогов сборки по умолчанию:
ifndef INTERMEDIATE_PATH
	INTERMEDIATE_PATH := obj/$(CONFIGURATION)/
endif
ifndef OUTPUT_PATH
	OUTPUT_PATH := bin/$(CONFIGURATION)/
endif
ifndef SOURCE_PATHS
	SOURCE_PATHS := $(subst ./,,$(call GET_PATHS,./))
endif

# Каталоги, которые должны быть созданы до начала сборки:
TARGET_PATHS := $(OUTPUT_PATH) $(INTERMEDIATE_PATH) $(addprefix $(INTERMEDIATE_PATH),$(SOURCE_PATHS))


# Определение общепринятых расширений, которые нежелательно трактовать как-то по-другому:
BIN := .bin
COM := .com
DEP := .depend
SYS := .sys

# Настройка сборки под выбранную платформу:
ifeq ($(SYSTEM),none)
	# Расширения абстрактной операционной системы:
	BIN := .b
	DEP := .d
	DLL := .s
	LIB := .l
	OBJ := .o
	PCH := .p
	# Для сборки низкоуровнего кода под определённое оборудование подходят более старые компиляторы. Чтобы их использовать,
	# необходимо вручную сменить переменные с настройками, или перед запуском сборки установить переменную окружения PATH.
	ifeq ($(HOST_SYSTEM),windows)
		DEFAULT_TOOLS := $(DEFAULT_TOOLS_WINDOWS)
	else
		DEFAULT_TOOLS := $(DEFAULT_TOOLS_POSIX)
	endif

else ifeq ($(SYSTEM),windows)
	DLL := .dll
	EXE := .exe
	LIB := .lib
	OBJ := .obj
	PCH := .pch
	# Выбор компиляторов по умолчанию:
	ifeq ($(HOST_SYSTEM),windows)
		DEFAULT_TOOLS := $(DEFAULT_TOOLS_WINDOWS)
	else
		DEFAULT_TOOLS := $(DEFAULT_TOOLS_POSIX)
	endif

else
	DLL := .so
	LIB := .a
	OBJ := .o
	PCH := .gch
	DEFAULT_TOOLS := $(DEFAULT_TOOLS_POSIX)

endif

# Настройка всех поддерживаемых утилит. Если программа сборки не поддерживает эти конструкции,
# необходимо закомментировать и настроить флаги вручную.
$(eval $(call SET_TOOLS,$(DEFAULT_TOOLS)))


########################################################################################################################
#                                              Auxiliary values computing                                              #
########################################################################################################################


# Вычисление флагов путей заголовочных файлов и статических библиотек:
CL_INCLUDE_FLAGS := $(call GET_PATHS_FLAGS,./:$(INCLUDE_PATH),/I)
LINK_LIB_PATHS_FLAGS := $(call GET_PATHS_FLAGS,./:$(LIBRARY_PATH),/LIBPATH$(COLON))
LINK_LIB_NAMES_FLAGS := $(addsuffix $(LIB)",$(addprefix ",$(LIBRARY_NAME)))
GCC_INCLUDE_FLAGS := $(call GET_PATHS_FLAGS,./:$(INCLUDE_PATH),-I)
GCC_LIB_PATHS_FLAGS := $(call GET_PATHS_FLAGS,./:$(LIBRARY_PATH),-L)
GCC_LIB_NAMES_FLAGS := $(addsuffix $(LIB),$(addprefix -l:,$(LIBRARY_NAME)))

# Prepare C precompiled header variables:
ifneq ($(TARGET_PCH_C_SOURCE),)
TARGET_PCH_C_OBJ := $(INTERMEDIATE_PATH)$(TARGET_PCH_C_SOURCE)$(OBJ)
TARGET_PCH_C_PREREQUISITE = $(INTERMEDIATE_PATH)$(TARGET_PCH_C_SOURCE)$(PCH)
TARGET_PCH_C_USE := $($(CC_PREFIX)_PCH_C_USE)
endif

# Prepare CPP precompiled header variables:
ifneq ($(TARGET_PCH_CPP_SOURCE),)
TARGET_PCH_CPP_OBJ := $(INTERMEDIATE_PATH)$(TARGET_PCH_CPP_SOURCE)$(OBJ)
TARGET_PCH_CPP_PREREQUISITE = $(INTERMEDIATE_PATH)$(TARGET_PCH_CPP_SOURCE)$(PCH)
TARGET_PCH_CPP_USE := $($(CXX_PREFIX)_PCH_CPP_USE)
endif

# Determine all source files in project directories or use custom files.
# But ifndef not works properly to allow empty values:
ifeq ($(origin TARGET_ASM_FILES),undefined)
TARGET_ASM_FILES := $(wildcard *.asm $(addsuffix *.asm,$(SOURCE_PATHS)) *.s $(addsuffix *.s,$(SOURCE_PATHS)))
endif
ifeq ($(origin TARGET_C_FILES),undefined)
TARGET_C_FILES := $(wildcard *.c $(addsuffix *.c,$(SOURCE_PATHS)))
endif
ifeq ($(origin TARGET_CPP_FILES),undefined)
TARGET_CPP_FILES := $(wildcard *.cpp $(addsuffix *.cpp,$(SOURCE_PATHS)))
endif

# Object files without PCH and % pattern to free target from object paths dependency.
# The one known linker have not entry point parameter and depends on file order,
# therefore assembler object files are first by default.
TARGET_OBJS_FILES := $(addprefix $(INTERMEDIATE_PATH),$(addsuffix $(OBJ),$(TARGET_ASM_FILES) $(TARGET_C_FILES) $(TARGET_CPP_FILES)))
TARGET_OBJS_FILES := $(filter-out $(TARGET_PCH_C_OBJ) $(TARGET_PCH_CPP_OBJ),$(TARGET_OBJS_FILES))

# Special target to rebuild sources when headers changes (%.depend file in intermediate directory):
TARGET_DEPEND = $(INTERMEDIATE_PATH)%$(DEP)
TARGET_DEPEND_FILES := $(addsuffix $(DEP),$(TARGET_C_FILES) $(TARGET_CPP_FILES))


########################################################################################################################
#                                                         Rules                                                        #
########################################################################################################################


# Prevent automatical removing some files by make:
.SECONDARY:

# Generate intermediate folders before build:
$(TARGET_PATHS):
	$(AT)$(MD) $@

.PHONY: peachtree
peachtree: $(TARGET_PATHS)

# Special target to create output folders:
-include peachtree

# Generate dependencies of source files on header files:
-include $(TARGET_DEPEND_FILES)

# Targets to generate dependencies:
$(TARGET_DEPEND): %.c
	@echo Updating $< dependencies...
	$(AT)$($(CC_PREFIX)_DEPEND_RECIPE)

$(TARGET_DEPEND): %.cpp
	@echo Updating $< dependencies...
	$(AT)$($(CXX_PREFIX)_DEPEND_RECIPE)

# Rule for C precompiled header:
ifneq ($(TARGET_PCH_C_SOURCE),)
$(TARGET_PCH_C_PREREQUISITE): $(TARGET_PCH_C_SOURCE) $(TARGET_PCH_C_HEADER)
	$(AT)$(CC) $(CFLAGS) $($(CC_PREFIX)_PCH)
	@echo Precompiled C header was created.

$(TARGET_PCH_C_OBJ): $(TARGET_PCH_C_SOURCE) $(TARGET_PCH_C_HEADER) $(TARGET_PCH_C_PREREQUISITE)
	$(AT)$(CC) $(CFLAGS) $($(CC_PREFIX)_PCH_OBJ)
	$(AT)$($(CC_PREFIX)_CC_ASM_RECIPE)
	@echo Precompiled C object was created.
endif

# Rule for CPP precompiled header:
ifneq ($(TARGET_PCH_CPP_SOURCE),)
$(TARGET_PCH_CPP_PREREQUISITE): $(TARGET_PCH_CPP_SOURCE) $(TARGET_PCH_CPP_HEADER)
	$(AT)$(CXX) $(CXXFLAGS) $($(CXX_PREFIX)_PCH)
	@echo Precompiled CPP header was created.

$(TARGET_PCH_CPP_OBJ): $(TARGET_PCH_CPP_SOURCE) $(TARGET_PCH_CPP_HEADER) $(TARGET_PCH_CPP_PREREQUISITE)
	$(AT)$(CXX) $(CXXFLAGS) $($(CXX_PREFIX)_PCH_OBJ)
	$(AT)$($(CXX_PREFIX)_CXX_ASM_RECIPE)
	@echo Precompiled CPP object was created.
endif

# C rule (dependencies are used by rebuild target to rebuild sources after usual build):
$(INTERMEDIATE_PATH)%.c$(OBJ): %.c $(TARGET_DEPEND) $(TARGET_PCH_C_OBJ)
	$(AT)$(CC) $(CFLAGS) $(TARGET_PCH_C_USE)
	$(AT)$($(CC_PREFIX)_CC_ASM_RECIPE)

# C++ rule:
$(INTERMEDIATE_PATH)%.cpp$(OBJ): %.cpp $(TARGET_DEPEND) $(TARGET_PCH_CPP_OBJ)
	$(AT)$(CXX) $(CXXFLAGS) $(TARGET_PCH_CPP_USE)
	$(AT)$($(CXX_PREFIX)_CXX_ASM_RECIPE)

# Native Assembler compilation:
$(INTERMEDIATE_PATH)%.s$(OBJ): %.s
$(INTERMEDIATE_PATH)%.asm$(OBJ): %.asm
	$(AT)$(AS) $(ASFLAGS)


# Т.к. некоторые исполняемые файлы могут быть без расширения, цели на их создание могут совпасть с .PHONY целями, что
# приведёт к ошибке сборки. Поэтому сборка доступна только в выходном каталоге. Выражение % заменяется последовательностью
# любых символов так, чтобы совпало со всей целью. Полученное значение далее подставляется в пререквизиты, которые
# в свою очередь должны совпасть с реальными файлами с путями или другими промежуточными целями.

# Static library rule:
$(OUTPUT_PATH)%$(LIB): $(TARGET_OBJS_FILES) $(TARGET_PCH_C_OBJ) $(TARGET_PCH_CPP_OBJ)
	$(AT)$(AR) $(ARFLAGS)

# Dynamic link library rule:
$(OUTPUT_PATH)%$(DLL): $(TARGET_OBJS_FILES) $(TARGET_PCH_C_OBJ) $(TARGET_PCH_CPP_OBJ)
	$(AT)$(LD) $(DLLFLAGS) $(LDFLAGS)

# Executable rule:
$(OUTPUT_PATH)%$(EXE) $(OUTPUT_PATH)%: $(TARGET_OBJS_FILES) $(TARGET_PCH_C_OBJ) $(TARGET_PCH_CPP_OBJ)
	$(AT)$(LD) $(EXEFLAGS) $(LDFLAGS)

# Default rule for unsupported types. To extend rule and allow binary extension usage,
# add rule with same target and additional prerequisites:
$(addprefix $(OUTPUT_PATH)%,$(BIN) $(SYS)):
	$(error Can't assembly binary file of $(suffix $@) type)


########################################################################################################################
#                                                       Debugging                                                      #
########################################################################################################################


# Additionally use "make print-VARIABLE" to debug particular variable:
print-%: ; @echo $* = $($*)

# Подготовка сборки произведена. Вывод отладочной информации.
ifdef DEBUG
# Не скрывать вызовы:
AT :=

# Целевая конфигурация:
$(info )
$(info $(SPACE)                   CONFIGURATION = $(CONFIGURATION))
$(info $(SPACE)           PLATFORM ARCHITECTURE = $(PLATFORM) $(ARCHITECTURE))
$(info $(SPACE)                          SYSTEM = $(SYSTEM))
$(info $(SPACE)                      EXTENSIONS = $(BIN) $(COM) $(DEP) $(DLL) $(EXE) $(LIB) $(OBJ) $(PCH) $(SYS))

# Текущая конфигурация:
$(info )
$(info $(SPACE) HOST_PLATFORM HOST_ARCHITECTURE = $(HOST_PLATFORM) $(HOST_ARCHITECTURE))
$(info $(SPACE)                     HOST_SYSTEM = $(HOST_SYSTEM))

$(info )
$(info $(SPACE)                              RM = $(RM))
$(info $(SPACE)                              CP = $(CP))
$(info $(SPACE)                              MD = $(MD))

# Параметры сборки:
$(info )
$(info $(SPACE)               INTERMEDIATE_PATH = $(INTERMEDIATE_PATH))
$(info $(SPACE)                     OUTPUT_PATH = $(OUTPUT_PATH))
$(info $(SPACE)                    SOURCE_PATHS = $(SOURCE_PATHS))
$(info $(SPACE)                    INCLUDE_PATH = $(INCLUDE_PATH))
$(info $(SPACE)                    LIBRARY_PATH = $(LIBRARY_PATH))
$(info $(SPACE)                    LIBRARY_NAME = $(LIBRARY_NAME))
$(info $(SPACE)                  TARGET_PCH_C_* = $(TARGET_PCH_C_HEADER) $(TARGET_PCH_C_SOURCE) $(TARGET_PCH_C_OBJ) $(TARGET_PCH_C_PREREQUISITE))
$(info $(SPACE)                TARGET_PCH_CPP_* = $(TARGET_PCH_CPP_HEADER) $(TARGET_PCH_CPP_SOURCE) $(TARGET_PCH_CPP_OBJ) $(TARGET_PCH_CPP_PREREQUISITE))
$(info $(SPACE)                    TARGET_ENTRY = $(TARGET_ENTRY))

# Вычисленные параметры:
$(info )
$(info $(SPACE)                  TARGET_C_FILES = $(TARGET_C_FILES))
$(info $(SPACE)                TARGET_CPP_FILES = $(TARGET_CPP_FILES))
$(info $(SPACE)                TARGET_ASM_FILES = $(TARGET_ASM_FILES))
$(info $(SPACE)               TARGET_OBJS_FILES = $(TARGET_OBJS_FILES))
$(info $(SPACE)             TARGET_DEPEND_FILES = $(TARGET_DEPEND_FILES))
$(info $(SPACE)                   TARGET_DEPEND = $(TARGET_DEPEND))

$(info )
$(info $(SPACE)            AR_PREFIX AR ARFLAGS = $(AR_PREFIX) $(AR) $(ARFLAGS))
$(info $(SPACE)            AS_PREFIX AS ASFLAGS = $(AS_PREFIX) $(AS) $(ASFLAGS))
$(info $(SPACE)             CC_PREFIX CC CFLAGS = $(CC_PREFIX) $(CC) $(CFLAGS))
$(info $(SPACE)         CXX_PREFIX CXX CXXFLAGS = $(CXX_PREFIX) $(CXX) $(CXXFLAGS))
$(info $(SPACE)            LD_PREFIX LD LDFLAGS = $(LD_PREFIX) $(LD) $(LDFLAGS))
$(info $(SPACE)           LD_PREFIX LD DLLFLAGS = $(LD_PREFIX) $(LD) $(DLLFLAGS))
$(info $(SPACE)           LD_PREFIX LD EXEFLAGS = $(LD_PREFIX) $(LD) $(EXEFLAGS))
$(info )
endif


# Disable implicit rules to speed-up build:
.SUFFIXES:
SUFFIXES :=
%.out:
%.a:
%.ln:
%.o:
%: %.o
%.c:
%: %.c
%.ln: %.c
%.o: %.c
%.cc:
%: %.cc
%.o: %.cc
%.C:
%: %.C
%.o: %.C
%.cpp:
%: %.cpp
%.o: %.cpp
%.p:
%: %.p
%.o: %.p
%.f:
%: %.f
%.o: %.f
%.F:
%: %.F
%.o: %.F
%.f: %.F
%.r:
%: %.r
%.o: %.r
%.f: %.r
%.y:
%.ln: %.y
%.c: %.y
%.l:
%.ln: %.l
%.c: %.l
%.r: %.l
%.s:
%: %.s
%.o: %.s
%.S:
%: %.S
%.o: %.S
%.s: %.S
%.mod:
%: %.mod
%.o: %.mod
%.sym:
%.def:
%.sym: %.def
%.h:
%.info:
%.dvi:
%.tex:
%.dvi: %.tex
%.texinfo:
%.info: %.texinfo
%.dvi: %.texinfo
%.texi:
%.info: %.texi
%.dvi: %.texi
%.txinfo:
%.info: %.txinfo
%.dvi: %.txinfo
%.w:
%.c: %.w
%.tex: %.w
%.ch:
%.web:
%.p: %.web
%.tex: %.web
%.sh:
%: %.sh
%.elc:
%.el:
(%): %
%.out: %
%.c: %.w %.ch
%.tex: %.w %.ch
%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%
.web.p:
.l.r:
.dvi:
.F.o:
.l:
.y.ln:
.o:
.y:
.def.sym:
.p.o:
.p:
.txinfo.dvi:
.a:
.l.ln:
.w.c:
.texi.dvi:
.sh:
.cc:
.cc.o:
.def:
.c.o:
.r.o:
.r:
.info:
.elc:
.l.c:
.out:
.C:
.r.f:
.S:
.texinfo.info:
.c:
.w.tex:
.c.ln:
.s.o:
.s:
.texinfo.dvi:
.el:
.texinfo:
.y.c:
.web.tex:
.texi.info:
.DEFAULT:
.h:
.tex.dvi:
.cpp.o:
.cpp:
.C.o:
.ln:
.texi:
.txinfo:
.tex:
.txinfo.info:
.ch:
.S.s:
.mod:
.mod.o:
.F.f:
.w:
.S.o:
.F:
.web:
.sym:
.f:
.f.o:

# End of makefile.
# Конец файла сборки.
