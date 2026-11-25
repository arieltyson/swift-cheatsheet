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

/// Puts each interval in the lowest column free at its start, so
/// overlapping intervals sit side by side, like calendar events.
func assignColumns(_ intervals: [[Int]]) -> [Int] {
  var columnEnds: [Int] = []
  var columns = [Int](repeating: 0, count: intervals.count)
  let order = intervals.indices.sorted {
    intervals[$0][0] < intervals[$1][0]
  }
  for index in order {
    let interval = intervals[index]
    if let free = columnEnds.firstIndex(where: { $0 <= interval[0] }) {
      columnEnds[free] = interval[1]
      columns[index] = free
    } else {
      columnEnds.append(interval[1])
      columns[index] = columnEnds.count - 1
    }
  }
  return columns
}

/// Half-open intervals [start, end) overlap when each starts before
/// the other ends. Back-to-back ([9, 10] and [10, 11]) don't.
func overlaps(_ a: [Int], _ b: [Int]) -> Bool {
  a[0] < b[1] && b[0] < a[1]
}

/// Column and column count for each interval. Intervals that chain
/// together by overlapping form a group; each group splits the width
/// by ITS OWN column count, so a lone interval keeps the full width.
func columnLayout(_ intervals: [[Int]]) -> [(column: Int, count: Int)] {
  let columns = assignColumns(intervals)
  var result = [(column: Int, count: Int)](
    repeating: (0, 1), count: intervals.count)
  var group: [Int] = []
  var groupEnd = Int.min
  func closeGroup() {
    let count = (group.map { columns[$0] }.max() ?? 0) + 1
    for member in group { result[member] = (columns[member], count) }
    group = []
  }
  let order = intervals.indices.sorted {
    intervals[$0][0] < intervals[$1][0]
  }
  for index in order {
    // Starts at or after everything so far ends: a new group
    if intervals[index][0] >= groupEnd { closeGroup() }
    group.append(index)
    groupEnd = max(groupEnd, intervals[index][1])
  }
  closeGroup()
  return result
}

func demoOverlaps() {
  assert(overlaps([9, 11], [10, 12]))
  assert(!overlaps([9, 10], [10, 11]))  // touching is not overlapping
  let layout = columnLayout([[9, 11], [10, 12], [13, 14]])
  assert(layout.map(\.column) == [0, 1, 0])
  // 13-14 overlaps nothing, so it keeps the full width
  assert(layout.map(\.count) == [2, 2, 1])
  let three = columnLayout([[14, 17], [14, 16], [15, 17]])
  assert(three.map(\.count) == [3, 3, 3])
}
