struct KeyCounter {
  var currentKeys = Key()

  var a = 0
  var b = 0
  var select = 0
  var start = 0
  var right = 0
  var left = 0
  var up = 0
  var down = 0
  var r = 0
  var l = 0

  mutating func poll() {
    currentKeys = Key.poll()
    a = currentKeys.contains(.a) ? a + 1 : 0
    b = currentKeys.contains(.b) ? b + 1 : 0
    select = currentKeys.contains(.select) ? select + 1 : 0
    start = currentKeys.contains(.start) ? start + 1 : 0
    right = currentKeys.contains(.right) ? right + 1 : 0
    left = currentKeys.contains(.left) ? left + 1 : 0
    up = currentKeys.contains(.up) ? up + 1 : 0
    down = currentKeys.contains(.down) ? down + 1 : 0
    r = currentKeys.contains(.r) ? r + 1 : 0
    l = currentKeys.contains(.l) ? l + 1 : 0
  }
}
