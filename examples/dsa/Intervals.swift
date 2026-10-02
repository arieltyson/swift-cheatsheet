/// Returns the union of intervals as sorted, non-overlapping ones.
func mergeIntervals(_ intervals: [[Int]]) -> [[Int]] {
  var merged: [[Int]] = []
  for interval in intervals.sorted(by: { $0[0] < $1[0] }) {
    if let last = merged.last, interval[0] <= last[1] {
      merged[merged.count - 1][1] = max(last[1], interval[1])
    } else {
      merged.append(interval)
    }
  }
  return merged
}

/// Returns how many rooms the meetings need at the busiest time.
func minMeetingRooms(_ intervals: [[Int]]) -> Int {
  var endTimes = Heap<Int>(by: <)
  for interval in intervals.sorted(by: { $0[0] < $1[0] }) {
    if let earliest = endTimes.peek, earliest <= interval[0] {
      _ = endTimes.pop()
    }
    endTimes.push(interval[1])
  }
  return endTimes.count
}
