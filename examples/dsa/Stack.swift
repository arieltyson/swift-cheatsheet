func reversedUsingStack<Element>(_ values: [Element]) -> [Element] {
  var stack: [Element] = []
  for value in values {
    stack.append(value)
  }
  var reversed: [Element] = []
  reversed.reserveCapacity(values.count)
  while let top = stack.popLast() {
    reversed.append(top)
  }
  return reversed
}
