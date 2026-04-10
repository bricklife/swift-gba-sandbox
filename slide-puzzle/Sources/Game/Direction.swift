enum Direction: UInt8, CaseIterable {
  case up
  case down
  case left
  case right
}

extension Direction {
  var opposite: Direction {
    switch self {
    case .up: return .down
    case .down: return .up
    case .left: return .right
    case .right: return .left
    }
  }
}
