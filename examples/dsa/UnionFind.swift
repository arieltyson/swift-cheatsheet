struct UnionFind {
  private var parent: [Int]
  private var size: [Int]
  private(set) var components: Int

  init(count: Int) {
    parent = Array(0..<count)
    size = Array(repeating: 1, count: count)
    components = count
  }

  mutating func find(_ node: Int) -> Int {
    var node = node
    // Path halving: point each visited node at its grandparent
    while parent[node] != node {
      parent[node] = parent[parent[node]]
      node = parent[node]
    }
    return node
  }

  /// Joins two sets; returns false if they were already one set.
  mutating func union(_ first: Int, _ second: Int) -> Bool {
    var rootA = find(first)
    var rootB = find(second)
    guard rootA != rootB else { return false }
    if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
    parent[rootB] = rootA
    size[rootA] += size[rootB]
    components -= 1
    return true
  }
}

func demoUnionFind() {
  var groups = UnionFind(count: 4)
  assert(groups.union(0, 1) == true)
  assert(groups.union(2, 3) == true)
  // Already connected: in an edge list this edge closes a cycle
  assert(groups.union(1, 0) == false)
  assert(groups.find(0) == groups.find(1))
  assert(groups.components == 2)
}
