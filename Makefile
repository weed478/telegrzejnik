BUILD_DIR := build
OUT_DIR := out

LLVMPATH := /opt/homebrew/opt/llvm/bin
CC := $(LLVMPATH)/clang --target=aarch64-elf
LD := $(LLVMPATH)/ld.lld -m aarch64elf
OBJCOPY := $(LLVMPATH)/llvm-objcopy

SRCS := $(wildcard *.c *.S)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

CCFLAGS := -Wall -Werror -O2 -ffreestanding -nostdinc -nostdlib -mcpu=cortex-a72+nosimd
LDFLAGS := -nostdlib

.PHONY: all
all: $(OUT_DIR)/kernel8.img

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) $(OUT_DIR)

$(BUILD_DIR)/%.o: %
	@mkdir -p $(dir $@)
	$(CC) $(CCFLAGS) -c -o $@ $<

$(BUILD_DIR)/kernel8.elf: $(OBJS) link.ld
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) $(OBJS) -T link.ld -o $@

$(OUT_DIR)/kernel8.img: $(BUILD_DIR)/kernel8.elf
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $< $@
