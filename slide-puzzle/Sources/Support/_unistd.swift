nonisolated(unsafe) private var seed: UInt32 = 289301

private func rand() -> UInt16 {
  seed = 69069 &* seed &+ 1
  return UInt16(seed >> 16)
}

@c
func getentropy(
  _ ptr: UnsafeMutablePointer<UInt8>,
  _ size: Int
) -> Int {
  for i in stride(from: 0, to: size - 1, by: 2) {
    let r = rand()
    ptr[i] = UInt8(r & 0xff)
    ptr[i + 1] = UInt8(r >> 8)
  }
  if size % 2 == 1 {
    ptr[size - 1] = UInt8(rand() & 0xff)
  }
  return 0
}
