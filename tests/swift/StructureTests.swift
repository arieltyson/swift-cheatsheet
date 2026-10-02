import Testing

@testable import InterviewExamples

@Test func firstEvenFindsOrReturnsNil() {
  #expect(firstEven([3, 4, 6]) == 4)
  #expect(firstEven([1, 3]) == nil)
}

@Test func queueMatchesAnArrayModel() {
  var queue = Queue<Int>()
  var model: [Int] = []
  var generator = SystemRandomNumberGenerator()
  for step in 0..<5_000 {
    if Int.random(in: 0..<3, using: &generator) == 0 {
      #expect(
        queue.dequeue() == (model.isEmpty ? nil : model.removeFirst()))
    } else {
      queue.enqueue(step)
      model.append(step)
    }
    #expect(queue.count == model.count)
    #expect(queue.peek == model.first)
  }
}

@Test func balancedBrackets() {
  for text in ["", "()", "([]{})", "a(b)c", "{[()()]}"] {
    #expect(isBalanced(text), "\(text)")
  }
  for text in ["(", ")", "(]", "([)]", "(()", "}{"] {
    #expect(!isBalanced(text), "\(text)")
  }
}

@Test func heapPopsInSortedOrder() {
  for _ in 0..<200 {
    let values = (0..<Int.random(in: 0...30)).map { _ in
      Int.random(in: 0...20)
    }
    var heap = Heap(values, by: <)
    var popped: [Int] = []
    while let value = heap.pop() { popped.append(value) }
    #expect(popped == values.sorted())
  }
}

@Test func heapMatchesAModelUnderMixedOperations() {
  var heap = Heap<Int>(by: >)
  var model: [Int] = []
  for _ in 0..<3_000 {
    if Bool.random() && !model.isEmpty {
      model.sort(by: >)
      #expect(heap.pop() == model.removeFirst())
    } else {
      let value = Int.random(in: 0...100)
      heap.push(value)
      model.append(value)
    }
    #expect(heap.count == model.count)
    #expect(heap.peek == model.max())
  }
}

@Test func linkedLists() {
  #expect(listValues(buildList([1, 2, 3])) == [1, 2, 3])
  #expect(buildList([]) == nil)
  for values in [[], [1], [1, 2, 3]] {
    #expect(
      listValues(reverseList(buildList(values))) == values.reversed())
  }
  #expect(middleNode(nil) == nil)
  #expect(middleNode(buildList([1, 2, 3]))?.val == 2)
  #expect(middleNode(buildList([1, 2, 3, 4]))?.val == 3)
  #expect(!hasCycle(buildList([1, 2, 3])))
  let head = buildList([1, 2, 3])!
  head.next!.next!.next = head.next
  #expect(hasCycle(head))
  head.next!.next!.next = nil
  let merged = mergeSorted(buildList([1, 4, 5]), buildList([1, 2, 6]))
  #expect(listValues(merged) == [1, 1, 2, 4, 5, 6])
  #expect(listValues(mergeSorted(nil, buildList([2]))) == [2])
}

//       4
//     2   6
//    1 3 5 7
let balanced: [Int?] = [4, 2, 6, 1, 3, 5, 7]

@Test func treesAndBSTs() {
  #expect(buildTree([]) == nil)
  #expect(buildTree([nil]) == nil)
  let gapped = buildTree([1, nil, 2, 3])!
  #expect(gapped.left == nil)
  #expect(gapped.right?.left?.val == 3)
  let (pre, inorder, post) = traversals(buildTree(balanced))
  #expect(pre == [4, 2, 1, 3, 6, 5, 7])
  #expect(inorder == [1, 2, 3, 4, 5, 6, 7])
  #expect(post == [1, 3, 2, 5, 7, 6, 4])
  for values in [balanced, [1, nil, 2, 3], [5, 3, nil, 2]] {
    let root = buildTree(values)
    #expect(inorderIterative(root) == traversals(root).inorder)
  }
  #expect(
    levelOrder(buildTree(balanced)) == [[4], [2, 6], [1, 3, 5, 7]])
  #expect(levelOrder(nil).isEmpty)
  #expect(maxDepth(buildTree([1, nil, 2, nil, 3])) == 3)
  var root: TreeNode?
  for value in [5, 3, 8, 1, 4, 9] { root = bstInsert(root, value) }
  #expect(traversals(root).inorder == [1, 3, 4, 5, 8, 9])
  #expect(isValidBST(root))
  #expect(!isValidBST(buildTree([5, 1, 6, nil, nil, 4, 7])))
  #expect(!isValidBST(TreeNode(2, TreeNode(2))))
}

@Test func trieAndUnionFind() {
  let words = Trie()
  #expect(!words.search("a"))
  #expect(words.startsWith(""))
  for word in ["car", "card", "care", "dog"] { words.insert(word) }
  #expect(words.search("card"))
  #expect(!words.search("ca"))
  #expect(words.startsWith("ca"))
  #expect(!words.startsWith("cat"))
  var groups = UnionFind(count: 100_000)
  for node in 1..<100_000 { _ = groups.union(node - 1, node) }
  #expect(groups.components == 1)
  var cycle = UnionFind(count: 3)
  let redundant = [(0, 1), (1, 2), (2, 0)].filter {
    !cycle.union($0.0, $0.1)
  }
  #expect(redundant.map(\.0) == [2])
}

@Test func graphHelpers() {
  #expect(buildGraph(count: 3, edges: [(0, 1)]) == [[1], [0], []])
  #expect(
    buildGraph(count: 2, edges: [(0, 1)], directed: true) == [[1], []])
  #expect(gridNeighbors(rows: 3, cols: 3, row: 1, col: 1).count == 4)
  #expect(gridNeighbors(rows: 1, cols: 1, row: 0, col: 0).isEmpty)
}
