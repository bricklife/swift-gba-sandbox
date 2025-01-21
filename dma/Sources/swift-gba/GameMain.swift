// https://github.com/devkitPro/libgba/blob/master/include/gba_interrupt.h
let INT_VECTOR   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x03007FFC)
let REG_DISPCNT  = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000000)
let REG_IME      = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x04000208)
let REG_IE       = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000200)
let REG_IF       = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000202)
let IRQ_DMA3 = UInt16(1 << 11)
let IRQ_KEYPAD = UInt16(1 << 12)

// https://github.com/devkitPro/libgba/blob/master/include/gba_input.h
let REG_KEYINPUT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000130)
let REG_KEYCNT   = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000132)
let KEY_A = UInt16(1 << 0)
let KEY_B = UInt16(1 << 1)
let KEYIRQ_ENABLE = UInt16(1 << 14)

// https://github.com/devkitPro/libgba/blob/master/include/gba_dma.h
let REG_DMA3SAD   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x040000D4)
let REG_DMA3DAD   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x040000D8)
let REG_DMA3CNT   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x040000DC)
let REG_DMA3CNT_L = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x040000DC)
let REG_DMA3CNT_H = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x040000DE)
let DMA_VBLANK = UInt16(1 << 12)
let DMA_IRQ = UInt16(1 << 14)
let DMA_ENABLE = UInt16(1 << 15)

@_section(".iwram")
func irqHandler() {
    REG_IME.store(0)
    
    let flag = REG_IF.load()
    if flag & IRQ_KEYPAD != 0 {
        let key = REG_KEYINPUT.load()
        if key & KEY_A == 0 {
            REG_DMA3SAD.store(src2Address)
        } else {
            REG_DMA3SAD.store(src1Address)
        }
        REG_DMA3CNT_H.store(DMA_ENABLE | DMA_IRQ | DMA_VBLANK)
    }
    if flag & IRQ_DMA3 != 0 {
        mGBA.log("IRQ_DMA3 done")
    }
    REG_IF.store(flag)
    
    REG_IME.store(1)
}

func initIrq() {
    REG_IME.store(0)
    
    let funcAddress = unsafeBitCast(irqHandler as @convention(c) () -> Void, to: UInt32.self)
    mGBA.log(hex: funcAddress)
    
    INT_VECTOR.store(funcAddress)
    REG_KEYCNT.store(KEYIRQ_ENABLE | KEY_A | KEY_B)
    REG_IE.store(IRQ_KEYPAD | IRQ_DMA3)
    
    REG_IME.store(1)
}

func setMode(_ mode: UInt16, flags: UInt16 = 0) {
    REG_DISPCNT.store((mode & 0x0007) | (flags & 0xfff8))
}

let src1 = UnsafeMutableBufferPointer<UInt16>.allocate(capacity: 240 * 160)
let src2 = UnsafeMutableBufferPointer<UInt16>.allocate(capacity: 240 * 160)
let src1Address = unsafeBitCast(src1.baseAddress, to: UInt32.self)
let src2Address = unsafeBitCast(src2.baseAddress, to: UInt32.self)

@main
struct GameMain {
    static func main() {
        initIrq()
        
        src1.initialize(repeating: 0x7FFF)
        for i in stride(from: 0, to: src1.count, by: 11) {
            src1[i] = 0x001F
        }
        src2.initialize(repeating: 0x7FFF)
        for i in stride(from: 0, to: src2.count, by: 13) {
            src2[i] = 0x7C00
        }
        
        let BG2_ENABLE = UInt16(1 << 10)
        setMode(3, flags: BG2_ENABLE)
        
        mGBA.log(hex: src1Address)
        mGBA.log(hex: src2Address)
        
        REG_DMA3SAD.store(src1Address)
        REG_DMA3DAD.store(0x06000000) // VRAM
        REG_DMA3CNT_L.store(240 * 160)
        REG_DMA3CNT_H.store(DMA_ENABLE | DMA_IRQ | DMA_VBLANK)
        
        while true {}
    }
}
