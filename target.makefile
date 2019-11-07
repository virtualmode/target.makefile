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
#	TARGET_ARCHITECTURE - preferred architecture to build output binary file (default: $(HOST_ARCHITECTURE)):
#		amd64
#		arm
#		x86
#	TARGET_PLATFORM - additional architecture features.
#	TARGET_OS - operating system specific headers for target (default: $(HOST_OS)):
#		none - clean architecture code without headers.
#		windows - known operating system.
#		posix - POSIX-compatible operating system.

#	TARGET_PATHS - additional paths that contains sources for assembling. Used to get target within this make instance.
#	TARGET_INTERMEDIATE_PATH - target path with intermediate build data.
#	TARGET_OUTPUT_PATH - output path with target and its resources.

#	TARGET_INCLUDE_PATHS - paths with additional headers.
#	TARGET_LIB_PATHS - paths with static libraries. You can include intermediate path also.
#	TARGET_LIB_NAMES - static library names used in build.

#	TARGET_PCH_C_HEADER - C header relative path for PCH.
#	TARGET_PCH_C_SOURCE - relative path of the C source file to compile as PCH.
#	TARGET_PCH_CPP_HEADER - CPP header relative path for PCH.
#	TARGET_PCH_CPP_SOURCE - relative path of the CPP source file to compile as PCH.

#	TARGET_ENTRY - optional variable with entry point name for executable binaries.


# Automatically initialized macroses that can be used:
#	EXT_EXE - executable file extension.
#	EXT_OBJ - object file extension.
#	EXT_DLL - dynamic link library extension.
#	EXT_LIB - static library extension.
#	EXT_PCH - precompiled header file extension.
#	EXT_ASM - assembler listing file extension.
#	EXT_BIN - unknown binary file extension.

#	HOST_ARCHITECTURE - current architecture.
#	HOST_OS - current operating system.

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


# Obsolete or unused macroses:
#	CPP - program for running the C PreProcessor, with results to standard output (default: $(CC) -E).
#	CPPFLAGS - flags for the C PreProcessor.
#	CO - name of the program that extracts a file from RCS (default: co).
#	COFLAGS - flags for the RCS co program.
#	FC - name of the FORTRAN compiler (default: f77).
#	FFLAGS - flags for the FORTRAN compiler.
#	RM - name of the command to delete a file (default: rm -f).
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
ML_VERSIONS = 001 008
# CC/CXX компиляторы C/C++:
CL_VERSION = $(shell $(CC) 2>&1 | $(PARSE_MAJOR_VERSION))
CL_VERSIONS = 001 010
GCC_VERSION = $(shell $(CC) --version 2>&1 | $(PARSE_MAJOR_VERSION))
GCC_VERSIONS = 001
# LD компоновщики:
LINK_VERSION = $(shell $(LD) /HELP 2>&1 | $(PARSE_MAJOR_VERSION))
LINK_VERSIONS = 001 010

# Общие флаги пакета компиляторов MSVC:
MSVC_INCLUDE_FLAGS := $(addsuffix ",$(addprefix /I",$(TARGET_INCLUDE_PATHS)))
MSVC_LIB_PATHS_FLAGS := $(addsuffix ",$(addprefix /LIBPATH:",$(TARGET_LIB_PATHS)))
MSVC_LIB_NAMES_FLAGS := $(addsuffix $(EXT_LIB)",$(addprefix ",$(TARGET_LIB_NAMES)))

# Флаги компиляторов Microsoft Visual Studio 1.XX для сборки и в 16-битном режиме:
# Данные программы проверены, предсказуемы и наиболее оптимизированы в отличие от современных наборов.
LIB001_DEBUG := /VERBOSE
LIB001_RELEASE := /VERBOSE

CL001_DEBUG := /AT /G2 /Gs /Gx /c /Zl
CL001_RELEASE := /AT /G2 /Gs /Gx /c /Zl

LINK001_DEBUG := /T /NOD
LINK001_RELEASE := /T /NOD

ML001_DEBUG := /AT /c
ML001_RELEASE := /AT /c

# Флаги актуальной версии MSVC для сборки цели.
# Компиляторы Microsoft не поддерживают флаги для компиляции под определённую архитектуру процессора.
# Для сборки необходимо запустить определённый экземпляр компилятора, установив переменную окружения.
CL010_DEBUG := /c $(MSVC_INCLUDE_FLAGS) /GS /W3 /Zc:wchar_t /ZI /Gm /Od /Fd"$(TARGET_INTERMEDIATE_PATH)vc141.pdb" /Zc:inline /fp:precise /D "_DEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /errorReport:prompt /WX- /Zc:forScope /RTC1 /Gd /Oy- /MDd /EHsc /nologo /diagnostics:classic
CL010_RELEASE := /c $(MSVC_INCLUDE_FLAGS) /GS- /GL /W3 /Gy /Zc:wchar_t /Zi /Gm- /O2 /Fd"$(TARGET_INTERMEDIATE_PATH)vc141.pdb" /Zc:inline /fp:precise /D "NDEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /errorReport:prompt /WX- /Zc:forScope /Gd /Oy- /Oi /MD /EHsc /nologo /diagnostics:classic

LINK010_DEBUG := /OUT:"$(SRC_OUTPUT_TARGET)" /ERRORREPORT:PROMPT /NOLOGO /SUBSYSTEM:WINDOWS
LINK010_RELEASE := /OUT:"$(SRC_OUTPUT_TARGET)" /ERRORREPORT:PROMPT /NOLOGO /SUBSYSTEM:WINDOWS /LTCG:incremental /NODEFAULTLIB

LINK010_DEBUG_EXE := $(MSVC_LIB_PATHS_FLAGS) $(MSVC_LIB_NAMES_FLAGS) "ucrtd.lib" "vcruntimed.lib" "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" /INCREMENTAL /DEBUG:FASTLINK
LINK010_RELEASE_EXE := $(MSVC_LIB_PATHS_FLAGS) $(MSVC_LIB_NAMES_FLAGS) "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" /INCREMENTAL:NO /OPT:REF /SAFESEH:NO /OPT:ICF

LINK010_X86 := /MACHINE:X86
LINK010_AMD64 := /MACHINE:X64

LINK010_AMD64_EXE := /ALIGN:16 /DRIVER
LINK010_EXE := /MANIFEST:NO /NXCOMPAT /PDB:"$(BUILD_INTERMEDIATE_PATH)src.pdb" /DYNAMICBASE /ENTRY:"$(SRC_ENTRY)" /MERGE:".rdata=.text" /TLBID:1

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
# @return Минимальная поддерживаемая версия из множества. Пустое значение, если версия не поддерживается.
CHECK_VERSION = $(if $(filter $2,$(word 2,$1)),$(word 1,$1),$(call CHECK_VERSION,$(wordlist 2,$(words $1),$1),$2))

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


# Определение текущей операционной системы и архитектуры:
ifeq ($(OS),Windows_NT)
	HOST_OS := windows
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		HOST_ARCHITECTURE := amd64
	else ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		HOST_ARCHITECTURE := amd64
	else ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		HOST_ARCHITECTURE := x86
	endif

else
	# Предположительно POSIX операционная система:
	UNAME_S := $(shell uname -s)
	UNAME_P := $(shell uname -p)
	ifneq ($(filter Linux Darwin,$(UNAME_S)),)
		HOST_OS := posix;
	endif
	ifeq ($(UNAME_P),x86_64)
		HOST_ARCHITECTURE := amd64
	else ifneq ($(filter %86, $(UNAME_P)),)
		HOST_ARCHITECTURE := x86
	else ifneq ($(filter arm%,$(UNAME_P)),)
		HOST_ARCHITECTURE := arm
	endif
endif

# Setup default parameters:
ifeq ($(CONFIGURATION),)
	CONFIGURATION := release
endif

ifeq ($(TARGET_OS),)
	TARGET_OS := $(HOST_OS)
endif
ifeq ($(TARGET_ARCHITECTURE),)
	TARGET_ARCHITECTURE := $(HOST_ARCHITECTURE)
endif

# TODO: Добавление текущего каталога в списки может оказаться необязательным.
ifdef TARGET_PATHS
	TARGET_PATHS := ./ $(TARGET_PATHS)
else
	TARGET_PATHS := ./
endif
ifdef TARGET_INCLUDE_PATHS
	TARGET_INCLUDE_PATHS := ./ $(TARGET_INCLUDE_PATHS)
else
	TARGET_INCLUDE_PATHS := ./
endif
ifdef TARGET_LIB_PATHS
	TARGET_LIB_PATHS := ./ $(TARGET_LIB_PATHS)
else
	TARGET_LIB_PATHS := ./
endif


# Определение общепринятых расширений, которые нежелательно трактовать как-то по-другому:
EXT_BIN := .bin
EXT_COM := .com
EXT_DEP := .d
EXT_SYS := .sys
# Установка расширений по умолчанию для поддерживаемых типов файлов:
EXT_ASM :=
EXT_DLL :=
EXT_EXE :=
EXT_LIB :=
EXT_OBJ :=
EXT_PCH :=

# Настройка сборки под выбранную платформу:
ifeq ($(TARGET_OS),none)
	# Расширения абстрактной операционной системы:
	EXT_ASM := .a
	EXT_BIN := .b
	EXT_DLL := .s
	EXT_LIB := .l
	EXT_OBJ := .o
	EXT_PCH := .p
	# Для сборки низкоуровнего кода под определённое оборудование подходят более старые компиляторы. Чтобы их использовать,
	# необходимо вручную сменить переменные с настройками, или перед запуском сборки установить переменную окружения PATH.
	ifeq ($(HOST_OS),windows)
		DEFAULT_TOOLS := $(DEFAULT_TOOLS_WINDOWS)
	else
		DEFAULT_TOOLS := $(DEFAULT_TOOLS_POSIX)
	endif

else ifeq ($(TARGET_OS),windows)
	EXT_ASM := .asm
	EXT_DLL := .dll
	EXT_EXE := .exe
	EXT_LIB := .lib
	EXT_OBJ := .obj
	EXT_PCH := .pch
	# Выбор компиляторов по умолчанию:
	ifeq ($(HOST_OS),windows)
		DEFAULT_TOOLS := $(DEFAULT_TOOLS_WINDOWS)
	else
		DEFAULT_TOOLS := $(DEFAULT_TOOLS_POSIX)
	endif

else
	EXT_ASM := .s
	EXT_DLL := .so
	EXT_LIB := .a
	EXT_OBJ := .o
	EXT_PCH := .gch
	DEFAULT_TOOLS := $(DEFAULT_TOOLS_POSIX)

endif

# Настройка всех поддерживаемых утилит. Если программа сборки не поддерживает эти конструкции,
# необходимо закомментировать и настроить флаги вручную.
$(eval $(call SET_TOOLS,$(DEFAULT_TOOLS)))

$(info DEBUG = $(CC_PREFIX) $(CFLAGS))


# Подготовка сборки произведена. Есть смысл вывести отладочную информацию:
ifdef DEBUG
$(info ) # Конфигурация и направление сборки.
$(info $(SPACE)            CONFIGURATION = $(CONFIGURATION))
$(info $(SPACE)        HOST_ARCHITECTURE = $(HOST_ARCHITECTURE))
$(info $(SPACE)                  HOST_OS = $(HOST_OS))
$(info $(SPACE)      TARGET_ARCHITECTURE = $(TARGET_ARCHITECTURE))
$(info $(SPACE)                TARGET_OS = $(TARGET_OS))
$(info $(SPACE)                  EXT_XXX = $(EXT_BIN) $(EXT_COM) $(EXT_DEP) $(EXT_SYS) $(EXT_ASM) $(EXT_DLL) $(EXT_EXE) $(EXT_LIB) $(EXT_OBJ) $(EXT_PCH))
$(info ) # Параметры сборки.
$(info $(SPACE)             TARGET_PATHS = $(TARGET_PATHS))
$(info $(SPACE) TARGET_INTERMEDIATE_PATH = $(TARGET_INTERMEDIATE_PATH))
$(info $(SPACE)       TARGET_OUTPUT_PATH = $(TARGET_OUTPUT_PATH))
$(info $(SPACE)     TARGET_INCLUDE_PATHS = $(TARGET_INCLUDE_PATHS))
$(info $(SPACE)         TARGET_LIB_PATHS = $(TARGET_LIB_PATHS))
$(info $(SPACE)         TARGET_LIB_NAMES = $(TARGET_LIB_NAMES))
$(info $(SPACE)      TARGET_PCH_C_HEADER = $(TARGET_PCH_C_HEADER))
$(info $(SPACE)      TARGET_PCH_C_SOURCE = $(TARGET_PCH_C_SOURCE))
$(info $(SPACE)    TARGET_PCH_CPP_HEADER = $(TARGET_PCH_CPP_HEADER))
$(info $(SPACE)    TARGET_PCH_CPP_SOURCE = $(TARGET_PCH_CPP_SOURCE))
$(info $(SPACE)             TARGET_ENTRY = $(TARGET_ENTRY))
$(info ) # Вычисленные параметры.

$(info $(SPACE)                       AR = $(AR) $(ARFLAGS))
$(info $(SPACE)                       AS = $(AS) $(ASFLAGS))
$(info $(SPACE)                       CC = $(CC) $(CFLAGS))
$(info $(SPACE)                      CXX = $(CXX) $(CXXFLAGS))
$(info $(SPACE)                       LD = $(LD) $(LDFLAGS))
$(info $(SPACE)                      CPP = $(CPP) $(CPPFLAGS))
$(info $(SPACE)                       CO = $(CO) $(COFLAGS))
$(info $(SPACE)                       FC = $(FC) $(FFLAGS))
$(info $(SPACE)                       RM = $(RM))
endif


# A phony target is one that is not really the name of a file.

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
