import Testing
@testable import InterviewExamples

@Test func binarySearchBoundaries() {
    for size in 0...40 {
        let values = (0..<size).map { $0 / 3 }
        for target in -2...18 {
            #expect(lowerBound(values, target: target) == (values.firstIndex { $0 >= target } ?? size))
            #expect(binarySearch(values, target: target) == values.firstIndex(of: target))
        }
    }
    #expect(binarySearch([Int.min, 0, Int.max], target: Int.max) == 2)
}

@Test func windowsPointersAndPrefixes() {
    let pair = twoSumSorted([-4, -1, 2, 5], target: 1)
    #expect(pair?.0 == 0 && pair?.1 == 3)
    #expect(twoSumSorted([], target: 1) == nil)
    #expect(twoSumSorted([1], target: 2) == nil)
    #expect(twoSumSorted([Int.min, Int.min + 1, -1], target: Int.min)?.0 == 1)
    #expect(twoSumSorted([1, 2, Int.max], target: 3)?.1 == 1)
    #expect(twoSumSorted([Int.min, Int.max], target: -1)?.1 == 1)
    #expect(longestUniqueSubstring("abcabcbb") == 3)
    #expect(longestUniqueSubstring("") == 0)
    #expect(longestUniqueSubstring("é👨‍👩‍👧‍👦é") == 2)
    #expect(longestUniqueSubstring("abba") == 2)
    let prefix = PrefixSums([2, -1, 4, 3])
    #expect(prefix.sum(in: 1..<3) == 3)
    #expect(prefix.sum(in: 0..<0) == 0)
    #expect(prefix.sum(in: 0..<4) == 8)
    #expect(PrefixSums([]).sum(in: 0..<0) == 0)
}

@Test func traversalHandlesCyclesAndDisconnectedVertices() {
    let graph = [[1, 2], [0, 2], [0, 1], []]
    #expect(breadthFirstDistances(graph, start: 0) == [0, 1, 1, nil])
    #expect(depthFirstOrder(graph, start: 0) == [0, 1, 2])
    #expect(breadthFirstDistances([[]], start: 0) == [0])
}

@Test func shortestPathsAndInvalidInputs() throws {
    let graph: [[WeightedEdge]] = [
        [.init(destination: 1, weight: 10), .init(destination: 2, weight: 1)],
        [.init(destination: 3, weight: 2)],
        [.init(destination: 1, weight: 1), .init(destination: 3, weight: 9)],
        [], []
    ]
    #expect(try dijkstra(graph, start: 0) == [0, 2, 1, 4, nil])
    #expect(try dijkstra([[.init(destination: 0, weight: 0)]], start: 0) == [0])
    #expect(try dijkstra([[.init(destination: 1, weight: Int.max)], []], start: 0) == [0, Int.max])
    #expect(throws: PathError.invalidVertex) { try dijkstra([], start: 0) }
    #expect(throws: PathError.invalidVertex) { try dijkstra([[.init(destination: 1, weight: 2)]], start: 0) }
    #expect(throws: PathError.negativeWeight) { try dijkstra([[.init(destination: 0, weight: -1)]], start: 0) }
    #expect(throws: PathError.distanceOverflow) {
        try dijkstra([[.init(destination: 1, weight: Int.max)], [.init(destination: 2, weight: 1)], []], start: 0)
    }
}

@Test func shortestPathsMatchRelaxationReference() throws {
    for seed in 0..<25 {
        let count = 6
        var graph = Array(repeating: [WeightedEdge](), count: count)
        for source in 0..<count {
            for destination in 0..<count where (source * 17 + destination * 13 + seed) % 4 == 0 {
                graph[source].append(.init(destination: destination, weight: (source + destination + seed) % 7))
            }
        }
        var expected = Array<Int?>(repeating: nil, count: count)
        expected[0] = 0
        for _ in 0..<count {
            for source in 0..<count {
                guard let distance = expected[source] else { continue }
                for edge in graph[source] {
                    expected[edge.destination] = min(expected[edge.destination] ?? Int.max, distance + edge.weight)
                }
            }
        }
        #expect(try dijkstra(graph, start: 0) == expected)
    }
}

@Test func intervalsBacktrackingAndDP() {
    #expect(mergeIntervals([1...3, 2...6, 8...10, 10...12]) == [1...6, 8...12])
    #expect(mergeIntervals([]).isEmpty)
    #expect(mergeIntervals([Int.min...Int.max]) == [Int.min...Int.max])
    #expect(subsets([1, 2]) == [[], [2], [1], [1, 2]])
    #expect(subsets([Int]()) == [[]])
    #expect(minimumCoins([1, 2, 5], amount: 11) == 3)
    #expect(minimumCoins([2], amount: 3) == nil)
    #expect(minimumCoins([], amount: 0) == 0)
    #expect(minimumCoins([], amount: 5) == nil)
    #expect(minimumCoins([Int.max], amount: 1) == nil)
}
