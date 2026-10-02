/// Returns every subset of values.
func subsets(_ values: [Int]) -> [[Int]] {
  var result: [[Int]] = []
  var path: [Int] = []
  func explore(_ start: Int) {
    result.append(path)
    for i in start..<values.count {
      path.append(values[i])
      explore(i + 1)
      path.removeLast()
    }
  }
  explore(0)
  return result
}

/// Returns every way to choose `size` values, order ignored.
func combinations(_ values: [Int], size: Int) -> [[Int]] {
  var result: [[Int]] = []
  var path: [Int] = []
  func explore(_ start: Int) {
    if path.count == size {
      result.append(path)
      return
    }
    for i in start..<values.count {
      path.append(values[i])
      explore(i + 1)
      path.removeLast()
    }
  }
  explore(0)
  return result
}

/// Returns every ordering of values.
func permutations(_ values: [Int]) -> [[Int]] {
  var result: [[Int]] = []
  var path: [Int] = []
  var used = Array(repeating: false, count: values.count)
  func explore() {
    if path.count == values.count {
      result.append(path)
      return
    }
    for (i, value) in values.enumerated() where !used[i] {
      used[i] = true
      path.append(value)
      explore()
      path.removeLast()
      used[i] = false
    }
  }
  explore()
  return result
}
