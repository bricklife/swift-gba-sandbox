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
    0x00010000,
    0x00010000,
    0x00111000,
    0x11111110,
    0x00111000,
    0x00010000,
    0x00010000,
    0x00000000,
]

enum Color: Int, CaseIterable {
    case yellow, white, gray
    
    var BGR: UInt16 {
        switch self {
        case .yellow: 0x03ff
        case .white: 0x7fff
        case .gray: 0x3def
        }
    }
}

extension ObjectAttribute {
    var color: Color {
        set { paletteNo = UInt16(newValue.rawValue) }
        get { Color(rawValue: Int(paletteNo))! }
    }
}

@main
struct GameMain {
    static func setup() {
        let objectPalettes = UnsafeMutablePointer<UInt16>(bitPattern: 0x05000200)!
        objectPalettes.update(repeating: 0, count: 256)
        for color in Color.allCases {
            objectPalettes[color.rawValue * 16 + 1] = color.BGR
        }
        
        let objectTiles = UnsafeMutablePointer<UInt32>(bitPattern: 0x06010000)!
        objectTiles.update(from: tileData, count: tileData.count)
        
        let OBJ_ENABLE = UInt16(1 << 12)
        setMode(0, flags: OBJ_ENABLE)
    }
    
    
    static func makeSprite(x: UInt16, y: UInt16, color: Color) -> ObjectAttribute {
        return ObjectAttribute(x: x, y: y, charNo: 0, paletteNo: UInt16(color.rawValue))
    }
    
    static func main() {
        setup()
        
        let sram = UnsafeMutablePointer<UInt8>(bitPattern: 0x0E000000)!
        
        let oam = UnsafeMutablePointer<ObjectAttribute>(bitPattern: 0x07000000)!
        oam.update(repeating:  ObjectAttribute(attr0: 0x0200), count: 128)
        
        var sprite = makeSprite(x: (240 / 2) - 8, y: (160 / 2) - 8, color: .white)
        if sram[0] != 0xff {
            sprite.x = UInt16(sram[0])
            sprite.y = UInt16(sram[1])
        }
        
        var spriteIndex = 1
        while true {
            waitForVsync()
            guard spriteIndex < 128, sram[spriteIndex * 2] != 0xff else { break }
            
            let x = UInt16(sram[spriteIndex * 2])
            let y = UInt16(sram[spriteIndex * 2 + 1])
            
            oam[spriteIndex] = makeSprite(x: x, y: y, color: .yellow)
            spriteIndex += 1
        }
        
        var isPressingA = false
        
        while true {
            waitForVsync()
            
            let key = Key.poll()
            if key.contains(.up),    sprite.y > 0   { sprite.y -= 1 }
            if key.contains(.down),  sprite.y < 144 { sprite.y += 1 }
            if key.contains(.left),  sprite.x > 0   { sprite.x -= 1 }
            if key.contains(.right), sprite.x < 224 { sprite.x += 1 }
            
            if key.contains(.a) {
                sprite.color = .gray
                if !isPressingA {
                    isPressingA = true
                    if spriteIndex < 128 {
                        oam[spriteIndex] = makeSprite(x: sprite.x, y: sprite.y, color: .yellow)
                        sram[spriteIndex * 2] = UInt8(sprite.x)
                        sram[spriteIndex * 2 + 1] = UInt8(sprite.y)
                        
                        spriteIndex += 1
                    }
                }
            } else {
                sprite.color = .white
                isPressingA = false
            }
            
            oam[0] = sprite
            sram[0] = UInt8(sprite.x)
            sram[1] = UInt8(sprite.y)
        }
    }
}
