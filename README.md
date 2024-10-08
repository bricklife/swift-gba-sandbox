# swift-gba-sandbox

Game Boy Advance ROM projects written in Embedded Swift.

## Building the Projects

1. Download and install a Swift nightly toolchain from [the Swift.org downloads page](https://www.swift.org/download/#snapshots).
2. Download `gba-llvm-devkit` from the [releases page](https://github.com/stuij/gba-llvm-devkit/releases).
3. Set `GBA_LLVM` in your environment to the path to the downloaded devkit (`export GBA_LLVM=<path to>/gba-llvm-devkit-1-Darwin-arm64`).
4. `cd` into one of the projects and run `make`.
5. Open the compiled `.gba` rom in a Game Boy emulator, e.g. [mGBA](https://mgba.io).

## Resources
This repository is based on information from the following URLs:

- https://speakerdeck.com/k_koheyi/draft
- https://github.com/k-kohey/swift-gba-samples/
- https://github.com/finnvoor/swift-gameboy-examples/
- https://akkera102.sakura.ne.jp/gbadev/
- https://gbadev.net/tonc/
