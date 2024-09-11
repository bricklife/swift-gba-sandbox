func setMode(_ mode: UInt16, flags: UInt16 = 0) {
    let REG_DISPCNT = UnsafeMutablePointer<UInt16>(bitPattern: 0x04000000)!
    REG_DISPCNT.pointee = (mode & 0x0007) | (flags & 0xfff8)
}

func waitForVsync() {
    //let REG_VCOUNT = UnsafePointer<UInt16>(bitPattern: 0x04000006)!
    while UnsafePointer<UInt16>(bitPattern: 0x04000006)!.pointee >= 160 {}
    while UnsafePointer<UInt16>(bitPattern: 0x04000006)!.pointee < 160 {}
}

@main
struct GameMain {
    static func main() {
        var lastKey: UInt16 = 0
        
        mGBA.log("== REG_KEYINPUT ==")
        
        while true {
            waitForVsync()
            
            let key = UnsafePointer<UInt16>(bitPattern: 0x04000130)!.pointee
            if key != lastKey {
                mGBA.log(key)
                mGBA.log(hex: key)
                lastKey = key
            }
        }
    }
}
