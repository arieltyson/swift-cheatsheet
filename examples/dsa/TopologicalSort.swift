/// Returns nodes 0..<count so every edge (a, b) puts a before b,
/// or nil if the edges contain a cycle.
func topologicalOrder(count: Int, edges: [(Int, Int)]) -> [Int]? {
  var graph = Array(repeating: [Int](), count: count)
  var inDegree = Array(repeating: 0, count: count)
  for (before, after) in edges {
    graph[before].append(after)
    inDegree[after] += 1
  }
  var order = (0..<count).filter { inDegree[$0] == 0 }
  // order doubles as the queue: read it with a moving head
  var head = 0
  while head < order.count {
    for next in graph[order[head]] {
      inDegree[next] -= 1
      if inDegree[next] == 0 { order.append(next) }
    }
    head += 1
  }
  return order.count == count ? order : nil
}
