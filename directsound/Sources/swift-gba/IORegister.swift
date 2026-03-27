// https://github.com/swiftlang/swift/blob/main/stdlib/public/Volatile/Volatile.swift
import _Volatile

struct IORegister<Pointee: FixedWidthInteger> {
    let volatileMappedRegister: VolatileMappedRegister<Pointee.Magnitude>
    
    init(address: UInt) {
        self.volatileMappedRegister = .init(unsafeBitPattern: address)
    }
}

extension IORegister where Pointee == UInt16 {
    func load() -> Pointee {
        volatileMappedRegister.load()
    }
    func store(_ value: Pointee) {
        volatileMappedRegister.store(value)
    }
}

extension IORegister where Pointee == UInt32 {
    func load() -> Pointee {
        volatileMappedRegister.load()
    }
    func store(_ value: Pointee) {
        volatileMappedRegister.store(value)
    }
}

extension IORegister where Pointee == Int16 {
    func load() -> Pointee {
        .init(bitPattern: volatileMappedRegister.load())
    }
    func store(_ value: Pointee) {
        volatileMappedRegister.store(.init(bitPattern: value))
    }
}

extension IORegister where Pointee == Int32 {
    func load() -> Pointee {
        .init(bitPattern: volatileMappedRegister.load())
    }
    func store(_ value: Pointee) {
        volatileMappedRegister.store(.init(bitPattern: value))
    }
}

// https://github.com/devkitPro/libgba/blob/master/include/gba_video.h
let REG_DISPCNT     = IORegister<UInt16>(address: 0x04000000)
let REG_DISPSTAT    = IORegister<UInt16>(address: 0x04000004)
let REG_VCOUNT      = IORegister<UInt16>(address: 0x04000006)
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
let REG_SOUNDCNT_L  = IORegister<UInt16>(address: 0x04000080)
let REG_SOUNDCNT_H  = IORegister<UInt16>(address: 0x04000082)
let REG_SOUNDCNT_X  = IORegister<UInt16>(address: 0x04000084)
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
let REG_DMA0SAD     = IORegister<UInt32>(address: 0x040000B0)
let REG_DMA0DAD     = IORegister<UInt32>(address: 0x040000B4)
let REG_DMA0CNT_L   = IORegister<UInt16>(address: 0x040000B8)
let REG_DMA0CNT_H   = IORegister<UInt16>(address: 0x040000BA)
let REG_DMA1SAD     = IORegister<UInt32>(address: 0x040000BC)
let REG_DMA1DAD     = IORegister<UInt32>(address: 0x040000C0)
let REG_DMA1CNT_L   = IORegister<UInt16>(address: 0x040000C4)
let REG_DMA1CNT_H   = IORegister<UInt16>(address: 0x040000C6)
let REG_DMA2SAD     = IORegister<UInt32>(address: 0x040000C8)
let REG_DMA2DAD     = IORegister<UInt32>(address: 0x040000CC)
let REG_DMA2CNT_L   = IORegister<UInt16>(address: 0x040000D0)
let REG_DMA2CNT_H   = IORegister<UInt16>(address: 0x040000D2)
let REG_DMA3SAD     = IORegister<UInt32>(address: 0x040000D4)
let REG_DMA3DAD     = IORegister<UInt32>(address: 0x040000D8)
let REG_DMA3CNT_L   = IORegister<UInt16>(address: 0x040000DC)
let REG_DMA3CNT_H   = IORegister<UInt16>(address: 0x040000DE)
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
let REG_TM0CNT_L    = IORegister<UInt16>(address: 0x04000100)
let REG_TM0CNT_H    = IORegister<UInt16>(address: 0x04000102)
let TIMER_START     = UInt16(1 << 7)

// https://github.com/devkitPro/libgba/blob/master/include/gba_input.h
let REG_KEYINPUT    = IORegister<UInt16>(address: 0x04000130)
let REG_KEYCNT      = IORegister<UInt16>(address: 0x04000132)
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
let INT_VECTOR      = IORegister<UInt32>(address: 0x03007FFC)
let REG_IME         = IORegister<UInt32>(address: 0x04000208)
let REG_IE          = IORegister<UInt16>(address: 0x04000200)
let REG_IF          = IORegister<UInt16>(address: 0x04000202)
let IRQ_VBLANK      = UInt16(1 << 0)
let IRQ_HBLANK      = UInt16(1 << 1)
let IRQ_DMA0        = UInt16(1 << 8)
let IRQ_DMA1        = UInt16(1 << 9)
let IRQ_DMA2        = UInt16(1 << 10)
let IRQ_DMA3        = UInt16(1 << 11)
let IRQ_KEYPAD      = UInt16(1 << 12)
