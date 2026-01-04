//
// https://akkera102.sakura.ne.jp/gbadev/?doc.10
//

enum mGBA {
    nonisolated(unsafe) static var putcharCount = 0
    
    enum Flag: UInt16 {
        case fatal  = 0x100
        case error  = 0x101
        case warn   = 0x102
        case info   = 0x103
        case debug  = 0x104
    }
    
    static func enableLog() {
        let REG_DEBUG_ENABLE = UnsafeMutablePointer<UInt16>(bitPattern: 0x04FFF780)!
        REG_DEBUG_ENABLE.pointee = 0xC0DE
    }
    
    static func putchar(_ c: CInt) {
        let REG_DEBUG_STR = UnsafeMutablePointer<UInt8>(bitPattern: 0x04FFF600)!
        REG_DEBUG_STR[putcharCount] = UInt8(c & 0xFF)
        putcharCount += 1
    }
    
    static func flush(as flag: Flag) {
        let REG_DEBUG_FLAGS = UnsafeMutablePointer<UInt16>(bitPattern: 0x04FFF700)!
        REG_DEBUG_FLAGS.pointee = flag.rawValue
        putcharCount = 0
    }
}
