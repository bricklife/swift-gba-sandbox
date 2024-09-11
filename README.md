# swift-gba-sandbox

## Building the Examples

1. Download and install a Swift nightly toolchain from [the Swift.org downloads page](https://www.swift.org/download/#snapshots).
2. Download `gba-llvm-devkit` from the [releases page](https://github.com/stuij/gba-llvm-devkit/releases).
3. Set `GBA_LLVM` in your environment to the path to the downloaded devkit (`export GBA_LLVM=<path to>/gba-llvm-devkit-1-Darwin-arm64`).
4. `cd` into one of the examples and run `make`.
5. Open the compiled `.gba` rom in a Game Boy emulator.

## Resources
This repository is based on information from the following URLs:

- https://github.com/k-kohey/swift-gba-samples/
- https://github.com/finnvoor/swift-gameboy-examples/
- https://akkera102.sakura.ne.jp/gbadev/
- https://gbadev.net/tonc/
