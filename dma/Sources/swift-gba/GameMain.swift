import _Volatile

// https://github.com/devkitPro/libgba/blob/master/include/gba_video.h
let REG_DISPCNT  = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000000)
let MODE_3 = UInt16(3)
let BG2_ENABLE = UInt16(1 << 10)

// https://github.com/devkitPro/libgba/blob/master/include/gba_dma.h
let REG_DMA3SAD   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x040000D4)
let REG_DMA3DAD   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x040000D8)
let REG_DMA3CNT   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x040000DC)
let REG_DMA3CNT_L = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x040000DC)
let REG_DMA3CNT_H = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x040000DE)
let DMA_VBLANK = UInt16(1 << 12)
let DMA_IRQ = UInt16(1 << 14)
let DMA_ENABLE = UInt16(1 << 15)

// https://github.com/devkitPro/libgba/blob/master/include/gba_input.h
let REG_KEYINPUT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000130)
let REG_KEYCNT   = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000132)
let KEY_A = UInt16(1 << 0)
let KEY_B = UInt16(1 << 1)
let KEYIRQ_ENABLE = UInt16(1 << 14)

// https://github.com/devkitPro/libgba/blob/master/include/gba_interrupt.h
let INT_VECTOR   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x03007FFC)
let REG_IME      = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x04000208)
let REG_IE       = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000200)
let REG_IF       = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000202)
let IRQ_DMA3 = UInt16(1 << 11)
let IRQ_KEYPAD = UInt16(1 << 12)

@section(".iwram")
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

let src1 = UnsafeMutableBufferPointer<UInt16>.allocate(capacity: 240 * 160)
let src2 = UnsafeMutableBufferPointer<UInt16>.allocate(capacity: 240 * 160)
let src1Address = unsafeBitCast(src1.baseAddress, to: UInt32.self)
let src2Address = unsafeBitCast(src2.baseAddress, to: UInt32.self)

@main
struct GameMain {
    static func main() {
        initIrq()
        
        for y in 0..<160 {
            for x in 0..<240 {
                src1[y * 240 + x] = UInt16(0x03FF - (y / 5))
                src2[y * 240 + x] = UInt16((y / 5) + 0x7C00)
            }
        }
        
        REG_DISPCNT.store(MODE_3 | BG2_ENABLE)
        
        mGBA.log(hex: src1Address)
        mGBA.log(hex: src2Address)
        
        REG_DMA3SAD.store(src1Address)
        REG_DMA3DAD.store(0x06000000) // VRAM
        REG_DMA3CNT_L.store(240 * 160)
        REG_DMA3CNT_H.store(DMA_ENABLE | DMA_IRQ | DMA_VBLANK)
        
        while true {}
    }
}
