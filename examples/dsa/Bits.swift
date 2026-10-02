func demoBits() {
  let value = 0b1100
  assert(value & 1 == 0)
  assert(value >> 2 == 0b11)
  assert((value >> 3) & 1 == 1)
  assert(value | 1 << 0 == 0b1101)
  assert(value ^ 1 << 2 == 0b1000)
  // Clear the lowest set bit, and isolate it
  assert(value & (value - 1) == 0b1000)
  assert(value & -value == 0b100)
  assert(value.nonzeroBitCount == 2)
  assert(value.trailingZeroBitCount == 2)
  let isPowerOfTwo = value > 0 && value & (value - 1) == 0
  assert(isPowerOfTwo == false)
}

func demoBitmaskSubsets() {
  let items = ["a", "b", "c"]
  let subsets = (0..<(1 << items.count)).map { mask in
    items.indices.filter { mask >> $0 & 1 == 1 }.map { items[$0] }
  }
  assert(subsets.count == 8)
  assert(subsets[0b101] == ["a", "c"])
}

/// Returns the value that appears once when the rest appear twice.
func singleNumber(_ values: [Int]) -> Int {
  values.reduce(0, ^)
}
