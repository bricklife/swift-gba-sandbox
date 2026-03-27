//
// https://github.com/finnvoor/swift-gameboy-examples/blob/main/Examples/helloworld/game.swift
//

@c
func __atomic_load_4(
    _ ptr: UnsafePointer<UInt32>,
    _ ordering: UInt32
) -> UInt32 {
    ptr.pointee
}

@c
func __atomic_load_2(
    _ ptr: UnsafePointer<UInt16>,
    _ ordering: UInt16
) -> UInt16 {
    ptr.pointee
}

@c
func __atomic_store_4(
    _ ptr: UnsafeMutablePointer<UInt32>,
    _ value: UInt32,
    _ ordering: UInt32
) {
    ptr.pointee = value
}

@c
func __atomic_store_2(
    _ ptr: UnsafeMutablePointer<UInt16>,
    _ value: UInt16,
    _ ordering: UInt32
) {
    ptr.pointee = value
}

@c
func __atomic_fetch_add_4(
    _ ptr: UnsafeMutablePointer<UInt32>,
    _ value: UInt32,
    _ ordering: UInt32
) -> UInt32 {
    let tmp = ptr.pointee
    ptr.pointee += value
    return tmp
}

@c
func __atomic_fetch_sub_4(
    _ ptr: UnsafeMutablePointer<UInt32>,
    _ value: UInt32,
    _ ordering: UInt32
) -> UInt32 {
    let tmp = ptr.pointee
    ptr.pointee -= value
    return tmp
}

@c
func __atomic_compare_exchange_4(
    _ ptr: UnsafeMutablePointer<UInt32>,
    _ expected: UnsafeMutablePointer<UInt32>,
    _ desired: UInt32,
    _ isWeak: Bool,
    _ successOrdering: UInt32,
    _ failureOrdering: UInt32
) -> Bool {
    if ptr.pointee == expected.pointee {
        ptr.pointee = desired
        return true
    } else {
        expected.pointee = ptr.pointee
        return false
    }
}
