ifeq ($(strip $(GBA_LLVM)),)
$(error "Please set GBA_LLVM in your environment. export GBA_LLVM=<path to>/gba-llvm-devkit-1-Darwin-arm64")
endif
TOOLCHAIN ?= /Library/Developer/Toolchains/swift-latest.xctoolchain

NAME := $(shell basename $(CURDIR))

BIN = $(GBA_LLVM)/bin
SWIFTC = $(TOOLCHAIN)/usr/bin/swiftc

SWIFT_FLAGS = -wmo -enable-experimental-feature Embedded -target armv4t-none-none-eabi -parse-as-library -Xfrontend -internalize-at-link -lto=llvm-thin -Xfrontend -disable-stack-protector -Xfrontend -disable-objc-interop
CFLAGS = -mthumb -mfpu=none -fno-exceptions -fno-rtti -D_LIBCPP_AVAILABILITY_HAS_NO_VERBOSE_ABORT -fshort-enums
SYSROOT = $(GBA_LLVM)/lib/clang-runtimes/arm-none-eabi/armv4t
LFLAGS = -lcrt0-gba
CLANG_LINKER_FLAGS = -T gba_cart.ld --sysroot $(SYSROOT) -fuse-ld=lld

SRC_DIRS = $(shell find Sources -type d)
SWIFT_FILES = $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.swift))
SWIFT_OBJ_FILES = $(SWIFT_FILES:.swift=.o)

all: $(NAME).gba

$(NAME).gba: $(NAME).elf
	$(BIN)/llvm-objcopy -O binary $^ $@
	$(BIN)/gbafix $@

$(NAME).elf: $(SWIFT_FILES)
	$(SWIFTC) -o $@ $(SWIFT_FILES) \
		$(SWIFT_FLAGS) $(addprefix -Xcc , $(CFLAGS)) \
		$(addprefix -Xlinker , $(LFLAGS)) \
		$(addprefix -Xclang-linker , $(CLANG_LINKER_FLAGS))

run: $(NAME).gba
	make
	mGBA $<

.PHONY: all clean run
clean:
	rm -f *.o *.elf *.gba *.bc
