BUILD_DIR := build
OUT_DIR := out

TOOLCHAIN := arm-none-eabi
CC := $(TOOLCHAIN)-gcc
LD := $(TOOLCHAIN)-ld
OBJCOPY := $(TOOLCHAIN)-objcopy
OBJDUMP := $(TOOLCHAIN)-objdump

SRCS := $(wildcard *.c *.S)
HDRS := $(wildcard *.h)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

OLEVEL := 0

# BCM2836
# CPU := cortex-a53
# BCM := 2836

# BCM2711
CPU := cortex-a72
BCM := 2711

CCFLAGS := -Wall -Werror -O$(OLEVEL) -nostdlib -mcpu=$(CPU) -DBCM$(BCM)
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
