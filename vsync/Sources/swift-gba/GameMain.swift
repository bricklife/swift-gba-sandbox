func setMode(_ mode: UInt16, flags: UInt16 = 0) {
    let REG_DISPCNT = UnsafeMutablePointer<UInt16>(bitPattern: 0x04000000)!
    REG_DISPCNT.pointee = (mode & 0x0007) | (flags & 0xfff8)
}

func waitForVsync() {
    /* Doesn't work...
     let REG_VCOUNT = UnsafePointer<UInt16>(bitPattern: 0x04000006)!
     while REG_VCOUNT.pointee >= 160 {}
     while REG_VCOUNT.pointee < 160 {}
     */
    while UnsafePointer<UInt16>(bitPattern: 0x04000006)!.pointee >= 160 {}
    while UnsafePointer<UInt16>(bitPattern: 0x04000006)!.pointee < 160 {}
}

@main
struct GameMain {
    static func main() {
        setMode(3)
        
        let screen = UnsafeMutablePointer<UInt16>(bitPattern: 0x06000000)!
        screen.update(repeating: 0, count: 240 * 160)
        
        let BG2_ENABLE = UInt16(1 << 10)
        setMode(3, flags: BG2_ENABLE)
        
        var x = 120
        var y = 80
        var dx = 1
        var dy = 1
        
        while true {
            waitForVsync()
            
            screen[y * 240 + x] = 0x7fff
            
            if (x == 0 && dx < 0) || (x == 239 && dx > 0) {
                dx *= -1
            }
            if (y == 0 && dy < 0) || (y == 159 && dy > 0) {
                dy *= -1
            }
            
            x += dx
            y += dy
        }
    }
}
