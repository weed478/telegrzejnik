BUILD_DIR := build
OUT_DIR := out

LLVM_PATH := /opt/homebrew/opt/llvm/bin
CC := $(LLVM_PATH)/clang --target=arm-arm-none-eabi
LD := $(CC)
OBJCOPY := $(LLVM_PATH)/llvm-objcopy
OBJDUMP := $(LLVM_PATH)/llvm-objdump

SRCS := $(wildcard *.c *.S)
HDRS := $(wildcard *.h)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

OLEVEL := s

# BCM2836
# CPU := cortex-a53
# BCM2711
CPU := cortex-a72

CCFLAGS := -Wall -Werror -O$(OLEVEL) -nostdlib -mcpu=$(CPU)+nofp+nomve -mfpu=none
CFLAGS := $(CCFLAGS) -ffreestanding -nostdinc
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

$(BUILD_DIR)/%.c.o: %.c $(HDRS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.S.o: %.S
	@mkdir -p $(dir $@)
	$(CC) $(SFLAGS) -c -o $@ $<

$(BUILD_DIR)/kernel.elf: $(OBJS) link.ld
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) $(OBJS) -T link.ld -o $@

$(OUT_DIR)/kernel.img: $(BUILD_DIR)/kernel.elf
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $< $@

$(OUT_DIR)/dump.txt: $(BUILD_DIR)/kernel.elf
	@mkdir -p $(dir $@)
	@$(OBJDUMP) -d $< > $@
