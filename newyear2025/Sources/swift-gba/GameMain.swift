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
    static let screen = UnsafeMutablePointer<UInt16>(bitPattern: 0x06000000)!
    static let oam = UnsafeMutablePointer<ObjectAttribute>(bitPattern: 0x07000000)!
    
    static var sprites: [ObjectAttribute] = []
    
    static func showTitle(_ index: Int) {
        let spriteIndex = 3 - index
        sprites[spriteIndex].x = UInt16(bitPattern: Int16(index * 60 - 32 - 2))
        sprites[spriteIndex].y = 0
        sprites[spriteIndex].charNo = 512 + UInt16(index * 8)
        sprites[spriteIndex].paletteNo = 0
        sprites[spriteIndex].attr0 |= 0x0300 // Double-Size Flag: On, Rotation/Scaling Flag: On
        sprites[spriteIndex].attr1 |= 0xc000 // OBJ Size: 64x64, Rotation/Scaling Parameter Selection: 0
        
        var angle = 350
        var scale = 0
        
        for _ in 0..<11 {
            let affine = Affine.Parameter(scale: scale, angle: angle)
            sprites[0].attr3 = affine.a
            sprites[1].attr3 = affine.b
            sprites[2].attr3 = affine.c
            sprites[3].attr3 = affine.d
            
            oam.update(from: sprites, count: sprites.count)
            
            if angle > 0 {
                angle -= 35
            }
            scale += 1
            
            waitForVsync()
        }
        
        sprites[spriteIndex].attr1 |= 0x0200 // Rotation/Scaling Parameter Selection: 1
    }
    
    static func showSubtitle() {
        for i in 0..<4 {
            let spriteIndex = i + 4
            sprites[spriteIndex].x = 56 + UInt16(i * 32)
            sprites[spriteIndex].y = 94
            sprites[spriteIndex].charNo = 512 + 256 + UInt16(i * 4)
            sprites[spriteIndex].paletteNo = 1
            sprites[spriteIndex].attr0 |= 0x1000 // OBJ Mosaic: On
            sprites[spriteIndex].attr1 |= 0x8000 // OBJ Size: 32x32
        }
        
        oam.update(from: sprites, count: sprites.count)
        
        for i in (0..<16).reversed() {
            let REG_MOSAIC = UnsafeMutablePointer<UInt16>(bitPattern: 0x0400004C)!
            REG_MOSAIC.pointee = UInt16((i << 12) | (i << 8))
            
            waitForVsync()
            waitForVsync()
            waitForVsync()
        }
    }
    
    static func main() {
        screen.update(repeating: 0x7fff, count: 240 * 160)
        oam.update(repeating: ObjectAttribute(attr0: 0x0200), count: 128)
        
        Sprite.setup()
        
        let OBJ_ENABLE = UInt16(1 << 12)
        let BG2_ENABLE = UInt16(1 << 10)
        setMode(3, flags: OBJ_ENABLE | BG2_ENABLE)
        
        while true {
            sprites = .init(repeating: .init(x: 240, y: 160, charNo: 0, paletteNo: 0), count: 8)
            
            let identify = Affine.Parameter()
            sprites[4 + 0].attr3 = identify.a
            sprites[4 + 1].attr3 = identify.b
            sprites[4 + 2].attr3 = identify.c
            sprites[4 + 3].attr3 = identify.d
            
            waitForVsync()
            
            for i in 0..<4 {
                showTitle(i)
                for _ in 0..<8 {
                    waitForVsync()
                }
            }
            
            for _ in 0..<8 {
                waitForVsync()
            }
            
            showSubtitle()
            
            while !Key.poll().isPressingAnyKey {}
        }
    }
}
