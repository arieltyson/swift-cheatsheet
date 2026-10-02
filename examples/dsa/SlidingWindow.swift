func longestUniqueSubstring(_ text: String) -> Int {
  var lastIndex: [Character: Int] = [:]
  var left = 0
  var longest = 0
  for (right, character) in text.enumerated() {
    if let previous = lastIndex[character], previous >= left {
      left = previous + 1
    }
    lastIndex[character] = right
    longest = max(longest, right - left + 1)
  }
  return longest
}
