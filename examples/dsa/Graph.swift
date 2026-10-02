/// Returns adjacency lists for nodes 0..<count.
func buildGraph(
  count: Int, edges: [(Int, Int)], directed: Bool = false
) -> [[Int]] {
  var graph = Array(repeating: [Int](), count: count)
  for (from, to) in edges {
    graph[from].append(to)
    if !directed { graph[to].append(from) }
  }
  return graph
}

/// Returns graph[from] = [(to, weight)] for directed edges.
func buildWeightedGraph(
  count: Int, edges: [(Int, Int, Int)]
) -> [[(to: Int, weight: Int)]] {
  var graph = Array(repeating: [(to: Int, weight: Int)](), count: count)
  for (from, to, weight) in edges {
    graph[from].append((to, weight))
  }
  return graph
}

/// Returns the in-bounds cells up, down, left and right of a cell.
func gridNeighbors(
  rows: Int, cols: Int, row: Int, col: Int
) -> [(row: Int, col: Int)] {
  [(1, 0), (-1, 0), (0, 1), (0, -1)].compactMap { step in
    let (nextRow, nextCol) = (row + step.0, col + step.1)
    let inRows = (0..<rows).contains(nextRow)
    return inRows && (0..<cols).contains(nextCol)
      ? (nextRow, nextCol) : nil
  }
}

func demoGraphs() {
  let graph = buildGraph(count: 3, edges: [(0, 1), (1, 2)])
  assert(graph[1] == [0, 2])
  let weighted = buildWeightedGraph(count: 3, edges: [(0, 2, 7)])
  assert(weighted[0].first?.weight == 7)
  let neighbors = gridNeighbors(rows: 2, cols: 2, row: 0, col: 0)
  assert(neighbors.count == 2)
}
