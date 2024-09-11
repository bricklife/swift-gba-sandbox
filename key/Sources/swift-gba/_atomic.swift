//
// https://github.com/finnvoor/swift-gameboy-examples/blob/main/Examples/helloworld/game.swift
//

@_cdecl("__atomic_load_4")
func atomicLoad4(
    _ ptr: UnsafePointer<UInt32>,
    _ ordering: UInt32
) -> UInt32 {
    ptr.pointee
}

@_cdecl("__atomic_store_4")
func atomicStore4(
    _ ptr: UnsafeMutablePointer<UInt32>,
    _ value: UInt32,
    _ ordering: UInt32
) {
    ptr.pointee = value
}

@_cdecl("__atomic_store_2")
func atomicStore2(
    _ ptr: UnsafeMutablePointer<UInt16>,
    _ value: UInt16,
    _ ordering: UInt32
) {
    ptr.pointee = value
}

@_cdecl("__atomic_fetch_add_4")
func atomicFetchAdd4(
    _ ptr: UnsafeMutablePointer<UInt32>,
    _ value: UInt32,
    _ ordering: UInt32
) -> UInt32 {
    let tmp = ptr.pointee
    ptr.pointee += value
    return tmp
}

@_cdecl("__atomic_fetch_sub_4")
func atomicFetchSub4(
    _ ptr: UnsafeMutablePointer<UInt32>,
    _ value: UInt32,
    _ ordering: UInt32
) -> UInt32 {
    let tmp = ptr.pointee
    ptr.pointee -= value
    return tmp
}

@_cdecl("__atomic_compare_exchange_4")
func atomicCompareExchange4(
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
