struct PrefixSums {
    private let totals: [Int]

    init(_ values: [Int]) {
        var running = [0]
        running.reserveCapacity(values.count + 1)
        for value in values {
            running.append(running[running.count - 1] + value)
        }
        totals = running
    }

    func sum(in range: Range<Int>) -> Int {
        precondition(range.lowerBound >= 0 && range.upperBound < totals.count)
        return totals[range.upperBound] - totals[range.lowerBound]
    }
}
