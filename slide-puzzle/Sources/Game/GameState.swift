struct GameState {
  enum Phase: UInt8 {
    case initialized
    case shuffling
    case idle
    case moving
    case solved
  }

  var phase: Phase
  var board: Board

  // Move
  var moving: (Int, Direction)?

  // Shuffle
  var shuffleRemaining: Int = 0
  var lastDir: Direction?
}

extension GameState {
  static var initial: GameState {
    GameState(
      phase: .initialized,
      board: .solved
    )
  }

  var isPlaying: Bool {
    switch phase {
    case .initialized, .solved:
      false
    case .shuffling, .idle, .moving:
      true
    }
  }
}

// MARK: - Move

extension GameState {
  mutating func tryMove(_ dir: Direction) {
    guard board.canMove(dir) else { return }
    let src = board.sourcePosition(for: dir)
    guard let p = board.piece(x: src.x, y: src.y) else { return }
    moving = (p, dir)
    phase = .moving
  }

  mutating func commitMove() {
    guard let (_, dir) = moving else { return }
    board.move(dir)
    moving = nil
    if board.isSolved {
      phase = .solved
    } else {
      phase = .idle
    }
  }
}

// MARK: - Shuffle

extension GameState {
  mutating func startShuffle(times: Int) {
    shuffleRemaining = times
    phase = .shuffling
  }

  mutating func shuffleStep() {
    if shuffleRemaining > 0 {
      while true {
        let dir = Direction.allCases.randomElement()!
        guard board.canMove(dir), dir != lastDir?.opposite else {
          continue
        }
        board.move(dir)
        lastDir = dir
        shuffleRemaining -= 1
        break
      }
    } else {
      lastDir = nil
      phase = .idle
    }
  }
}
