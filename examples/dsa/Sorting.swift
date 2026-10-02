/// Returns a new sorted array (stable).
func mergeSort(_ values: [Int]) -> [Int] {
  guard values.count > 1 else { return values }
  let middle = values.count / 2
  let left = mergeSort(Array(values[..<middle]))
  let right = mergeSort(Array(values[middle...]))
  var merged: [Int] = []
  merged.reserveCapacity(values.count)
  var (i, j) = (0, 0)
  while i < left.count && j < right.count {
    if left[i] <= right[j] {
      merged.append(left[i])
      i += 1
    } else {
      merged.append(right[j])
      j += 1
    }
  }
  return merged + left[i...] + right[j...]
}

/// Returns the k-th largest value (k = 1 is the maximum).
func kthLargest(_ values: [Int], _ k: Int) -> Int {
  var candidates = values
  var k = k
  while true {
    let pivot = candidates.randomElement()!
    let larger = candidates.filter { $0 > pivot }
    let equal = candidates.count(where: { $0 == pivot })
    if k <= larger.count {
      candidates = larger
    } else if k <= larger.count + equal {
      return pivot
    } else {
      k -= larger.count + equal
      candidates = candidates.filter { $0 < pivot }
    }
  }
}

/// Returns the k largest values, largest first.
func topKLargest(_ values: [Int], _ k: Int) -> [Int] {
  // Min-heap of the best k so far; peek is the weakest of them
  var best = Heap<Int>(by: <)
  for value in values {
    if best.count < k {
      best.push(value)
    } else if let weakest = best.peek, value > weakest {
      _ = best.pop()
      best.push(value)
    }
  }
  var result: [Int] = []
  while let value = best.pop() { result.append(value) }
  return result.reversed()
}
