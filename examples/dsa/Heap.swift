/// A binary heap: pop() returns what `areSorted` puts first.
struct Heap<Element> {
  private var items: [Element]
  private let areSorted: (Element, Element) -> Bool

  init(
    _ items: [Element] = [],
    by areSorted: @escaping (Element, Element) -> Bool
  ) {
    self.items = items
    self.areSorted = areSorted
    // Heapify bottom-up in O(n)
    for index in stride(from: items.count / 2 - 1, through: 0, by: -1) {
      siftDown(from: index)
    }
  }

  var count: Int { items.count }
  var isEmpty: Bool { items.isEmpty }
  var peek: Element? { items.first }

  mutating func push(_ item: Element) {
    items.append(item)
    var child = items.count - 1
    while child > 0 {
      let parent = (child - 1) / 2
      guard areSorted(items[child], items[parent]) else { return }
      items.swapAt(child, parent)
      child = parent
    }
  }

  mutating func pop() -> Element? {
    guard !items.isEmpty else { return nil }
    items.swapAt(0, items.count - 1)
    let top = items.removeLast()
    siftDown(from: 0)
    return top
  }

  private mutating func siftDown(from index: Int) {
    var parent = index
    while true {
      var first = parent
      for child in [2 * parent + 1, 2 * parent + 2]
      where child < items.count && areSorted(items[child], items[first])
      {
        first = child
      }
      guard first != parent else { return }
      items.swapAt(parent, first)
      parent = first
    }
  }
}

func demoHeap() {
  var minHeap = Heap([5, 1, 4], by: <)
  minHeap.push(2)
  assert(minHeap.peek == 1)
  assert(minHeap.pop() == 1)
  assert(minHeap.pop() == 2)
  assert(minHeap.count == 2)
  // Flip the comparison for a max-heap
  var maxHeap = Heap([5, 1, 4], by: >)
  assert(maxHeap.pop() == 5)
}

func demoHeapOfTuples() {
  var tasks = Heap<(priority: Int, name: String)>(by: { a, b in
    (a.priority, a.name) < (b.priority, b.name)
  })
  tasks.push((2, "write"))
  tasks.push((1, "plan"))
  tasks.push((2, "test"))
  assert(tasks.pop()?.name == "plan")
  assert(tasks.pop()?.name == "test")
  var jobs = Heap<Job>(by: <)
  jobs.push(Job(priority: 3, name: "ship"))
  assert(jobs.peek?.name == "ship")
}
