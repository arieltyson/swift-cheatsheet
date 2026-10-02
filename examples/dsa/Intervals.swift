func mergeIntervals(_ intervals: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
  let sorted = intervals.sorted { $0.lowerBound < $1.lowerBound }
  var merged: [ClosedRange<Int>] = []
  for interval in sorted {
    if let last = merged.last, interval.lowerBound <= last.upperBound {
      merged[merged.count - 1] = last.lowerBound...max(last.upperBound, interval.upperBound)
    } else {
      merged.append(interval)
    }
  }
  return merged
}
