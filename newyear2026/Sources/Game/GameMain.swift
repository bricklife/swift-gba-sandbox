// Affine Transformation Logic: https://www.coranac.com/tonc/text/mode7.htm

typealias Fixed = Int32 // 24.8

struct Vector: Equatable {
    var x: Fixed
    var y: Fixed
    var z: Fixed
}

struct Camera {
    var position: Vector
    var phi: UInt16
    var d: Int32
    
    init(position: Vector, phi: UInt16, d: Int32) {
        self.position = position
        self.phi = phi
        self.d = d
    }
}

extension Camera {
    static let initial = Camera(
        position: .init(x: 128 << 8, y: 80 << 8, z: 128 << 8),
        phi: 0,
        d: 300,
    )
    
    func cosPhi() -> Fixed {
        Fixed(Math.cos(phi) >> 4)
    }
    
    func sinPhi() -> Fixed {
        Fixed(Math.sin(phi) >> 4)
    }
}

nonisolated(unsafe) var camera = Camera.initial

@_section(".iwram")
func irqHandler() {
    REG_IME.store(0)
    
    let flag = REG_IF.load()
    if flag & IRQ_HBLANK != 0 {
        let vcount = REG_VCOUNT.load()
        switch vcount {
        case 0..<159:
            applyEffect(for: UInt8(vcount) + 1)
        case 160:
            camera.position.z += (1 << 6)
            applyEffect(for: 0)
        default:
            break
        }
    }
    if flag & IRQ_KEYPAD != 0 {
        camera = .initial
    }
    REG_IF.store(flag)
    
    REG_IME.store(1)
}

@_section(".iwram")
func applyEffect(for y: UInt8) {
    let d = Int32(bitPattern: Math.div(y))
    let lam = (camera.position.y &* d) >> 12
    let lcf = (lam &* camera.cosPhi()) >> 8
    let lsf = (lam &* camera.sinPhi()) >> 8
    
    REG_BG2PA.store(.init(truncatingIfNeeded: lcf >> 4))
    REG_BG2PC.store(.init(truncatingIfNeeded: lsf >> 4))
    
    let lxr = 120 * (lcf >> 4)
    let lyr = (camera.d * lsf) >> 4
    REG_BG2X.store(camera.position.x - lxr + lyr)
    
    let lxr2 = 120 * (lsf >> 4)
    let lyr2 = (camera.d * lcf) >> 4
    REG_BG2Y.store(camera.position.z - lxr2 - lyr2)
    
    switch y {
    case 0..<48:
        REG_BLDY.store(16)
    case 48..<80:
        REG_BLDY.store(16 - UInt16((y - 48) >> 1))
    default:
        REG_BLDY.store(0)
    }
}

@main
struct GameMain {
    static func setupIRQ() {
        REG_IME.store(0)
        
        let funcAddress = unsafeBitCast(irqHandler as @convention(c) () -> Void, to: UInt32.self)
        INT_VECTOR.store(funcAddress)
        REG_DISPSTAT.store(LCDC_HBL)
        REG_KEYCNT.store(KEYIRQ_ENABLE | KEY_ANY)
        REG_IE.store(IRQ_HBLANK | IRQ_KEYPAD)
        
        REG_IME.store(1)
    }
    
    static func setupBackground() {
        let bgPalette = UnsafeMutablePointer<UInt16>(bitPattern: 0x5000000)!
        bgPalette.update(from: Background.palette, count: Background.palette.count)
        
        // BG2: Scale/Rotate Background (for Scrolling text)
        let bg2Tile = UnsafeMutablePointer<UInt16>(bitPattern: 0x6000000 + (0x4000 * 0))!
        bg2Tile.update(from: Background.tile, count: Background.tile.count)
        
        let bg2Map = UnsafeMutablePointer<UInt16>(bitPattern: 0x6000000 + (0x800 * 27))!
        bg2Map.update(from: Background.map, count: Background.map.count)
        
        REG_BG2CNT.store(BG_TILE_BASE(0) | BG_256_COLOR | BG_MAP_BASE(27) | BG_SIZE(1))
        REG_BLDCNT.store(BLEND_TOP_BG2 | BLEND_MODE_DARK)
        
        // BG0: Normal Tile Background (for Random stars)
        let bg0Tile = UnsafeMutablePointer<UInt16>(bitPattern: 0x6000000 + (0x4000 * 1))!
        let n = 240 * 160 / 2
        bg0Tile.update(repeating: 0x0000, count: n)
        for _ in 0..<50 {
            bg0Tile[.random(in: 0..<n)] = .random(in: 0x0001...0x000F)
        }
        
        let bg0Map = UnsafeMutablePointer<UInt16>(bitPattern: 0x6000000 + (0x800 * 28))!
        for y in 0..<20 {
            for x in 0..<30 {
                bg0Map[y * 32 + x] = UInt16(y * 30 + x)
            }
        }
        
        REG_BG0CNT.store(BG_TILE_BASE(1) | BG_256_COLOR | BG_MAP_BASE(28) | BG_SIZE(0) | BG_PRIORITY(1))
        
        REG_DISPCNT.store(MODE_1 | BG0_ENABLE | BG2_ENABLE)
    }
    
    static func main() {
        setupIRQ()
        setupBackground()
        
        while true {}
    }
}
