enum PathError: Error, Equatable {
  case invalidVertex
  case negativeWeight
  case distanceOverflow
}

func dijkstra(_ graph: [[WeightedEdge]], start: Int) throws -> [Int?] {
  guard graph.indices.contains(start) else { throw PathError.invalidVertex }
  for neighbors in graph {
    for edge in neighbors {
      guard graph.indices.contains(edge.destination) else {
        throw PathError.invalidVertex
      }
      guard edge.weight >= 0 else { throw PathError.negativeWeight }
    }
  }
  var distances = [Int?](repeating: nil, count: graph.count)
  var frontier = BinaryHeap<(distance: Int, vertex: Int)>(
    orderedBefore: { $0.distance < $1.distance }
  )
  distances[start] = 0
  frontier.push((0, start))
  while let current = frontier.pop() {
    guard distances[current.vertex] == current.distance else { continue }
    for edge in graph[current.vertex] {
      let candidate = current.distance.addingReportingOverflow(edge.weight)
      guard !candidate.overflow else { throw PathError.distanceOverflow }
      if let known = distances[edge.destination], known <= candidate.partialValue {
        continue
      }
      distances[edge.destination] = candidate.partialValue
      frontier.push((candidate.partialValue, edge.destination))
    }
  }
  return distances
}
