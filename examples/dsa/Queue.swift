struct Queue<Element> {
  private var storage: [Element?] = []
  private var head = 0

  var count: Int { storage.count - head }
  var isEmpty: Bool { count == 0 }

  mutating func enqueue(_ value: Element) {
    storage.append(value)
  }

  mutating func dequeue() -> Element? {
    guard head < storage.count else { return nil }
    let value = storage[head]
    storage[head] = nil
    head += 1
    if head >= storage.count - head {
      storage.removeFirst(head)
      head = 0
    }
    return value
  }
}
