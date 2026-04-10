struct Board {
  private var tiles: InlineArray<16, Int?>
  private var emptyPosition: (x: Int, y: Int)
}

extension Board {
  static var solved: Board {
    Board(
      tiles: [
        0, 1, 2, 3,
        4, 5, 6, 7,
        8, 9, 10, 11,
        12, 13, 14, nil,
      ],
      emptyPosition: (3, 3)
    )
  }
}

// MARK: - Access

extension Board {
  func piece(x: Int, y: Int) -> Int? {
    tiles[y * 4 + x]
  }

  mutating func setPiece(x: Int, y: Int, _ value: Int?) {
    tiles[y * 4 + x] = value
  }
}

// MARK: - Move

extension Board {
  func canMove(_ dir: Direction) -> Bool {
    switch dir {
    case .up: return emptyPosition.y < 3
    case .down: return emptyPosition.y > 0
    case .left: return emptyPosition.x < 3
    case .right: return emptyPosition.x > 0
    }
  }

  func sourcePosition(for dir: Direction) -> (x: Int, y: Int) {
    switch dir {
    case .up: return (emptyPosition.x, emptyPosition.y + 1)
    case .down: return (emptyPosition.x, emptyPosition.y - 1)
    case .left: return (emptyPosition.x + 1, emptyPosition.y)
    case .right: return (emptyPosition.x - 1, emptyPosition.y)
    }
  }

  mutating func move(_ dir: Direction) {
    let src = sourcePosition(for: dir)
    let p = piece(x: src.x, y: src.y)
    setPiece(x: emptyPosition.x, y: emptyPosition.y, p)
    setPiece(x: src.x, y: src.y, nil)
    emptyPosition = src
  }
}

// MARK: - State

extension Board {
  var isSolved: Bool {
    for i in 0..<15 {
      if i != tiles[i] {
        return false
      }
    }
    return tiles[15] == nil
  }
}
