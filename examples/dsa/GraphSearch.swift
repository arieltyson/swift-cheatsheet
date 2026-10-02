/// Returns nodes reachable from start, nearest first.
func bfsOrder(_ graph: [[Int]], start: Int) -> [Int] {
  var visited = Array(repeating: false, count: graph.count)
  visited[start] = true
  var queue = [start]
  var head = 0
  while head < queue.count {
    let node = queue[head]
    head += 1
    for neighbor in graph[node] where !visited[neighbor] {
      visited[neighbor] = true
      queue.append(neighbor)
    }
  }
  return queue
}

/// Returns the fewest steps from start to goal on 0 cells, or nil.
func shortestPathGrid(
  _ grid: [[Int]], from start: (Int, Int), to goal: (Int, Int)
) -> Int? {
  var steps = grid.map { $0.map { _ in -1 } }
  steps[start.0][start.1] = 0
  var queue = [start]
  var head = 0
  while head < queue.count {
    let (row, col) = queue[head]
    head += 1
    if (row, col) == goal { return steps[row][col] }
    let rows = grid.count
    let cols = grid[0].count
    for next in gridNeighbors(
      rows: rows, cols: cols, row: row, col: col)
    where grid[next.row][next.col] == 0
      && steps[next.row][next.col] == -1
    {
      steps[next.row][next.col] = steps[row][col] + 1
      queue.append((next.row, next.col))
    }
  }
  return nil
}

/// Returns nodes reachable from start in depth-first order.
func dfsRecursive(_ graph: [[Int]], start: Int) -> [Int] {
  var visited = Array(repeating: false, count: graph.count)
  var order: [Int] = []
  func visit(_ node: Int) {
    visited[node] = true
    order.append(node)
    for neighbor in graph[node] where !visited[neighbor] {
      visit(neighbor)
    }
  }
  visit(start)
  return order
}

/// Returns the dfsRecursive order using an explicit stack.
func dfsIterative(_ graph: [[Int]], start: Int) -> [Int] {
  var visited = Array(repeating: false, count: graph.count)
  var order: [Int] = []
  var stack = [start]
  while let node = stack.popLast() {
    if visited[node] { continue }
    visited[node] = true
    order.append(node)
    // Push in reverse so the first neighbor is visited first
    for neighbor in graph[node].reversed() where !visited[neighbor] {
      stack.append(neighbor)
    }
  }
  return order
}

/// Returns the number of 4-connected groups of "1" cells.
func countIslands(_ grid: [[Character]]) -> Int {
  let rows = grid.count
  let cols = grid.first?.count ?? 0
  var seen = grid.map { $0.map { _ in false } }
  var islands = 0
  for row in 0..<rows {
    for col in 0..<cols where grid[row][col] == "1" && !seen[row][col] {
      islands += 1
      seen[row][col] = true
      var stack = [(row, col)]
      while let (r, c) = stack.popLast() {
        for next in gridNeighbors(
          rows: rows, cols: cols, row: r, col: c)
        where grid[next.row][next.col] == "1"
          && !seen[next.row][next.col]
        {
          seen[next.row][next.col] = true
          stack.append((next.row, next.col))
        }
      }
    }
  }
  return islands
}
