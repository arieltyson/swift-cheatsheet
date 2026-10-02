func twoSumSorted(_ values: [Int], target: Int) -> (Int, Int)? {
    guard values.count >= 2 else { return nil }
    var left = 0
    var right = values.count - 1
    while left < right {
        let sum = values[left].addingReportingOverflow(values[right])
        if sum.overflow {
            if values[left] > 0 {
                right -= 1
            } else {
                left += 1
            }
        } else if sum.partialValue == target {
            return (left, right)
        } else if sum.partialValue < target {
            left += 1
        } else {
            right -= 1
        }
    }
    return nil
}
