// https://github.com/devkitPro/libgba/blob/master/include/gba_interrupt.h
let INT_VECTOR   = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x03007FFC)
let REG_DISPCNT  = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000000)
let REG_IME      = VolatileMappedRegister<UInt32>(unsafeBitPattern: 0x04000208)
let REG_IE       = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000200)
let REG_IF       = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000202)
let IRQ_VBLANK = UInt16(1 << 0)
let IRQ_HBLANK = UInt16(1 << 1)
let IRQ_KEYPAD = UInt16(1 << 12)

// https://github.com/devkitPro/libgba/blob/master/include/gba_video.h
let REG_DISPSTAT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000004)
let LCDC_VBL = UInt16(1 << 3)
let LCDC_HBL = UInt16(1 << 4)

// https://github.com/devkitPro/libgba/blob/master/include/gba_input.h
let REG_KEYINPUT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000130)
let REG_KEYCNT   = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000132)
let KEY_A = UInt16(1 << 0)
let KEYIRQ_ENABLE = UInt16(1 << 14)

var isStarted = false
var count = 0
var color = UInt16(0)

@_section(".iwram")
func irqHandler() {
    REG_IME.store(0)
    
    let flag = REG_IF.load()
    if flag & IRQ_VBLANK != 0 {
        isStarted = true
        UnsafeMutablePointer<UInt16>(bitPattern: 0x06000000)![count] = color
        count = (count + 1) % (240 * 160)
    }
    if flag & IRQ_HBLANK != 0 {
        if isStarted {
            color = (color + 1) & 0x7FFF
        }
    }
    if flag & IRQ_KEYPAD != 0 {
        count = (count + 240) % (240 * 160)
    }
    REG_IF.store(flag)
    
    REG_IME.store(1)
}

func initIrq() {
    REG_IME.store(0)
    
    let funcAddress = unsafeBitCast(irqHandler as @convention(c) () -> Void, to: UInt32.self)
    mGBA.log(hex: funcAddress)
    
    INT_VECTOR.store(funcAddress)
    REG_DISPSTAT.store(LCDC_VBL | LCDC_HBL)
    REG_KEYCNT.store(KEYIRQ_ENABLE | KEY_A)
    REG_IE.store(IRQ_VBLANK | IRQ_HBLANK | IRQ_KEYPAD)
    
    REG_IME.store(1)
}

func setMode(_ mode: UInt16, flags: UInt16 = 0) {
    REG_DISPCNT.store((mode & 0x0007) | (flags & 0xfff8))
}

@main
struct GameMain {
    static func main() {
        initIrq()
        
        let BG2_ENABLE = UInt16(1 << 10)
        setMode(3, flags: BG2_ENABLE)
        
        while true {}
    }
}
