func demoStack() {
  var stack: [Int] = []
  stack.append(1)
  stack.append(2)
  assert(stack.last == 2)
  assert(stack.popLast() == 2)
  assert(stack.removeLast() == 1)
  assert(stack.popLast() == nil)
}

func demoHeadIndexQueue() {
  // removeFirst() is O(n); a moving head index reads in O(1)
  var queue = [1]
  var head = 0
  var order: [Int] = []
  while head < queue.count {
    let value = queue[head]
    head += 1
    order.append(value)
    if value < 4 { queue.append(value * 2) }
  }
  assert(order == [1, 2, 4])
}

/// A FIFO queue with O(1) amortized enqueue and dequeue.
struct Queue<Element> {
  private var items: [Element] = []
  private var head = 0

  var count: Int { items.count - head }
  var isEmpty: Bool { count == 0 }
  var peek: Element? { isEmpty ? nil : items[head] }

  mutating func enqueue(_ item: Element) {
    items.append(item)
  }

  mutating func dequeue() -> Element? {
    guard head < items.count else { return nil }
    let item = items[head]
    head += 1
    // Drop the used half now and then so memory stays O(n)
    if head * 2 >= items.count {
      items.removeFirst(head)
      head = 0
    }
    return item
  }
}

func demoQueue() {
  var queue = Queue<String>()
  queue.enqueue("first")
  queue.enqueue("second")
  assert(queue.peek == "first")
  assert(queue.dequeue() == "first")
  assert(queue.count == 1)
}

/// Returns true if every bracket in text closes in order.
func isBalanced(_ text: String) -> Bool {
  let openingFor: [Character: Character] = [
    ")": "(", "]": "[", "}": "{",
  ]
  var stack: [Character] = []
  for char in text {
    if "([{".contains(char) {
      stack.append(char)
    } else if let opening = openingFor[char] {
      guard stack.popLast() == opening else { return false }
    }
  }
  return stack.isEmpty
}
