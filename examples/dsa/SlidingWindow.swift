/// Returns the largest sum of `size` consecutive values.
func maxWindowSum(_ values: [Int], size: Int) -> Int {
  var window = values.prefix(size).reduce(0, +)
  var best = window
  for end in size..<values.count {
    window += values[end] - values[end - size]
    best = max(best, window)
  }
  return best
}

/// Returns the longest substring length with at most k distinct.
func longestWithKDistinct(_ text: String, _ k: Int) -> Int {
  let chars = Array(text)
  var counts: [Character: Int] = [:]
  var start = 0
  var best = 0
  for end in chars.indices {
    counts[chars[end], default: 0] += 1
    while counts.count > k {
      let leaving = chars[start]
      counts[leaving]! -= 1
      if counts[leaving] == 0 { counts[leaving] = nil }
      start += 1
    }
    best = max(best, end - start + 1)
  }
  return best
}

/// Returns the longest substring length with no repeated chars.
func longestUniqueSubstring(_ text: String) -> Int {
  var lastSeen: [Character: Int] = [:]
  var start = 0
  var best = 0
  for (end, char) in text.enumerated() {
    if let previous = lastSeen[char], previous >= start {
      start = previous + 1
    }
    lastSeen[char] = end
    best = max(best, end - start + 1)
  }
  return best
}

/// Returns the largest value in each window of size k.
func slidingWindowMax(_ values: [Int], k: Int) -> [Int] {
  guard k > 0 else { return [] }
  // Indices whose values strictly decrease from head to end
  var deque: [Int] = []
  var head = 0
  var result: [Int] = []
  for (index, value) in values.enumerated() {
    // A smaller, older value can never be the largest again
    while deque.count > head, values[deque[deque.count - 1]] <= value {
      deque.removeLast()
    }
    deque.append(index)
    if deque[head] <= index - k {
      head += 1
    }
    if index >= k - 1 {
      result.append(values[deque[head]])
    }
  }
  return result
}
