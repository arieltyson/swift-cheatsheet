struct WeightedEdge {
  let destination: Int
  let weight: Int
}

func adjacencyList(
  vertexCount: Int,
  edges: [(source: Int, destination: Int)],
  directed: Bool = false
) -> [[Int]] {
  precondition(vertexCount >= 0)
  var neighbors = Array(repeating: [Int](), count: vertexCount)
  for edge in edges {
    precondition(neighbors.indices.contains(edge.source))
    precondition(neighbors.indices.contains(edge.destination))
    neighbors[edge.source].append(edge.destination)
    if !directed {
      neighbors[edge.destination].append(edge.source)
    }
  }
  return neighbors
}
