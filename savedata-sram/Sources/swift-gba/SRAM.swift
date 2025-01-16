enum SRAM {
    static let sram = UnsafeMutablePointer<UInt8>(bitPattern: 0x0E000000)!
    
    static func write(_ value: UInt8, offset index: Int) {
        precondition(index >= 0 && index < 0x8000)
        sram[index] = value
    }
    
    static func read(offset index: Int) -> UInt8 {
        precondition(index >= 0 && index < 0x8000)
        return sram[index]
    }
    
    static func clear() {
        sram.update(repeating: 0xff, count: 0x8000)
    }
}
