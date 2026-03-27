ifeq ($(strip $(GBA_LLVM)),)
$(error "Please set GBA_LLVM in your environment. export GBA_LLVM=<path to>/gba-llvm-devkit-1-Darwin-arm64")
endif

NAME := $(shell basename $(CURDIR))

# Paths
TOOLSET          := toolset.json
LLVM_OBJCOPY     := llvm-objcopy
SWIFT_BUILD      := swift build
GBAFIX           := $(GBA_LLVM)/bin/gbafix

# Flags
ARCH             := armv4t
TARGET           := $(ARCH)-none-none-eabi
SYSROOT          := $(GBA_LLVM)/lib/clang-runtimes/arm-none-eabi/armv4t
SWIFT_BUILD_ARGS := \
    --build-system native \
	--configuration release \
	--triple $(TARGET) \
	--toolset $(TOOLSET) \
	$(addprefix -Xswiftc , $(addprefix -Xclang-linker ,--sysroot $(SYSROOT)))
BUILDROOT        := $(shell $(SWIFT_BUILD) $(SWIFT_BUILD_ARGS) --show-bin-path)

.PHONY: build
build:
	@echo "building..."
	$(SWIFT_BUILD) \
		$(SWIFT_BUILD_ARGS) \
		--verbose

	@echo "extracting binary..."
	$(LLVM_OBJCOPY) \
		-O binary \
		"$(BUILDROOT)/Game" \
		"$(NAME).gba"
	$(GBAFIX) "$(NAME).gba"


.PHONY: clean
clean:
	@echo "cleaning..."
	@swift package clean
	@rm -rf .build
