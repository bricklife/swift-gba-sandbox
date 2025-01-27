// https://github.com/swiftlang/swift/blob/main/stdlib/public/Volatile/Volatile.swift
#if canImport(_Volatile)
import _Volatile
typealias Register = _Volatile.VolatileMappedRegister
#else
struct Register<Pointee> {
    let unsafeBitPattern: UInt
    
    func load() -> Pointee where Pointee: UnsignedInteger {
        UnsafePointer<Pointee>(bitPattern: unsafeBitPattern)!.pointee
    }
      
    func store(_ value: Pointee) where Pointee: UnsignedInteger {
        UnsafeMutablePointer<Pointee>(bitPattern: unsafeBitPattern)!.pointee = value
    }
}
#endif

// https://github.com/devkitPro/libgba/blob/master/include/gba_video.h
let REG_DISPCNT     = Register<UInt16>(unsafeBitPattern: 0x04000000)
let REG_DISPSTAT    = Register<UInt16>(unsafeBitPattern: 0x04000004)
let REG_VCOUNT      = Register<UInt16>(unsafeBitPattern: 0x04000006)
let MODE_0          = UInt16(0)
let MODE_1          = UInt16(1)
let MODE_2          = UInt16(2)
let MODE_3          = UInt16(3)
let MODE_4          = UInt16(4)
let MODE_5          = UInt16(5)
let OBJ_1D_MAP      = UInt16(1 << 6)
let BG0_ENABLE      = UInt16(1 << 8)
let BG1_ENABLE      = UInt16(1 << 9)
let BG2_ENABLE      = UInt16(1 << 10)
let BG3_ENABLE      = UInt16(1 << 11)
let OBJ_ENABLE      = UInt16(1 << 12)
let LCDC_VBL        = UInt16(1 << 3)
let LCDC_HBL        = UInt16(1 << 4)

// https://github.com/devkitPro/libgba/blob/master/include/gba_sound.h
let REG_SOUNDCNT_L  = Register<UInt16>(unsafeBitPattern: 0x04000080)
let REG_SOUNDCNT_H  = Register<UInt16>(unsafeBitPattern: 0x04000082)
let REG_SOUNDCNT_X  = Register<UInt16>(unsafeBitPattern: 0x04000084)
let REG_FIFO_A      = UInt32(0x040000A0)
let REG_FIFO_B      = UInt32(0x040000A4)
let SNDA_VOL_50     = UInt16(0 << 2)
let SNDA_VOL_100    = UInt16(1 << 2)
let SNDB_VOL_50     = UInt16(0 << 3)
let SNDB_VOL_100    = UInt16(1 << 3)
let SNDA_R_ENABLE   = UInt16(1 << 8)
let SNDA_L_ENABLE   = UInt16(1 << 9)
let SNDA_RESET_FIFO = UInt16(1 << 11)
let SNDB_R_ENABLE   = UInt16(1 << 12)
let SNDB_L_ENABLE   = UInt16(1 << 13)
let SNDB_RESET_FIFO = UInt16(1 << 15)
let SNDSTAT_ENABLE  = UInt16(1 << 7)

// https://github.com/devkitPro/libgba/blob/master/include/gba_dma.h
let REG_DMA0SAD     = Register<UInt32>(unsafeBitPattern: 0x040000B0)
let REG_DMA0DAD     = Register<UInt32>(unsafeBitPattern: 0x040000B4)
let REG_DMA0CNT_L   = Register<UInt16>(unsafeBitPattern: 0x040000B8)
let REG_DMA0CNT_H   = Register<UInt16>(unsafeBitPattern: 0x040000BA)
let REG_DMA1SAD     = Register<UInt32>(unsafeBitPattern: 0x040000BC)
let REG_DMA1DAD     = Register<UInt32>(unsafeBitPattern: 0x040000C0)
let REG_DMA1CNT_L   = Register<UInt16>(unsafeBitPattern: 0x040000C4)
let REG_DMA1CNT_H   = Register<UInt16>(unsafeBitPattern: 0x040000C6)
let REG_DMA2SAD     = Register<UInt32>(unsafeBitPattern: 0x040000C8)
let REG_DMA2DAD     = Register<UInt32>(unsafeBitPattern: 0x040000CC)
let REG_DMA2CNT_L   = Register<UInt16>(unsafeBitPattern: 0x040000D0)
let REG_DMA2CNT_H   = Register<UInt16>(unsafeBitPattern: 0x040000D2)
let REG_DMA3SAD     = Register<UInt32>(unsafeBitPattern: 0x040000D4)
let REG_DMA3DAD     = Register<UInt32>(unsafeBitPattern: 0x040000D8)
let REG_DMA3CNT_L   = Register<UInt16>(unsafeBitPattern: 0x040000DC)
let REG_DMA3CNT_H   = Register<UInt16>(unsafeBitPattern: 0x040000DE)
let DMA_DST_INC     = UInt16(0 << (21 - 16))
let DMA_DST_DEC     = UInt16(1 << (21 - 16))
let DMA_DST_FIXED   = UInt16(2 << (21 - 16))
let DMA_DST_RELOAD  = UInt16(3 << (21 - 16))
let DMA_SRC_INC     = UInt16(0 << (23 - 16))
let DMA_SRC_DEC     = UInt16(1 << (23 - 16))
let DMA_SRC_FIXED   = UInt16(2 << (23 - 16))
let DMA_REPEAT      = UInt16(1 << (25 - 16))
let DMA16           = UInt16(0 << (26 - 16))
let DMA32           = UInt16(1 << (26 - 16))
let DMA_IMMEDIATE   = UInt16(0 << (28 - 16))
let DMA_VBLANK      = UInt16(1 << (28 - 16))
let DMA_HBLANK      = UInt16(2 << (28 - 16))
let DMA_SPECIAL     = UInt16(3 << (28 - 16))
let DMA_IRQ         = UInt16(1 << (30 - 16))
let DMA_ENABLE      = UInt16(1 << (31 - 16))

// https://github.com/devkitPro/libgba/blob/master/include/gba_timers.h
let REG_TM0CNT_L    = Register<UInt16>(unsafeBitPattern: 0x04000100)
let REG_TM0CNT_H    = Register<UInt16>(unsafeBitPattern: 0x04000102)
let TIMER_START     = UInt16(1 << 7)

// https://github.com/devkitPro/libgba/blob/master/include/gba_input.h
let REG_KEYINPUT    = Register<UInt16>(unsafeBitPattern: 0x04000130)
let REG_KEYCNT      = Register<UInt16>(unsafeBitPattern: 0x04000132)
let KEY_A           = UInt16(1 << 0)
let KEY_B           = UInt16(1 << 1)
let KEY_SELECT      = UInt16(1 << 2)
let KEY_START       = UInt16(1 << 3)
let KEY_RIGHT       = UInt16(1 << 4)
let KEY_LEFT        = UInt16(1 << 5)
let KEY_UP          = UInt16(1 << 6)
let KEY_DOWN        = UInt16(1 << 7)
let KEY_R           = UInt16(1 << 8)
let KEY_L           = UInt16(1 << 9)
let KEYIRQ_ENABLE   = UInt16(1 << 14)

// https://github.com/devkitPro/libgba/blob/master/include/gba_interrupt.h
let INT_VECTOR      = Register<UInt32>(unsafeBitPattern: 0x03007FFC)
let REG_IME         = Register<UInt32>(unsafeBitPattern: 0x04000208)
let REG_IE          = Register<UInt16>(unsafeBitPattern: 0x04000200)
let REG_IF          = Register<UInt16>(unsafeBitPattern: 0x04000202)
let IRQ_VBLANK      = UInt16(1 << 0)
let IRQ_HBLANK      = UInt16(1 << 1)
let IRQ_DMA0        = UInt16(1 << 8)
let IRQ_DMA1        = UInt16(1 << 9)
let IRQ_DMA2        = UInt16(1 << 10)
let IRQ_DMA3        = UInt16(1 << 11)
let IRQ_KEYPAD      = UInt16(1 << 12)
