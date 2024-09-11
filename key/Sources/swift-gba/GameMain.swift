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
        setMode(3)
        
        let screen = UnsafeMutablePointer<UInt16>(bitPattern: 0x06000000)!
        screen.update(repeating: 0x7fff, count: 240 * 160)
        
        let BG2_ENABLE = UInt16(1 << 10)
        setMode(3, flags: BG2_ENABLE)
        
        var x = 120
        var y = 80
        
        while true {
            waitForVsync()
            
            screen[y * 240 + x] = 0
            
            let key = Key.poll()
            if key.contains(.up)    { y -= 1 }
            if key.contains(.down)  { y += 1 }
            if key.contains(.left)  { x -= 1 }
            if key.contains(.right) { x += 1 }
        }
    }
}
