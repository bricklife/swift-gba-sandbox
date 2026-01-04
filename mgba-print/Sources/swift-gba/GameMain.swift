import _Volatile

func setMode(_ mode: UInt16, flags: UInt16 = 0) {
    let REG_DISPCNT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000000)
    REG_DISPCNT.store((mode & 0x0007) | (flags & 0xfff8))
}

func waitForVsync() {
    let REG_VCOUNT = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000006)
    while REG_VCOUNT.load() >= 160 {}
    while REG_VCOUNT.load() < 160 {}
}

@main
struct GameMain {
    static func main() {
        var lastKey: UInt16 = 0
        
        print("\n== REG_KEYINPUT Logger ==")
        print("Open 'Logs' from Tools menu.")
        print("ToolsメニューからLogsを開いてね\n")
        
        while true {
            waitForVsync()
            
            let key = VolatileMappedRegister<UInt16>(unsafeBitPattern: 0x04000130).load()
            if key != lastKey {
                print("DEC:", terminator: " ")
                print(key)
                print("HEX:", terminator: " ")
                print(key.hexString)
                lastKey = key
            }
        }
    }
}

extension BinaryInteger {
    var hexString: String {
        let hex = String(self, radix: 16)
        let zeroPaddingCount = (self.bitWidth / 4) - hex.utf8.count
        return "0x" + String(repeating: "0", count: zeroPaddingCount) + hex
    }
}
