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

#	TARGET_ENTRY - optional variable with entry point name for executable binaries (optional and empty by default).
#	TARGET_LIB_PATHS - paths with static libraries. You can include intermediate path also.
#	TARGET_LIB_NAMES - static library names used in build (optional and empty by default). Adjust to specific compiler.
#	TARGET_INCLUDE_PATHS - paths with additional headers.
#	TARGET_PCH_C_HEADER - C header relative path for PCH.
#	TARGET_PCH_C_SOURCE - relative path of the C source file to compile as PCH.
#	TARGET_PCH_CPP_HEADER - CPP header relative path for PCH.
#	TARGET_PCH_CPP_SOURCE - relative path of the CPP source file to compile as PCH.


# You can define this macroses at any time:
#	TARGET_PATHS - additional paths with explicit ./ current directory that contains sources for assembling.
#	TARGET_INTERMEDIATE_PATH - target path with intermediate build data.
#	TARGET_OUTPUT_PATH - output path with target and its resources.


# Automatically initialized macroses that can be used:
#	ASM - assembler listing file extension.
#	BIN - unknown binary file extension.
#	COM - simple executable file extension.
#	DEP - dependency file extension.
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
#	LDFLAGS - linker flags.
#	RM - command to remove a file (default: rm -rf).
#	CP - file copy command (default: cp -f).

# This is obsolete instruction because target makefile can be included multiple times now. Default target:
#.DEFAULT_GOAL = all


# Наборы инструментов по умолчанию для поддерживаемых платформ:
DEFAULT_TOOLS_WINDOWS := AR ARFLAGS lib AS ASFLAGS ml CC CFLAGS cl CXX CXXFLAGS cl LD LDFLAGS link
DEFAULT_TOOLS_POSIX := AR ARFLAGS ar AS ASFLAGS ml CC CFLAGS gcc CXX CXXFLAGS gcc LD LDFLAGS gcc

# Макросы определения версий поддерживаемых утилит.
# AR программы обслуживания (сопровождения) архивов:
LIB_VERSION = $(shell $(AR) 2>&1 | $(PARSE_MAJOR_VERSION))
LIB_VERSIONS = 001
# AS ассемблеры:
ML_VERSION = $(shell $(AS) 2>&1 | $(PARSE_MAJOR_VERSION))
ML_VERSIONS = 001 007
ML64_VERSION = $(shell $(AS) 2>&1 | $(PARSE_MAJOR_VERSION))
ML64_VERSIONS = 001 007
# CC/CXX компиляторы C/C++:
CL_VERSION = $(shell $(CC) 2>&1 | $(PARSE_MAJOR_VERSION))
CL_VERSIONS = 001 010
GCC_VERSION = $(shell $(CC) --version 2>&1 | $(PARSE_MAJOR_VERSION))
GCC_VERSIONS = 001
# LD компоновщики:
LINK_VERSION = $(shell $(LD) /HELP 2>&1 | $(PARSE_MAJOR_VERSION))
LINK_VERSIONS = 001 010

# Общие флаги пакета компиляторов MSVC:
# TODO: NOT MACROS. CHECK ORDER!
MSVC_INCLUDE_FLAGS := $(addsuffix ",$(addprefix /I",$(TARGET_INCLUDE_PATHS)))
MSVC_LIB_PATHS_FLAGS := $(addsuffix ",$(addprefix /LIBPATH:",$(TARGET_LIB_PATHS)))
MSVC_LIB_NAMES_FLAGS := $(addsuffix $(LIB)",$(addprefix ",$(TARGET_LIB_NAMES)))

# Флаги компиляторов Microsoft Visual Studio 1.XX для сборки и в 16-битном режиме:
# Данные программы проверены, предсказуемы и наиболее оптимизированы в отличие от современных наборов.
ML001_DEBUG := /AT /c
ML001_RELEASE := /AT /c

ML64001_DEBUG := /AT /c
ML64001_RELEASE := /AT /c

CL001_DEBUG := /AT /G2 /Gs /Gx /c /Zl
CL001_RELEASE := /AT /G2 /Gs /Gx /c /Zl

LIB001_DEBUG := /VERBOSE
LIB001_RELEASE := /VERBOSE

LINK001_DEBUG := /T /NOD
LINK001_RELEASE := /T /NOD

# Флаги актуальной версии MSVC для сборки цели.
# Компиляторы Microsoft не поддерживают флаги для компиляции под определённую архитектуру процессора.
# Для сборки необходимо запустить определённый экземпляр компилятора, установив переменную окружения.
ML007_DEBUG := /AT /c
ML007_RELEASE := /AT /c

ML64007_DEBUG := /AT /c
ML64007_RELEASE := /AT /c

CL010_DEBUG := /c $(MSVC_INCLUDE_FLAGS) /GS /W3 /Zc:wchar_t /ZI /Gm /Od /Fd"$(TARGET_INTERMEDIATE_PATH)vc141.pdb" /Zc:inline /fp:precise /D "_DEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /errorReport:prompt /WX- /Zc:forScope /RTC1 /Gd /Oy- /MDd /EHsc /nologo /diagnostics:classic
CL010_RELEASE := /c $(MSVC_INCLUDE_FLAGS) /GS- /GL /W3 /Gy /Zc:wchar_t /Zi /Gm- /O2 /Fd"$(TARGET_INTERMEDIATE_PATH)vc141.pdb" /Zc:inline /fp:precise /D "NDEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /errorReport:prompt /WX- /Zc:forScope /Gd /Oy- /Oi /MD /EHsc /nologo /diagnostics:classic

LINK010_DEBUG := /OUT:"$(SRC_OUTPUT_TARGET)" /ERRORREPORT:PROMPT /NOLOGO /SUBSYSTEM:WINDOWS
LINK010_RELEASE := /OUT:"$(SRC_OUTPUT_TARGET)" /ERRORREPORT:PROMPT /NOLOGO /SUBSYSTEM:WINDOWS /LTCG:incremental /NODEFAULTLIB

LINK010_DEBUG_EXE := $(MSVC_LIB_PATHS_FLAGS) $(MSVC_LIB_NAMES_FLAGS) "ucrtd.lib" "vcruntimed.lib" "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" /INCREMENTAL /DEBUG:FASTLINK
LINK010_RELEASE_EXE := $(MSVC_LIB_PATHS_FLAGS) $(MSVC_LIB_NAMES_FLAGS) "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" /INCREMENTAL:NO /OPT:REF /SAFESEH:NO /OPT:ICF

LINK010_X86 := /MACHINE:X86
LINK010_AMD64 := /MACHINE:X64

LINK010_AMD64_EXE := /ALIGN:16 /DRIVER
LINK010_EXE := /MANIFEST:NO /NXCOMPAT /PDB:"$(TARGET_INTERMEDIATE_PATH)src.pdb" /DYNAMICBASE /ENTRY:"$(TARGET_ENTRY)" /MERGE:".rdata=.text" /TLBID:1

# GCC:



# Определение define создаёт переменную из нескольких строк в отличии от обычного присваивания и символа переноса.
# Если требуется присвоить несколько строк, их можно разделять точкой с запятой, но это выглядит несколько необычно.
# Дополнительная пустая строка в конце даёт возможность запускать несколько макросов в одном $(eval).
# Вывод @echo работает с однострочными переменными, $(eval) работает с многострочными и является заменой := присвоения.
# Команду для оболочки можно вызвать через $(shell) функцию, @echo или обратные апострофы.

# Специальные символы для экранирования:
SPACE :=
SPACE +=
COMMA := ,
COLON := :

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
# @return Минимальная поддерживаемая версия из множества. Пустое значение, если версия не поддерживается или не была корректно определена.
CHECK_VERSION = $(if $2,$(if $(filter $2,$(word 2,$1)),$(word 1,$1),$(call CHECK_VERSION,$(wordlist 2,$(words $1),$1),$2)),)

# Вычисление префикса флагов выбранной утилиты.
# @param $1 Имя проверяемой утилиты без пути и расширения.
# @return Префикс флагов, если проверяемая утилита соответствует выбранной.
GET_PREFIX = $1$(call CHECK_VERSION,$(sort $($1_VERSION) $($1_VERSIONS)),$($1_VERSION))

# Упрощенное вычисление префикса флагов выбранной утилиты.
# @param $1 Название переменной утилиты.
# @param $2 Утилита по умолчанию.
CHECK_TOOL = $(eval $1_PREFIX:=$(call GET_PREFIX,$(eval $1_NAME:=$(call UPPERCASE,$(CASE_TABLE),$(basename $(notdir $($1)))))$(eval $($1_NAME)_VERSION:=$($($1_NAME)_VERSION))$($1_NAME)))

# Установка флагов по имени переменной.
# @param $1 Общее имя переменной флагов.
# @param $2 Сформированное имя переменной флагов выбранной утилиты.
SET_FLAGS = $(eval $1:=$(call UPPERCASE,$(CASE_TABLE),$2))$(eval $1:=$($($1)))

# Макрос выбора утилиты по умолчанию.
# @param $1 Название переменной утилиты.
# @param $2 Название переменной флагов.
# @param $3 Утилита по умолчанию.
SET_TOOL = $(if $(filter file,$(origin $1)),,$(eval $1:=$3))$(call CHECK_TOOL,$1,$3)$(call SET_FLAGS,$2,$($1_PREFIX)_$(CONFIGURATION))

# Общая команда получения старшей версии из стандартного вывода. Производится поиск версии,
# и дописываются ведущие ноли для последующей строковой сортировки из-за отсутствия числовой.
PARSE_MAJOR_VERSION := sed -ne 's/^[^0-9]*\([0-9]\+\)\..*/\1/g; s/\b[0-9]\b/00&/p; s/\b[0-9]\{2\}\b/0&/p'

# Выбор набора утилит и установка их флагов.
# @param $1 Множество с названием переменной утилиты, названием переменной флагов и значением по умолчанию.
SET_TOOLS = $(if $1,$(call SET_TOOL,$(word 1,$1),$(word 2,$1),$(word 3,$1))$(call SET_TOOLS,$(wordlist 4,$(words $1),$1)),)

# Рекурсивное получение списка каталогов проекта без временного и рабочего:
# @param $1 Корневой каталог для чтения.
GET_PATHS = $1 $(foreach d,$(filter-out %$(TARGET_INTERMEDIATE_PATH) %$(TARGET_OUTPUT_PATH),$(filter %/,$(wildcard $1*/))),$(call GET_PATHS,$d))

# Make использует свой $(SHELL) во время работы. Не важно, из какой оболочки при этом он был запущен.
# Т.к. команды на удаление и копирование могут отличаться, то лучше использовать универсальную запись:
# @cd folder && $(RM) * || true
# В данном случае отключается вывод в консоль, происходит переход в каталог для очистки, выполняется команда,
# актуальная и для POSIX-систем, и для Windows, и всегда возвращается положительный результат (при этом вариант с
# одиночным | каналом не будет выполнен, если первая команда завершится неудачно),
# что предотвращает завершение сборки из-за возможных ошибок.
RM := rm -rf
CP := cp -f

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
		RM := del /f /s /q
		CP := copy /y
	endif

# Операционная система POSIX:
else
	UNAME_S := $(shell uname -s)
	UNAME_P := $(shell uname -p)
	ifneq ($(filter Linux Darwin,$(UNAME_S)),)
		HOST_SYSTEM := posix;
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
ifndef TARGET_INTERMEDIATE_PATH
	TARGET_INTERMEDIATE_PATH := obj/$(CONFIGURATION)/
endif
ifndef TARGET_OUTPUT_PATH
	TARGET_OUTPUT_PATH := bin/$(CONFIGURATION)/
endif
ifndef TARGET_PATHS
	TARGET_PATHS := $(call GET_PATHS,./)
endif
ifndef TARGET_INCLUDE_PATHS
	TARGET_INCLUDE_PATHS := ./
endif
ifndef TARGET_LIB_PATHS
	TARGET_LIB_PATHS := ./
endif


# Определение общепринятых расширений, которые нежелательно трактовать как-то по-другому:
BIN := .bin
COM := .com
DEP := .depend
SYS := .sys

# Настройка сборки под выбранную платформу:
ifeq ($(SYSTEM),none)
	# Расширения абстрактной операционной системы:
	ASM := .a
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
	ASM := .asm
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
	ASM := .s
	DLL := .so
	LIB := .a
	OBJ := .o
	PCH := .gch
	DEFAULT_TOOLS := $(DEFAULT_TOOLS_POSIX)

endif

# Настройка всех поддерживаемых утилит. Если программа сборки не поддерживает эти конструкции,
# необходимо закомментировать и настроить флаги вручную.
$(eval $(call SET_TOOLS,$(DEFAULT_TOOLS)))


# Prepare C precompiled header variables:
ifneq ($(TARGET_PCH_C_SOURCE),)
TARGET_PCH_C_OBJ := $(TARGET_INTERMEDIATE_PATH)$(TARGET_PCH_C_SOURCE)$(OBJ)
TARGET_PCH_C_PREREQUISITE = $(TARGET_INTERMEDIATE_PATH)$(TARGET_PCH_C_SOURCE)$(PCH)
#TARGET_PCH_C_USE_MACROS := $(SRC_PCH_C_USE_FLAGS)
endif

# Prepare CPP precompiled header variables:
ifneq ($(TARGET_PCH_CPP_SOURCE),)
TARGET_PCH_CPP_OBJ := $(TARGET_INTERMEDIATE_PATH)$(TARGET_PCH_CPP_SOURCE)$(OBJ)
TARGET_PCH_CPP_PREREQUISITE = $(TARGET_INTERMEDIATE_PATH)$(TARGET_PCH_CPP_SOURCE)$(PCH)
#TARGET_PCH_CPP_USE_MACROS := $(SRC_PCH_CPP_USE_FLAGS)
endif

# Determine all source files in project directories:
TARGET_C_FILES = $(subst ./,,$(wildcard $(addsuffix *.c, $(TARGET_PATHS))))
TARGET_CPP_FILES = $(subst ./,,$(wildcard $(addsuffix *.cpp, $(TARGET_PATHS))))
TARGET_ASM_FILES = $(subst ./,,$(wildcard $(addsuffix *$(ASM), $(TARGET_PATHS))))

# Object files without PCH. Specially without % pattern to free target from object paths dependency:
TARGET_OBJS_FILES := $(addprefix $(TARGET_INTERMEDIATE_PATH),$(addsuffix $(OBJ),$(TARGET_C_FILES) $(TARGET_CPP_FILES) $(TARGET_ASM_FILES)))
TARGET_OBJS_FILES := $(filter-out $(TARGET_PCH_C_OBJ) $(TARGET_PCH_CPP_OBJ),$(TARGET_OBJS_FILES))

# Special dependency target to rebuild sources when headers changes (%.depend file in intermediate directory):
TARGET_DEPENDENCY = $(TARGET_INTERMEDIATE_PATH)%$(DEP)
TARGET_DEPENDENCY_FILES := $(addsuffix $(DEP),$(TARGET_C_FILES) $(TARGET_CPP_FILES))


# Prevent automatical removing some files by make:
.SECONDARY:

# Generate dependencies of source files on header files:
ifneq ($(MAKECMDGOALS),clean)
-include $(TARGET_DEPENDENCY_FILES)
endif

# Don't build dependencies in usual builds:
# Use automatic variables without := operator!
TARGET_DEPENDENCY_ECHO =
ifneq ($(MAKECMDGOALS),rebuild)
TARGET_DEPENDENCY_RECIPE = touch -a $@
else
TARGET_DEPENDENCY_ECHO = (echo "Updating $< dependencies...");
endif

# Targets to generate dependencies:
$(TARGET_DEPENDENCY): %.c
	@$(TARGET_DEPENDENCY_ECHO)($(TARGET_DEPENDENCY_RECIPE))

$(TARGET_DEPENDENCY): %.cpp
	@$(TARGET_DEPENDENCY_ECHO)($(TARGET_DEPENDENCY_RECIPE))

# Rule for C precompiled header:
ifneq ($(TARGET_PCH_C_SOURCE),)
$(TARGET_PCH_C_PREREQUISITE): $(TARGET_PCH_C_SOURCE) $(TARGET_PCH_C_HEADER)
#	@$(CC) $(CFLAGS) $(SRC_PCH_CXX_MACROS)
	@echo Precompiled C header was created.

$(TARGET_PCH_C_OBJ): $(TARGET_PCH_C_SOURCE) $(TARGET_PCH_C_HEADER) $(TARGET_PCH_C_PREREQUISITE)
#	@$(CC) $(CFLAGS) $(SRC_PCH_CXX_OBJ_MACROS)
#	@$(SRC_CC_C_ASM_MACROS)
	@echo Precompiled C object was created.
endif

# Rule for CPP precompiled header:
ifneq ($(TARGET_PCH_CPP_SOURCE),)
$(TARGET_PCH_CPP_PREREQUISITE): $(TARGET_PCH_CPP_SOURCE) $(TARGET_PCH_CPP_HEADER)
#	@$(CC) $(CPPFLAGS) $(SRC_PCH_CXX_MACROS)
	@echo Precompiled CPP header was created.

$(TARGET_PCH_CPP_OBJ): $(TARGET_PCH_CPP_SOURCE) $(TARGET_PCH_CPP_HEADER) $(TARGET_PCH_CPP_PREREQUISITE)
#	@$(CC) $(CPPFLAGS) $(SRC_PCH_CXX_OBJ_MACROS)
#	@$(SRC_CC_CPP_ASM_MACROS)
	@echo Precompiled CPP object was created.
endif

# C rule (dependencies are used by rebuild target to rebuild sources after usual build):
TARGET_C := $(TARGET_INTERMEDIATE_PATH)%.c$(OBJ)
TARGET_C_PREREQUISITES := %.c $(TARGET_DEPENDENCY) $(TARGET_PCH_C_OBJ)
TARGET_C_RECIPE := $(CC) $(CFLAGS) $(SRC_CC_C_MACROS)
#TARGET_C_ASM_RECIPE := $(SRC_CC_C_ASM_MACROS)

$(TARGET_C): $(TARGET_C_PREREQUISITES)
	@echo "*** TARGET C *** $@: $^"
#	@$(TARGET_C_RECIPE)
#	@$(TARGET_C_ASM_RECIPE)

# C++ rule:
TARGET_CPP := $(TARGET_INTERMEDIATE_PATH)%.cpp$(OBJ)
TARGET_CPP_PREREQUISITES := %.cpp $(TARGET_DEPENDENCY) $(TARGET_PCH_CPP_OBJ)
TARGET_CPP_RECIPE := $(CXX) $(CXXFLAGS) $(SRC_CC_CPP_MACROS)
#TARGET_CPP_ASM_RECIPE := $(SRC_CC_CPP_ASM_MACROS)

$(TARGET_CPP): $(TARGET_CPP_PREREQUISITES)
	@echo "*** TARGET CPP *** $@: $^"
#	@$(TARGET_CPP_RECIPE)
#	@$(TARGET_CPP_ASM_RECIPE)

# Native Assembler compilation:
TARGET_ASM := $(TARGET_INTERMEDIATE_PATH)%$(ASM)$(OBJ)
TARGET_ASM_PREREQUISITES := %$(ASM)
TARGET_ASM_RECIPE := $(AS) $(ASFLAGS)

$(TARGET_ASM): $(TARGET_ASM_PREREQUISITES)
	@echo "*** TARGET ASM *** $@: $^"
#	@$(TARGET_ASM_RECIPE)


# Т.к. некоторые исполняемые файлы могут быть без расширения, цели на их создание могут совпасть с .PHONY целями, что
# приведёт к ошибке сборки. Поэтому сборка доступна только в выходном каталоге. Выражение % заменяется последовательностью
# любых символов так, чтобы совпало со всей целью. Полученное значение далее подставляется в пререквизиты, которые
# в свою очередь должны совпасть с реальными файлами с путями или другими промежуточными целями.

# Static library rule:
TARGET_STATIC := $(TARGET_OUTPUT_PATH)%$(LIB)
TARGET_STATIC_PREREQUISITES := $(TARGET_OBJS_FILES) $(TARGET_PCH_C_OBJ) $(TARGET_PCH_CPP_OBJ)
TARGET_STATIC_RECIPE := $(AR) $(addprefix ",$(addsuffix ",$^)) $(ARFLAGS)

$(TARGET_STATIC): $(TARGET_STATIC_PREREQUISITES)
	@echo "*** TARGET LIB *** $@: $^"
#	@$(TARGET_STATIC_RECIPE)

# Generic linker rules for executables and dynamic link libraries:
TARGET_EXECUTABLE := $(addprefix $(TARGET_OUTPUT_PATH)%,$(EXE) $(DLL)) $(TARGET_OUTPUT_PATH)%
TARGET_EXECUTABLE_PREREQUISITES := $(TARGET_OBJS_FILES) $(TARGET_PCH_C_OBJ) $(TARGET_PCH_CPP_OBJ)
TARGET_EXECUTABLE_RECIPE := $(LD) $(LFLAGS) $(addprefix ",$(addsuffix ",$^))

$(TARGET_EXECUTABLE): $(TARGET_OBJS_FILES)
	@echo "*** TARGET EXE DLL *** $@: $^"
#	@$(TARGET_EXECUTABLE_RECIPE)

# Default rule for unsupported types. To extend rule and allow binary extension usage,
# add rule with same target and additional prerequisites:
TARGET_BINARY := $(addprefix $(TARGET_OUTPUT_PATH)%,$(BIN) $(SYS))
$(TARGET_BINARY):
	$(error Can't assembly binary file of $(suffix $@) type)


# Подготовка сборки произведена. Вывод отладочной информации.
ifdef DEBUG
# Целевая конфигурация:
$(info )
$(info $(SPACE)                   CONFIGURATION = $(CONFIGURATION))
$(info $(SPACE)           PLATFORM ARCHITECTURE = $(PLATFORM) $(ARCHITECTURE))
$(info $(SPACE)                          SYSTEM = $(SYSTEM))
$(info $(SPACE)                      EXTENSIONS = $(ASM) $(BIN) $(COM) $(DEP) $(DLL) $(EXE) $(LIB) $(OBJ) $(PCH) $(SYS))

# Текущая конфигурация:
$(info )
$(info $(SPACE) HOST_PLATFORM HOST_ARCHITECTURE = $(HOST_PLATFORM) $(HOST_ARCHITECTURE))
$(info $(SPACE)                     HOST_SYSTEM = $(HOST_SYSTEM))

# Параметры сборки:
$(info )
$(info $(SPACE)        TARGET_INTERMEDIATE_PATH = $(TARGET_INTERMEDIATE_PATH))
$(info $(SPACE)              TARGET_OUTPUT_PATH = $(TARGET_OUTPUT_PATH))
$(info $(SPACE)                    TARGET_PATHS = $(TARGET_PATHS))
$(info $(SPACE)            TARGET_INCLUDE_PATHS = $(TARGET_INCLUDE_PATHS))
$(info $(SPACE)                TARGET_LIB_PATHS = $(TARGET_LIB_PATHS))
$(info $(SPACE)                TARGET_LIB_NAMES = $(TARGET_LIB_NAMES))
$(info $(SPACE)                  TARGET_PCH_C_* = $(TARGET_PCH_C_HEADER) $(TARGET_PCH_C_SOURCE) $(TARGET_PCH_C_OBJ) $(TARGET_PCH_C_PREREQUISITE))
$(info $(SPACE)                TARGET_PCH_CPP_* = $(TARGET_PCH_CPP_HEADER) $(TARGET_PCH_CPP_SOURCE) $(TARGET_PCH_CPP_OBJ) $(TARGET_PCH_CPP_PREREQUISITE))
$(info $(SPACE)                    TARGET_ENTRY = $(TARGET_ENTRY))

# Вычисленные параметры:
$(info )
$(info $(SPACE)                  TARGET_C_FILES = $(TARGET_C_FILES))
$(info $(SPACE)                TARGET_CPP_FILES = $(TARGET_CPP_FILES))
$(info $(SPACE)                TARGET_ASM_FILES = $(TARGET_ASM_FILES))
$(info $(SPACE)               TARGET_OBJS_FILES = $(TARGET_OBJS_FILES))
$(info $(SPACE)         TARGET_DEPENDENCY_FILES = $(TARGET_DEPENDENCY_FILES))

$(info )
$(info $(SPACE)            AR_PREFIX AR ARFLAGS = $(AR_PREFIX) $(AR) $(ARFLAGS))
$(info $(SPACE)            AS_PREFIX AS ASFLAGS = $(AS_PREFIX) $(AS) $(ASFLAGS))
$(info $(SPACE)             CC_PREFIX CC CFLAGS = $(CC_PREFIX) $(CC) $(CFLAGS))
$(info $(SPACE)         CXX_PREFIX CXX CXXFLAGS = $(CXX_PREFIX) $(CXX) $(CXXFLAGS))
$(info $(SPACE)            LD_PREFIX LD LDFLAGS = $(LD_PREFIX) $(LD) $(LDFLAGS))
$(info $(SPACE)                              RM = $(RM))

# Вычисленные цели, пререквизиты и рецепты:
$(info )
$(info $(SPACE)                      TARGET_C_* = $(TARGET_C): $(TARGET_C_PREREQUISITES))
$(info $(SPACE)                                   	$(TARGET_C_RECIPE))
$(info $(SPACE)                                   	$(TARGET_C_ASM_RECIPE))

$(info $(SPACE)                    TARGET_CPP_* = $(TARGET_CPP): $(TARGET_CPP_PREREQUISITES))
$(info $(SPACE)                                   	$(TARGET_CPP_RECIPE))
$(info $(SPACE)                                   	$(TARGET_CPP_ASM_RECIPE))

$(info $(SPACE)                    TARGET_ASM_* = $(TARGET_ASM): $(TARGET_ASM_PREREQUISITES))
$(info $(SPACE)                                   	$(TARGET_ASM_RECIPE))

$(info $(SPACE)                 TARGET_STATIC_* = $(TARGET_STATIC): $(TARGET_STATIC_PREREQUISITES))
$(info $(SPACE)                                   	$(TARGET_STATIC_RECIPE))

$(info $(SPACE)             TARGET_EXECUTABLE_* = $(TARGET_EXECUTABLE): $(TARGET_EXECUTABLE_PREREQUISITES))
$(info $(SPACE)                                   	$(TARGET_EXECUTABLE_RECIPE))

$(info $(SPACE)                 TARGET_BINARY_* = $(TARGET_BINARY):)
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
