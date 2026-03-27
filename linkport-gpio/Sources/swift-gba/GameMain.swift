// https://github.com/devkitPro/libgba/blob/master/include/gba_input.h
import _Volatile

let REG_KEYINPUT    = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000130)

// https://github.com/devkitPro/libgba/blob/master/include/gba_sio.h
let RCNT            = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000134)
let R_GPIO          = UInt16(0x8000)
let GPIO_SO_OUTPUT  = UInt16(0x0080)
let GPIO_SO         = UInt16(0x0008)

@main
struct GameMain {
    static func main() {
        while true {
            let key = REG_KEYINPUT.load() & 0x03ff
            if key == 0x03ff {
                // GPIO: SO = Output & Low
                RCNT.store(R_GPIO & GPIO_SO_OUTPUT)
            } else {
                // GPIO: SO = Output & High
                RCNT.store(R_GPIO & GPIO_SO_OUTPUT & GPIO_SO)
            }
        }
    }
}
