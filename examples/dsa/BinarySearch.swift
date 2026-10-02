/// Returns an index of target in sorted values, or nil.
func binarySearch(_ values: [Int], _ target: Int) -> Int? {
  var low = 0
  var high = values.count - 1
  while low <= high {
    let middle = low + (high - low) / 2
    if values[middle] == target { return middle }
    if values[middle] < target {
      low = middle + 1
    } else {
      high = middle - 1
    }
  }
  return nil
}

/// Returns the first index with value >= target (count if none).
func lowerBound(_ values: [Int], _ target: Int) -> Int {
  var low = 0
  var high = values.count
  while low < high {
    let middle = low + (high - low) / 2
    if values[middle] < target {
      low = middle + 1
    } else {
      high = middle
    }
  }
  return low
}

/// Returns the first index with value > target (count if none).
func upperBound(_ values: [Int], _ target: Int) -> Int {
  var low = 0
  var high = values.count
  while low < high {
    let middle = low + (high - low) / 2
    if values[middle] <= target {
      low = middle + 1
    } else {
      high = middle
    }
  }
  return low
}

/// Returns the smallest x in low...high with isValid(x) true.
/// isValid must be false...false, true...true, and true at high.
func firstTrue(
  _ low: Int, _ high: Int, _ isValid: (Int) -> Bool
) -> Int {
  var (low, high) = (low, high)
  while low < high {
    let middle = low + (high - low) / 2
    if isValid(middle) {
      high = middle
    } else {
      low = middle + 1
    }
  }
  return low
}

/// Returns the slowest speed that finishes every pile in time.
func minEatingSpeed(_ piles: [Int], _ hours: Int) -> Int {
  firstTrue(1, piles.max() ?? 1) { speed in
    piles.reduce(0) { $0 + ($1 + speed - 1) / speed } <= hours
  }
}
