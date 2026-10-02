func demoIntegerDivision() {
  assert(7 / 2 == 3)
  // Integer division truncates toward zero
  assert(-7 / 2 == -3)
  // % keeps the sign of the left side
  assert(-7 % 2 == -1)
  assert(((-7 % 2) + 2) % 2 == 1)
  assert(7.quotientAndRemainder(dividingBy: 2) == (3, 1))
  // Ceiling division for non-negative values
  assert((7 + 2 - 1) / 2 == 4)
  assert(Double(7) / 2 == 3.5)
}

func demoOverflow() {
  assert(Int.max == 9_223_372_036_854_775_807)
  // Int.max + 1 traps at run time; &+ wraps around
  assert(Int.max &+ 1 == Int.min)
  let (sum, didOverflow) = Int.max.addingReportingOverflow(1)
  assert(didOverflow)
  assert(sum == Int.min)
  // abs(Int.min) also traps: there is no positive counterpart
  assert(Int.min.magnitude == UInt(Int.max) + 1)
  let modulus = 1_000_000_007
  assert((123_456_789 * 987_654_321) % modulus == 259_106_859)
}

func demoMath() {
  assert(abs(-7) == 7)
  assert(min(4, 9) == 4)
  assert(max(4, 9, 2) == 9)
  assert(Double(16).squareRoot() == 4)
  assert(Int(Double(17).squareRoot()) == 4)
  assert(Double.pi > 3.14)
  assert(Int.max > 1 << 62)
  assert(Double.infinity > Double.greatestFiniteMagnitude)
  assert([3, 1, 2].min() == 1)
}

/// Returns the greatest common divisor of a and b.
func gcd(_ a: Int, _ b: Int) -> Int {
  var (a, b) = (abs(a), abs(b))
  while b != 0 {
    (a, b) = (b, a % b)
  }
  return a
}

func demoGcd() {
  assert(gcd(12, 18) == 6)
  let lcm = 4 / gcd(4, 6) * 6
  assert(lcm == 12)
}
