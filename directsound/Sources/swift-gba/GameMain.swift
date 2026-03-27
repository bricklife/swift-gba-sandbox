let soundHi: [Int8] = [
    0, 24, 48, 70, 89, 105, 117, 124,
    127, 124, 117, 105, 89, 70, 48, 24,
    0, -24, -48, -70, -89, -105, -117, -124,
    -127, -124, -117, -105, -89, -70, -48, -24,
]
let soundLow: [Int8] = [
    0, 12, 24, 36, 48, 59, 70, 80, 89, 98, 105, 112, 117, 121, 124, 126,
    127, 126, 124, 121, 117, 112, 105, 98, 89, 80, 70, 59, 48, 36, 24, 12,
    0, -12, -24, -36, -48, -59, -70, -80, -89, -98, -105, -112, -117, -121, -124, -126,
    -127, -126, -124, -121, -117, -112, -105, -98, -89, -80, -70, -59, -48, -36, -24, -12,
]

let cpuClock = 16 * 1024 * 1024
let audioRate = 16384
let audioFreq = cpuClock / audioRate

var playingSound: (address: UInt32, length: Int) = (0, 0)
var remainingLength = 0

func initIrq() {
    REG_IME.store(0)
    
    let funcAddress = unsafeBitCast(irqHandler as @convention(c) () -> Void, to: UInt32.self)
    INT_VECTOR.store(funcAddress)
    REG_IE.store(IRQ_DMA1)
    
    REG_IME.store(1)
}

@section(".iwram")
func irqHandler() {
    REG_IME.store(0)
    
    let flag = REG_IF.load()
    if flag & IRQ_DMA1 != 0 {
        remainingLength -= 16
        if remainingLength <= 0 {
            startSound(address: playingSound.address, length: playingSound.length)
        }
    }
    REG_IF.store(flag)
    
    REG_IME.store(1)
}

func initSound() {
    REG_SOUNDCNT_X.store(SNDSTAT_ENABLE)
    REG_SOUNDCNT_L.store(0)
    REG_SOUNDCNT_H.store(SNDA_RESET_FIFO | SNDA_VOL_100 | SNDA_L_ENABLE | SNDA_R_ENABLE)
    
    REG_TM0CNT_L.store(UInt16(truncatingIfNeeded: 0x10000 - audioFreq))
}

@section(".iwram")
func startSound(address: UInt32, length: Int) {
    playingSound = (address: address, length: length)
    remainingLength = length
    
    REG_DMA1CNT_H.store(0)
    REG_TM0CNT_H.store(0)
    
    REG_DMA1DAD.store(REG_FIFO_A)
    REG_DMA1SAD.store(address)
    
    REG_DMA1CNT_H.store(DMA_ENABLE | DMA_IRQ | DMA_SPECIAL | DMA32 | DMA_REPEAT | DMA_SRC_INC | DMA_DST_FIXED)
    REG_TM0CNT_H.store(TIMER_START)
}

@section(".iwram")
func stopSound() {
    REG_DMA1CNT_H.store(0)
    REG_TM0CNT_H.store(0)
    
    playingSound = (0, 0)
    remainingLength = 0
}

@main
struct GameMain {
    static func waitVBlank() {
        while REG_VCOUNT.load() >= 160 {}
        while REG_VCOUNT.load() < 160 {}
    }
    
    static func main() {
        initIrq()
        initSound()
        
        REG_DISPCNT.store(MODE_3 | BG2_ENABLE)
        
        var lastKey = Key()
        
        while true {
            waitVBlank()
            
            let key = Key.poll()
            if key.contains(.a) {
                if !lastKey.contains(.a) {
                    startSound(address: soundHi.address, length: soundHi.count)
                }
            } else if key.contains(.b) {
                if !lastKey.contains(.b) {
                    startSound(address: soundLow.address, length: soundLow.count)
                }
            } else {
                if lastKey.contains(.a) || lastKey.contains(.b) {
                    stopSound()
                }
            }
            lastKey = key
        }
    }
}

extension [Int8] {
    var address: UInt32 {
        withUnsafeBufferPointer {
            unsafeBitCast($0.baseAddress, to: UInt32.self)
        }
    }
}
