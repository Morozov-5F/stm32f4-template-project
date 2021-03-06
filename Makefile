CROSS_COMPILE?=/opt/gcc-arm-none-eabi-5_4-2016q3/bin/arm-none-eabi-
CC=gcc
LD=gcc
OBJCOPY=objcopy
RM=rm -rf
MKDIR=mkdir -p
OCD=openocd
SCREEN=screen
SCRIPTS_DIR=scripts
SCREENRC=debug.screenrc

.PHONY: clean flash debug release

BOARD_TYPE=STM32F407xx

CFLAGS_DEBUG   = -g -O0
CFLAGS_RELEASE = -Os

CFLAGS  = --specs=nosys.specs -Wall -mcpu=cortex-m4 -mlittle-endian -mthumb -D$(BOARD_TYPE) -DOS_USE_TRACE_ITM
CFLAGS += $(CFLAGS_DEBUG)

LDFLAGS = -mcpu=cortex-m4 -mlittle-endian -D$(BOARD_TYPE) -mthumb -Tlinker/STM32F407VG_FLASH.ld -Wl,--gc-sections --specs=rdimon.specs -lc -lrdimon

I_PATH = include

OUTPUT_DIR = bin
FLASH_NAME = flash

COMPILE = $(CROSS_COMPILE)$(CC) $(CFLAGS) -I$(I_PATH) -MD -c $< -o $@
LINK    = $(CROSS_COMPILE)$(LD) $(LDFLAGS) $(OBJECT_FILES) -o $(OUTPUT_DIR)/$(FLASH_NAME).elf
CONVERT = $(CROSS_COMPILE)$(OBJCOPY) -Oihex $(OUTPUT_DIR)/$(FLASH_NAME).elf $(OUTPUT_DIR)/$(FLASH_NAME).hex

PRJ_C_SRC_DIRS  = src
PRJ_C_SRC_DIRS += src/trace

OBJECT_FILES += $(patsubst %.c, %.o, $(wildcard $(addsuffix /*.c, $(PRJ_C_SRC_DIRS))))
OBJECT_FILES += $(patsubst %.s, %.o, $(wildcard $(addsuffix /*.s, $(PRJ_C_SRC_DIRS))))

TOREMOVE += $(addsuffix /*.o, $(PRJ_C_SRC_DIRS))
TOREMOVE += $(addsuffix /*.d, $(PRJ_C_SRC_DIRS))
TOREMOVE_ALL += $(addsuffix /*.elf, $(OUTPUT_DIR))
TOREMOVE_ALL += $(addsuffix /*.hex, $(OUTPUT_DIR))

PWD=`pwd`

LOAD_IMAGE_CMD = "flash write_image erase $(OUTPUT_DIR)/$(FLASH_NAME).hex"
VERIFY_IMAGE_CMD = "verify_image $(OUTPUT_DIR)/$(FLASH_NAME).hex"
OPENOCD_SCRIPT ?= /usr/share/openocd/scripts/board/stm32f4discovery.cfg
OPENOCD_STARTUP =\
-c "init"\
-c "halt"\
-c $(LOAD_IMAGE_CMD)\
-c $(VERIFY_IMAGE_CMD)\
-c "reset run"\
-c "shutdown"\

image: $(OBJECT_FILES)
	@echo "Linking image $(FLASH_NAME).elf"
	@$(MKDIR) $(OUTPUT_DIR)
	$(LINK)
	@echo "Assembling final image $(FLASH_NAME).hex"
	$(CONVERT)

burn: image
	$(OCD) -f$(OPENOCD_SCRIPT) $(OPENOCD_STARTUP)

%.o: %.c
	@echo "Compiling C file:   " $<
	@$(COMPILE)

%.o: %.s
	@echo "Compiling ASM file: " $<
	@$(COMPILE)

clean:
	@echo "Cleaning: " $(TOREMOVE)
	@$(RM) $(TOREMOVE)

clean_all: clean
	@echo "Removing image files: " $(TOREMOVE_ALL)
	@$(RM) $(TOREMOVE_ALL)

debug:
	(cd $(SCRIPTS_DIR) && $(SCREEN) -c $(SCREENRC))

info:
	@echo "### Diagnostic info ###"
	@echo "Project directories:" $(PRJ_C_SRC_DIRS)
	@echo "Image name: " $(FLASH_NAME)
	@echo "C Files:        " $(wildcard  $(addsuffix /*.c, $(PRJ_C_SRC_DIRS))) $(C_FILES)
	@echo "Assembly files: " $(wildcard  $(addsuffix /*.s, $(PRJ_C_SRC_DIRS)))
	@echo "Object files:   " $(OBJECT_FILES)
	@echo "C compiler:     " $(CROSS_COMPILE)$(CC)
	@echo "Linker:         " $(CROSS_COMPILE)$(LD)
	@echo "Convert tool:   " $(CROSS_COMPILE)$(OBJCOPY)
	@echo "Include path:   " $(I_PATH)
	@echo "LD flags:       " $(LDFLAGS)
	@echo "CC flags:       " $(CFLAGS)
	@echo "Compile cmd:    " $(COMPILE)
