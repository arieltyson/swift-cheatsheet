func breadthFirstDistances(_ graph: [[Int]], start: Int) -> [Int?] {
    precondition(graph.indices.contains(start))
    var distances = Array<Int?>(repeating: nil, count: graph.count)
    var queue = [start]
    var head = 0
    distances[start] = 0
    while head < queue.count {
        let vertex = queue[head]
        head += 1
        guard let distance = distances[vertex] else { continue }
        for neighbor in graph[vertex] where distances[neighbor] == nil {
            distances[neighbor] = distance + 1
            queue.append(neighbor)
        }
    }
    return distances
}

func depthFirstOrder(_ graph: [[Int]], start: Int) -> [Int] {
    precondition(graph.indices.contains(start))
    var visited = Array(repeating: false, count: graph.count)
    var order: [Int] = []
    func visit(_ vertex: Int) {
        visited[vertex] = true
        order.append(vertex)
        for neighbor in graph[vertex] where !visited[neighbor] {
            visit(neighbor)
        }
    }
    visit(start)
    return order
}
