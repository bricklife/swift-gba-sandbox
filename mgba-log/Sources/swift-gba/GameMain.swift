import _Volatile

let REG_DISPCNT  = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000000)
let REG_VCOUNT   = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000006)
let REG_KEYINPUT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000130)

func setMode(_ mode: UInt16, flags: UInt16 = 0) {
    REG_DISPCNT.store((mode & 0x0007) | (flags & 0xfff8))
}

func waitForVsync() {
    while REG_VCOUNT.load() >= 160 {}
    while REG_VCOUNT.load() < 160 {}
}

@main
struct GameMain {
    static func main() {
        var lastKey: UInt16 = 0
        
        mGBA.log("== REG_KEYINPUT ==")
        
        while true {
            waitForVsync()
            
            let key = REG_KEYINPUT.load()
            if key != lastKey {
                mGBA.log(key)
                mGBA.log(hex: key)
                lastKey = key
            }
        }
    }
}
