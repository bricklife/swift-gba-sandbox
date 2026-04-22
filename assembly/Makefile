NAME := $(shell basename $(CURDIR))

# Paths
TOOLSET          := toolset.json
LLVM_OBJCOPY     := llvm-objcopy
SWIFT_BUILD      := swift build

# Flags
ARCH             := armv4t
TARGET           := $(ARCH)-none-none-eabi
SWIFT_BUILD_ARGS := \
	--build-system native \
	--configuration release \
	--triple $(TARGET) \
	--toolset $(TOOLSET)
BUILDROOT        := $(shell $(SWIFT_BUILD) $(SWIFT_BUILD_ARGS) --show-bin-path)

.PHONY: build
build:
	@echo "building cartridge image..."
	$(SWIFT_BUILD) \
		$(SWIFT_BUILD_ARGS) \
		-Xlinker -T -Xlinker gba_cart.ld \
		--verbose

	@echo "extracting binary..."
	$(LLVM_OBJCOPY) \
		-O binary \
		"$(BUILDROOT)/Game" \
		"$(NAME).gba"

.PHONY: clean
clean:
	@echo "cleaning..."
	@swift package clean
	@rm -rf .build
