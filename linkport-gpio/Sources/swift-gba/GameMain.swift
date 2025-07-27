// https://github.com/devkitPro/libgba/blob/master/include/gba_input.h
let REG_KEYINPUT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000130)

// https://github.com/devkitPro/libgba/blob/master/include/gba_sio.h
let RCNT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000134)

@main
struct GameMain {
    static func main() {
        while true {
            let key = REG_KEYINPUT.load() & 0x03ff
            if key == 0x03ff {
                RCNT.store(0b1000_0000_1000_0000) // SO: Output & Low
            } else {
                RCNT.store(0b1000_0000_1000_1000) // SO: Output & High
            }
        }
    }
}
