func setMode(_ mode: UInt16, flags: UInt16 = 0) {
    let REG_DISPCNT = UnsafeMutablePointer<UInt16>(bitPattern: 0x04000000)!
    REG_DISPCNT.pointee = (mode & 0x0007) | (flags & 0xfff8)
}

@inline(never)
func vcount() -> UInt16 {
    let REG_VCOUNT = UnsafePointer<UInt16>(bitPattern: 0x04000006)!
    return REG_VCOUNT.pointee
}

func waitForVsync() {
    while vcount() >= 160 {}
    while vcount() < 160 {}
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
    init(x: UInt16, y: UInt16, color: Color) {
        self.init(x: x, y: y, charNo: 0, paletteNo: UInt16(color.rawValue))
    }
    
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
    
    static func main() {
        setup()
        
        let oam = UnsafeMutablePointer<ObjectAttribute>(bitPattern: 0x07000000)!
        oam.update(repeating: ObjectAttribute(attr0: 0x0200), count: 128)
        
        var sprite = ObjectAttribute(x: (240 / 2) - 8, y: (160 / 2) - 8, color: .white)
        if SRAM.read(offset: 0) != 0xff {
            sprite.x = UInt16(SRAM.read(offset: 0))
            sprite.y = UInt16(SRAM.read(offset: 1))
        }
        
        var spriteIndex = 1
        while true {
            waitForVsync()
            guard spriteIndex < 128, SRAM.read(offset: spriteIndex * 2) != 0xff else { break }
            
            let x = UInt16(SRAM.read(offset: spriteIndex * 2))
            let y = UInt16(SRAM.read(offset: spriteIndex * 2 + 1))
            
            oam[spriteIndex] = ObjectAttribute(x: x, y: y, color: .yellow)
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
                        oam[spriteIndex] = ObjectAttribute(x: sprite.x, y: sprite.y, color: .yellow)
                        SRAM.write(UInt8(sprite.x), offset: spriteIndex * 2)
                        SRAM.write(UInt8(sprite.y), offset: spriteIndex * 2 + 1)
                        
                        spriteIndex += 1
                    }
                }
            } else {
                sprite.color = .white
                isPressingA = false
            }
            if key.contains(.select) {
                oam.advanced(by: 1).update(repeating: ObjectAttribute(attr0: 0x0200), count: 127)
                spriteIndex = 1
                SRAM.clear()
            }
            
            oam[0] = sprite
            SRAM.write(UInt8(sprite.x), offset: 0)
            SRAM.write(UInt8(sprite.y), offset: 1)
        }
    }
}
