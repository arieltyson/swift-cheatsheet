func greatestCommonDivisor(_ first: UInt, _ second: UInt) -> UInt {
    var remainder = first
    var divisor = second
    while divisor != 0 {
        (remainder, divisor) = (divisor, remainder % divisor)
    }
    return remainder
}

func numberExample() -> (quotient: Int, remainder: Int, rounded: Double) {
    let quotient = -7 / 3
    let remainder = -7 % 3
    let addition = Int.max.addingReportingOverflow(1)
    precondition(addition.overflow)
    let magnitude = Int.min.magnitude
    precondition(magnitude > UInt(Int.max))
    let squareRoot = 81.0.squareRoot()
    let rounded = 2.5.rounded(.toNearestOrEven)
    let clipped = min(max(15, 0), 10)
    let mask: UInt = 1 << 3
    let flags: UInt = 0b1010
    precondition(flags & mask != 0)
    precondition(flags.nonzeroBitCount == 2)
    precondition(squareRoot == 9 && clipped == 10)
    return (quotient, remainder, rounded)
}
