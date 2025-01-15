enum SRAM {
    static let sram = UnsafeMutablePointer<UInt8>(bitPattern: 0x0E000000)!
    
    static func write(_ value: UInt8, offset index: Int) {
        precondition(index >= 0 && index < 0x7FFF)
        sram[index] = value
    }
    
    static func read(offset index: Int) -> UInt8 {
        precondition(index >= 0 && index < 0x7FFF)
        return sram[index]
    }
}
