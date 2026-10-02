/// Returns indices of two sorted values adding to target, or nil.
func pairWithSum(_ values: [Int], _ target: Int) -> (Int, Int)? {
  var left = 0
  var right = values.count - 1
  while left < right {
    let total = values[left] + values[right]
    if total == target { return (left, right) }
    if total < target {
      left += 1
    } else {
      right -= 1
    }
  }
  return nil
}

/// Returns every unique triplet that sums to zero.
func threeSum(_ values: [Int]) -> [[Int]] {
  let sorted = values.sorted()
  var triplets: [[Int]] = []
  for i in sorted.indices.dropLast(2) {
    if i > 0 && sorted[i] == sorted[i - 1] { continue }
    var left = i + 1
    var right = sorted.count - 1
    while left < right {
      let total = sorted[i] + sorted[left] + sorted[right]
      if total < 0 {
        left += 1
      } else if total > 0 {
        right -= 1
      } else {
        triplets.append([sorted[i], sorted[left], sorted[right]])
        left += 1
        right -= 1
        while left < right && sorted[left] == sorted[left - 1] {
          left += 1
        }
      }
    }
  }
  return triplets
}

/// Dedupes sorted values in place and returns the new length.
func removeDuplicates(_ values: inout [Int]) -> Int {
  var write = 0
  for value in values where write == 0 || value != values[write - 1] {
    values[write] = value
    write += 1
  }
  return write
}

/// Returns true if text reads the same both ways (letters only).
func isPalindrome(_ text: String) -> Bool {
  let chars = text.lowercased().filter { $0.isLetter || $0.isNumber }
  let letters = Array(chars)
  var left = 0
  var right = letters.count - 1
  while left < right {
    if letters[left] != letters[right] { return false }
    left += 1
    right -= 1
  }
  return true
}
