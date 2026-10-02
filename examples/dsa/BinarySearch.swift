func lowerBound(_ values: [Int], target: Int) -> Int {
  var lower = 0
  var upper = values.count
  while lower < upper {
    let middle = lower + (upper - lower) / 2
    if values[middle] < target {
      lower = middle + 1
    } else {
      upper = middle
    }
  }
  return lower
}

func binarySearch(_ values: [Int], target: Int) -> Int? {
  let index = lowerBound(values, target: target)
  guard index < values.count, values[index] == target else { return nil }
  return index
}
