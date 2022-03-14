BUILD_DIR := build
OUT_DIR := out

LLVMPATH := /opt/homebrew/opt/llvm/bin
CC := $(LLVMPATH)/clang --target=aarch64-elf
LD := $(LLVMPATH)/ld.lld -m aarch64elf
OBJCOPY := $(LLVMPATH)/llvm-objcopy
OBJDUMP := $(LLVMPATH)/llvm-objdump

SRCS := $(wildcard *.c *.s)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

CCFLAGS := -Wall -Werror -Os -nostdlib -mcpu=cortex-a72+nosimd
CFLAGS := $(CCFLAGS) -ffreestanding -nostdinc -g
SFLAGS := $(CCFLAGS)
LDFLAGS := -nostdlib

.PHONY: all
all: $(OUT_DIR)/kernel8.img

.PHONY: flash
flash: $(OUT_DIR)/kernel8.img
	@echo 'Flashing...'
	@cp $< /Volumes/boot/kernel8.img
	@echo 'Done'

.PHONY: dump
dump: $(BUILD_DIR)/kernel8.elf
	@$(OBJDUMP) -d $<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) $(OUT_DIR)

$(BUILD_DIR)/%.c.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.s.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(SFLAGS) -c -o $@ $<

$(BUILD_DIR)/kernel8.elf: $(OBJS) link.ld
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) $(OBJS) -T link.ld -o $@

$(OUT_DIR)/kernel8.img: $(BUILD_DIR)/kernel8.elf
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $< $@
