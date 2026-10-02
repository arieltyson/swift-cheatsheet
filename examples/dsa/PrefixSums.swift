/// Returns sums where prefix[i] is the sum of values[0..<i].
func prefixSums(_ values: [Int]) -> [Int] {
  var prefix = [0]
  for value in values {
    prefix.append(prefix.last! + value)
  }
  return prefix
}

func demoRangeSum() {
  let prefix = prefixSums([3, 1, 4, 1])
  assert(prefix == [0, 3, 4, 8, 9])
  // Sum of values[left...right] in O(1)
  let (left, right) = (1, 3)
  assert(prefix[right + 1] - prefix[left] == 6)
}

/// Returns how many contiguous subarrays sum to target.
func countSubarraysWithSum(_ values: [Int], _ target: Int) -> Int {
  var seen = [0: 1]
  var running = 0
  var count = 0
  for value in values {
    running += value
    count += seen[running - target, default: 0]
    seen[running, default: 0] += 1
  }
  return count
}
