@c
public func putchar(_ c: CInt) -> CInt {
    mGBA.enableLog()
    if c == 0x0A {
        mGBA.flush(as: .warn)
    } else {
        mGBA.putchar(c)
    }
    return c
}
