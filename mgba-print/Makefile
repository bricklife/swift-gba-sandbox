ifeq ($(strip $(GBA_LLVM)),)
$(error "Please set GBA_LLVM in your environment. export GBA_LLVM=<path to>/gba-llvm-devkit-1-Darwin-arm64")
endif

NAME := $(shell basename $(CURDIR))

BIN = $(GBA_LLVM)/bin

SWIFT_FLAGS = -O -wmo -enable-experimental-feature Embedded -enable-experimental-feature Volatile -target armv4t-none-none-eabi -parse-as-library -lto=llvm-thin -Xfrontend -internalize-at-link -Xfrontend -disable-stack-protector -Xfrontend -disable-objc-interop
CFLAGS = -marm -mfpu=none -fno-exceptions -fno-rtti -D_LIBCPP_AVAILABILITY_HAS_NO_VERBOSE_ABORT -fshort-enums
SYSROOT = $(GBA_LLVM)/lib/clang-runtimes/arm-none-eabi/armv4t
LFLAGS = -lcrt0-gba -lc
CLANG_LINKER_FLAGS = -T gba_cart.ld --sysroot $(SYSROOT) -nostdlib -fuse-ld=lld

SRC_DIRS = $(shell find Sources -type d)
SWIFT_FILES = $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.swift))
SWIFT_OBJ_FILES = $(SWIFT_FILES:.swift=.o)

all: $(NAME).gba

$(NAME).gba: $(NAME).elf
	$(BIN)/llvm-objcopy -O binary $^ $@
	$(BIN)/gbafix $@

$(NAME).elf: $(SWIFT_FILES)
	swiftc -o $@ $(SWIFT_FILES) \
		$(SWIFT_FLAGS) $(addprefix -Xcc , $(CFLAGS)) \
		$(addprefix -Xlinker , $(LFLAGS)) \
		$(addprefix -Xclang-linker , $(CLANG_LINKER_FLAGS))

run: $(NAME).gba
	make
	mGBA $<

.PHONY: all clean run
clean:
	rm -f *.o *.elf *.gba *.bc
