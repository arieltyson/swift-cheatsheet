/// Returns the shortest distance from source to every node, nil if
/// unreachable. graph[node] = [(to, weight)], all weights >= 0.
func dijkstra(_ graph: [[(to: Int, weight: Int)]], source: Int)
  -> [Int?]
{
  var distances = [Int?](repeating: nil, count: graph.count)
  distances[source] = 0
  var heap = Heap([(distance: 0, node: source)]) {
    $0.distance < $1.distance
  }
  while let (distance, node) = heap.pop() {
    // Skip stale entries left behind by a later, shorter path
    guard distance == distances[node] else { continue }
    for (neighbor, weight) in graph[node] {
      let candidate = distance + weight
      if candidate < distances[neighbor] ?? .max {
        distances[neighbor] = candidate
        heap.push((candidate, neighbor))
      }
    }
  }
  return distances
}
