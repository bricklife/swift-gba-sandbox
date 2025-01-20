#if canImport(_Volatile)
import _Volatile
typealias VolatileMappedRegister = _Volatile.VolatileMappedRegister
#else
// https://github.com/swiftlang/swift/blob/main/stdlib/public/Volatile/Volatile.swift
public struct VolatileMappedRegister<Pointee> {
    let unsafeBitPattern: UInt
    
    public init(unsafeBitPattern: UInt) {
        self.unsafeBitPattern = unsafeBitPattern
    }
    
    public func load() -> Pointee where Pointee: UnsignedInteger {
        UnsafePointer<Pointee>(bitPattern: unsafeBitPattern)!.pointee
    }
      
    public func store(_ value: Pointee) where Pointee: UnsignedInteger {
        UnsafeMutablePointer<Pointee>(bitPattern: unsafeBitPattern)!.pointee = value
    }
}
#endif
