import Testing

@testable import InterviewExamples

@Test func stackAndQueue() {
  #expect(reversedUsingStack([1, 2, 3]) == [3, 2, 1])
  #expect(reversedUsingStack([Int]()).isEmpty)
  var queue = Queue<Int>()
  #expect(queue.dequeue() == nil)
  for value in 0..<1_000 { queue.enqueue(value) }
  for value in 0..<600 { #expect(queue.dequeue() == value) }
  #expect(queue.count == 400)
  for value in 1_000..<1_500 { queue.enqueue(value) }
  for value in 600..<1_500 { #expect(queue.dequeue() == value) }
  #expect(queue.isEmpty)
  queue.enqueue(7)
  #expect(queue.dequeue() == 7)
  var optionalQueue = Queue<Int?>()
  optionalQueue.enqueue(nil)
  optionalQueue.enqueue(4)
  #expect(optionalQueue.count == 2)
  #expect(optionalQueue.dequeue() != nil)
  #expect(optionalQueue.dequeue() == 4)
}

@Test func queueReleasesDequeuedReferences() {
  var queue = Queue<ScoreBox>()
  weak var observed: ScoreBox?
  do {
    let object = ScoreBox()
    observed = object
    queue.enqueue(object)
  }
  queue.enqueue(ScoreBox())
  queue.enqueue(ScoreBox())
  #expect(observed != nil)
  _ = queue.dequeue()
  #expect(observed == nil)
}

@Test func heapsMatchSorting() {
  for size in 0...80 {
    let values = (0..<size).map { ($0 * 37 + size * 11) % 23 - 11 }
    var minimum = BinaryHeap(values, orderedBefore: <)
    var maximum = BinaryHeap<Int>(orderedBefore: >)
    for value in values { maximum.push(value) }
    var ascending: [Int] = []
    var descending: [Int] = []
    while let value = minimum.pop() { ascending.append(value) }
    while let value = maximum.pop() { descending.append(value) }
    #expect(ascending == values.sorted())
    #expect(descending == values.sorted(by: >))
    #expect(minimum.peek == nil)
    #expect(minimum.pop() == nil)
  }
  var original = BinaryHeap([3, 1, 2], orderedBefore: <)
  var copy = original
  copy.push(0)
  #expect(copy.pop() == 0)
  #expect(original.pop() == 1)
}

@Test func nodesAndGraphs() {
  let head = ListNode(1, next: ListNode(2, next: ListNode(3)))
  let reversed = reverseList(head)
  #expect(reversed?.value == 3)
  #expect(reversed?.next?.value == 2)
  #expect(head.next == nil)
  #expect(reverseList(nil as ListNode<Int>?) == nil)
  let root = TreeNode(2)
  root.left = TreeNode(1)
  root.right = TreeNode(3)
  #expect(inorder(root) == [1, 2, 3])
  #expect(inorder(nil as TreeNode<Int>?).isEmpty)
  #expect(adjacencyList(vertexCount: 3, edges: [(0, 1), (1, 2)]) == [[1], [0, 2], [1]])
  #expect(adjacencyList(vertexCount: 2, edges: [(0, 1)], directed: true) == [[1], []])
}
