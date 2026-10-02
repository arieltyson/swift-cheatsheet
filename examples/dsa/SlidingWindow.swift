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
