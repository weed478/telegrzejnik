BUILD_DIR := build
OUT_DIR := out

CC := arm-none-eabi-gcc
LD := arm-none-eabi-ld
OBJCOPY := arm-none-eabi-objcopy
OBJDUMP := arm-none-eabi-objdump

SRCS := $(wildcard *.c *.s)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

CCFLAGS := -Wall -Werror -Os -nostdlib -mcpu=cortex-a72#+nosimd
CFLAGS := $(CCFLAGS) -ffreestanding -nostdinc -g
SFLAGS := $(CCFLAGS)
LDFLAGS := -nostdlib

.PHONY: all
all: $(OUT_DIR)/kernel.img $(OUT_DIR)/dump.txt

.PHONY: flash
flash: $(OUT_DIR)/kernel.img
	@echo 'Flashing...'
	@cp $< /Volumes/boot/kernel.img
	@echo 'Done'

.PHONY: dump
dump: $(OUT_DIR)/dump.txt
	@cat $<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) $(OUT_DIR)

$(BUILD_DIR)/%.c.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.s.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(SFLAGS) -c -o $@ $<

$(BUILD_DIR)/kernel.elf: $(OBJS) link.ld
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) $(OBJS) -T link.ld -o $@

$(OUT_DIR)/kernel.img: $(BUILD_DIR)/kernel.elf
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $< $@

$(OUT_DIR)/dump.txt: $(BUILD_DIR)/kernel.elf
	@$(OBJDUMP) -d $< > $@
