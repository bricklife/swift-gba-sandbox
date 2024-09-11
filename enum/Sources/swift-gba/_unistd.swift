@_cdecl("getentropy")
func getentropy(
    _ ptr: UnsafeMutablePointer<UInt8>,
    _ size: Int
) -> Int {
    ptr.update(repeating: 0, count: size)
    return 0
}
