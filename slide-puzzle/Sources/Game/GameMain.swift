@main
struct GameMain {
  static let originX: UInt16 = 56
  static let originY: UInt16 = 8

  nonisolated(unsafe) static let oam = UnsafeMutablePointer<ObjectAttribute>(bitPattern: 0x0700_0000)!
  nonisolated(unsafe) static var sprites: InlineArray<16, ObjectAttribute> = .init(repeating: .init())

  nonisolated(unsafe) static var gameState = GameState.initial
  nonisolated(unsafe) static var movingOffset: UInt16 = 0

  static func initBg() {
    let bgPalettes = UnsafeMutablePointer<UInt16>(bitPattern: 0x0500_0000)!
    bgPalettes[0] = 0x7fff
    bgPalettes[1] = 0x0000

    var bg0Tiles = UnsafeMutablePointer<UInt16>(bitPattern: 0x6000000 + (0x4000 * 1))!
    bg0Tiles.update(repeating: 0x0000, count: 2 * 8)
    bg0Tiles = bg0Tiles.advanced(by: 2 * 8)

    bg0Tiles.update(repeating: 0x1111, count: 2 * 8)
    bg0Tiles = bg0Tiles.advanced(by: 2 * 8)

    for i in 0..<pressStartTiles.count {
      bg0Tiles[i] = pressStartTiles[i]
    }
    bg0Tiles = bg0Tiles.advanced(by: pressStartTiles.count)

    for i in 0..<congratulationsTiles.count {
      bg0Tiles[i] = congratulationsTiles[i]
    }

    let bg0Map = UnsafeMutablePointer<UInt16>(bitPattern: 0x6000000 + (0x800 * 0))!
    bg0Map.update(repeating: 0x0000, count: 32 * 32)

    let originX = Int(originX / 8)
    let originY = Int(originY / 8)
    for y in 0..<16 {
      for x in 0..<16 {
        bg0Map[(originY + y) * 32 + originX + x] = 0x0001
      }
    }

    REG_BG0CNT.store(BG_TILE_BASE(1) | BG_16_COLOR | BG_MAP_BASE(0) | BG_SIZE(0) | BG_PRIORITY(1))
  }

  static func updateBg() {
    let originX = Int(originX / 8)
    let originY = Int(originY / 8) + 16 + 1

    let bg0Map = UnsafeMutablePointer<UInt16>(bitPattern: 0x6000000 + (0x800 * 0))!
      .advanced(by: originY * 32 + originX)

    switch gameState.phase {
    case .initialized:
      for x in 0..<16 {
        bg0Map[x] = UInt16(x + 2)
      }
    case .solved:
      for x in 0..<16 {
        bg0Map[x] = UInt16(x + 2 + 16)
      }
    case .shuffling, .idle, .moving:
      for x in 0..<16 {
        bg0Map[x] = 0x0000
      }
    }
  }

  static func initSprites() {
    let objectPalettes = UnsafeMutablePointer<UInt16>(bitPattern: 0x0500_0200)!
    for i in 0..<logoPalette.count {
      objectPalettes[i] = logoPalette[i]
    }

    let objectTiles = UnsafeMutablePointer<UInt16>(bitPattern: 0x0601_0000)!
    for i in 0..<logoTiles.count {
      objectTiles[i] = logoTiles[i]
    }

    oam.update(repeating: ObjectAttribute(attr0: 0x0200), count: 128)

    for i in 0..<16 {
      sprites[i].attr1 = 0x8000  // Size: 32x32
      sprites[i].attr2 = UInt16(i * 16)  // Tile Number
      oam[i] = sprites[i]
    }
  }

  static func updateSprites() {
    for y in 0..<4 {
      for x in 0..<4 {
        let p = gameState.board.piece(x: x, y: y) ?? 15
        sprites[p].x = UInt16(x) * 32 + originX
        sprites[p].y = UInt16(y) * 32 + originY
      }
    }

    if let (p, dir) = gameState.moving {
      switch dir {
      case .up: sprites[p].y &-= movingOffset
      case .down: sprites[p].y &+= movingOffset
      case .right: sprites[p].x &+= movingOffset
      case .left: sprites[p].x &-= movingOffset
      }
    }

    if gameState.isPlaying {
      sprites[15].attr0 |= 0x0200
    } else {
      sprites[15].attr0 &= 0xfdff
    }

    for i in 0..<16 {
      oam[i] = sprites[i]
    }
  }

  static func waitForVsync() {
    while REG_VCOUNT.load() >= 160 {}
    while REG_VCOUNT.load() < 160 {}
  }

  static func main() {
    initBg()
    initSprites()

    updateBg()
    updateSprites()

    REG_DISPCNT.store(MODE_0 | OBJ_ENABLE | OBJ_1D_MAP | BG0_ENABLE)

    var keyCounter = KeyCounter()

    while true {
      waitForVsync()
      keyCounter.poll()

      switch gameState.phase {
      case .initialized, .solved:
        if keyCounter.start == 1 {
          gameState.startShuffle(times: 50)
        }
      case .shuffling:
        gameState.shuffleStep()
      case .idle:
        movingOffset = 0
        if keyCounter.up == 1 {
          gameState.tryMove(.up)
        } else if keyCounter.down == 1 {
          gameState.tryMove(.down)
        } else if keyCounter.right == 1 {
          gameState.tryMove(.right)
        } else if keyCounter.left == 1 {
          gameState.tryMove(.left)
        }
      case .moving:
        if movingOffset < 32 {
          movingOffset += 4
        } else {
          gameState.commitMove()
        }
      }

      updateBg()
      updateSprites()
    }
  }
}
