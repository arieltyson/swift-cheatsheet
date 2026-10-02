/// Returns the next larger value to the right of each item, or -1.
func nextGreater(_ values: [Int]) -> [Int] {
  var result = Array(repeating: -1, count: values.count)
  // Indices still waiting for a larger value; their values decrease
  var waiting: [Int] = []
  for (index, value) in values.enumerated() {
    while let last = waiting.last, values[last] < value {
      result[waiting.removeLast()] = value
    }
    waiting.append(index)
  }
  return result
}
