struct Key: OptionSet {
    let rawValue: UInt16
    
    static let a        = Self(rawValue: 1 << 0)
    static let b        = Self(rawValue: 1 << 1)
    static let select   = Self(rawValue: 1 << 2)
    static let start    = Self(rawValue: 1 << 3)
    static let right    = Self(rawValue: 1 << 4)
    static let left     = Self(rawValue: 1 << 5)
    static let up       = Self(rawValue: 1 << 6)
    static let down     = Self(rawValue: 1 << 7)
    static let r        = Self(rawValue: 1 << 8)
    static let l        = Self(rawValue: 1 << 9)
    
    static let all      = Self(rawValue: 0x03ff)
    
    static func poll() -> Self {
        let REG_KEYINPUT = UnsafePointer<UInt16>(bitPattern: 0x04000130)!
        return Self(rawValue: ~REG_KEYINPUT.pointee)
    }
    
    var isPressingAnyKey: Bool {
        rawValue != 0
    }
}
