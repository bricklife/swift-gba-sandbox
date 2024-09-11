//
// https://akkera102.sakura.ne.jp/gbadev/?doc.10
//

enum mGBA {
    static let REG_DEBUG_ENABLE = UnsafeMutablePointer<UInt16>(bitPattern: 0x04FFF780)!
    static let REG_DEBUG_FLAGS  = UnsafeMutablePointer<UInt16>(bitPattern: 0x04FFF700)!
    static let REG_DEBUG_STR    = UnsafeMutablePointer<UInt8>(bitPattern:  0x04FFF600)!
    
    static func log(_ string: String) {
        REG_DEBUG_ENABLE.pointee = 0xC0DE
        
        let bytes = string.utf8CString.withUnsafeBytes { $0.bindMemory(to: UInt8.self) }
        var buf = bytes.baseAddress!
        var len = bytes.count
        
        while len > 0 {
            let write = min(len, 256)
            REG_DEBUG_STR.update(from: buf, count: write)
            REG_DEBUG_FLAGS.pointee = 0x102
            buf += write
            len -= write
        }
    }
    
    static func log<Number: BinaryInteger>(_ number: Number) {
        REG_DEBUG_ENABLE.pointee = 0xC0DE
        
        var numbers: [UInt8] = []
        var n = number * number.signum()
        while n > 0 {
            numbers.insert(UInt8(n % 10), at: 0)
            n /= 10
        }
        if numbers.isEmpty {
            numbers.append(0)
        }
        
        var p = REG_DEBUG_STR
        if number < 0 {
            p.pointee = 0x2d // '-'
            p += 1
        }
        for n in numbers {
            p.pointee = n + 0x30
            p += 1
        }
        p.pointee = 0
        
        REG_DEBUG_FLAGS.pointee = 0x102
    }
    
    static func log<Number: BinaryInteger>(hex number: Number) {
        REG_DEBUG_ENABLE.pointee = 0xC0DE
        
        var p = REG_DEBUG_STR
        p[0] = 0x30 // '0'
        p[1] = 0x78 // 'x'
        p += 2
        
        for i in stride(from: number.bitWidth - 4, through: 0, by: -4) {
            let n = UInt8((number >> i) & 0x0f)
            if n > 9 {
                p.pointee = n - 10 + 0x41
            } else {
                p.pointee = n + 0x30
            }
            p += 1
        }
        p.pointee = 0
        
        REG_DEBUG_FLAGS.pointee = 0x102
    }
}
