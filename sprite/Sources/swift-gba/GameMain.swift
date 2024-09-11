func setMode(_ mode: UInt16, flags: UInt16 = 0) {
    let REG_DISPCNT = UnsafeMutablePointer<UInt16>(bitPattern: 0x04000000)!
    REG_DISPCNT.pointee = (mode & 0x0007) | (flags & 0xfff8)
}

func waitForVsync() {
    //let REG_VCOUNT = UnsafePointer<UInt16>(bitPattern: 0x04000006)!
    while UnsafePointer<UInt16>(bitPattern: 0x04000006)!.pointee >= 160 {}
    while UnsafePointer<UInt16>(bitPattern: 0x04000006)!.pointee < 160 {}
}

let tileData: [UInt32] = [
    0x00111100,
    0x01122110,
    0x11211211,
    0x11211211,
    0x11222211,
    0x11211211,
    0x01211210,
    0x00111100,
    
    0x00111100,
    0x01122210,
    0x11211211,
    0x11122211,
    0x11211211,
    0x11211211,
    0x01122210,
    0x00111100,
]

@main
struct GameMain {
    static func main() {
        let objectPalettes = UnsafeMutablePointer<UInt16>(bitPattern: 0x05000200)!
        objectPalettes.update(repeating: 0, count: 256)
        objectPalettes[1] = 0x001f
        objectPalettes[2] = 0x7fff
        objectPalettes[16 + 1] = 0x03e0
        objectPalettes[16 + 2] = 0x0000
        
        let objectTiles = UnsafeMutablePointer<UInt32>(bitPattern: 0x06010000)!
        objectTiles.update(from: tileData, count: tileData.count)
        
        let oam = UnsafeMutablePointer<ObjectAttribute>(bitPattern: 0x07000000)!
        oam.update(repeating:  ObjectAttribute(attr0: 0x0200), count: 128)
        
        var sprite = ObjectAttribute(x: 120 - 4, y: 80 - 4, charNo: 0, paletteNo: 0)
        oam[0] = sprite
        
        let OBJ_ENABLE = UInt16(1 << 12)
        setMode(0, flags: OBJ_ENABLE)
        
        while true {
            waitForVsync()
            
            let key = Key.poll()
            if key.contains(.up)    { sprite.y -= 1 }
            if key.contains(.down)  { sprite.y += 1 }
            if key.contains(.left)  { sprite.x -= 1 }
            if key.contains(.right) { sprite.x += 1 }
            if key.contains(.a)     { sprite.charNo = 0 }
            if key.contains(.b)     { sprite.charNo = 1 }
            if key.contains(.r)     { sprite.paletteNo = 0 }
            if key.contains(.l)     { sprite.paletteNo = 1 }
            
            oam[0] = sprite
        }
    }
}
