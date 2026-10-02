import Testing

@testable import InterviewExamples

func randomArray(_ count: ClosedRange<Int>, _ values: ClosedRange<Int>)
  -> [Int]
{
  (0..<Int.random(in: count)).map { _ in Int.random(in: values) }
}

@Test func binarySearchAndBounds() {
  for _ in 0..<300 {
    let values = randomArray(0...12, -5...5).sorted()
    for target in -6...6 {
      if let index = binarySearch(values, target) {
        #expect(values[index] == target)
      } else {
        #expect(!values.contains(target))
      }
      let firstAtLeast =
        values.firstIndex { $0 >= target } ?? values.count
      let firstAbove = values.firstIndex { $0 > target } ?? values.count
      #expect(lowerBound(values, target) == firstAtLeast)
      #expect(upperBound(values, target) == firstAbove)
    }
  }
  #expect(firstTrue(0, 100) { $0 * $0 >= 50 } == 8)
  #expect(minEatingSpeed([3, 6, 7, 11], 8) == 4)
  #expect(minEatingSpeed([30, 11, 23, 4, 20], 6) == 23)
}

@Test func twoPointers() {
  #expect(pairWithSum([1, 2, 4, 7, 11], 9)! == (1, 3))
  #expect(pairWithSum([1, 2], 9) == nil)
  for _ in 0..<200 {
    let values = randomArray(0...8, -4...4)
    var expected = Set<[Int]>()
    for i in values.indices {
      for j in values.indices where j > i {
        for k in values.indices
        where k > j && values[i] + values[j] + values[k] == 0 {
          expected.insert([values[i], values[j], values[k]].sorted())
        }
      }
    }
    let actual = threeSum(values)
    #expect(Set(actual) == expected)
    #expect(actual.count == expected.count)
    var sorted = values.sorted()
    let length = removeDuplicates(&sorted)
    #expect(Array(sorted[..<length]) == Array(Set(values)).sorted())
  }
  #expect(isPalindrome("A man, a plan, a canal: Panama"))
  #expect(isPalindrome(""))
  #expect(!isPalindrome("race a car"))
}

func substrings(_ text: String) -> [String] {
  let chars = Array(text)
  var all: [String] = []
  for start in chars.indices {
    for end in start..<chars.count {
      all.append(String(chars[start...end]))
    }
  }
  return all
}

@Test func slidingWindowsAndPrefixSums() {
  for _ in 0..<200 {
    let values = randomArray(1...10, -4...4)
    for size in 1...values.count {
      let expected = (0...(values.count - size)).map {
        values[$0..<($0 + size)].reduce(0, +)
      }.max()!
      #expect(maxWindowSum(values, size: size) == expected)
    }
    for target in -3...3 {
      var expected = 0
      for start in values.indices {
        var total = 0
        for end in start..<values.count {
          total += values[end]
          if total == target { expected += 1 }
        }
      }
      #expect(countSubarraysWithSum(values, target) == expected)
    }
    let text = String(
      (0..<Int.random(in: 0...12)).map { _ in "abcd".randomElement()! })
    let all = substrings(text)
    for k in 0...3 {
      let expected =
        all.filter { Set($0).count <= k }.map(\.count).max() ?? 0
      #expect(longestWithKDistinct(text, k) == expected)
    }
    let unique =
      all.filter { Set($0).count == $0.count }.map(\.count).max() ?? 0
    #expect(longestUniqueSubstring(text) == unique)
  }
  #expect(prefixSums([]) == [0])
}

@Test func stackAndIntervals() {
  for _ in 0..<300 {
    let values = randomArray(0...10, 0...5)
    let expected = values.indices.map { i in
      values[(i + 1)...].first { $0 > values[i] } ?? -1
    }
    #expect(nextGreater(values) == expected)
    let intervals = (0..<Int.random(in: 0...8)).map { _ -> [Int] in
      let start = Int.random(in: 0...10)
      return [start, start + Int.random(in: 1...5)]
    }
    let busiest =
      (0...16).map { moment in
        intervals.count { $0[0] <= moment && moment < $0[1] }
      }.max() ?? 0
    #expect(minMeetingRooms(intervals) == busiest)
    let merged = mergeIntervals(intervals)
    func covered(_ list: [[Int]]) -> Set<Int> {
      Set(list.flatMap { Array($0[0]...$0[1]) })
    }
    #expect(covered(merged) == covered(intervals))
    for i in merged.indices.dropFirst() {
      #expect(merged[i - 1][1] < merged[i][0])
    }
  }
  #expect(mergeIntervals([[1, 4], [4, 5]]) == [[1, 5]])
}

//   0 - 1 - 3
//   |   |
//   2   4 - 5
let sampleGraph = [[1, 2], [0, 3, 4], [0], [1], [1, 5], [4]]

@Test func graphSearch() {
  #expect(bfsOrder(sampleGraph, start: 0) == [0, 1, 2, 3, 4, 5])
  #expect(dfsRecursive(sampleGraph, start: 0) == [0, 1, 3, 4, 5, 2])
  for _ in 0..<200 {
    let graph = (0..<8).map { _ in randomArray(0...3, 0...7) }
    #expect(
      dfsIterative(graph, start: 0) == dfsRecursive(graph, start: 0))
  }
  var grid = [[0, 0, 0], [1, 1, 0], [0, 0, 0]]
  #expect(shortestPathGrid(grid, from: (0, 0), to: (2, 0)) == 6)
  #expect(shortestPathGrid(grid, from: (0, 0), to: (0, 0)) == 0)
  grid[1][2] = 1
  #expect(shortestPathGrid(grid, from: (0, 0), to: (2, 0)) == nil)
  let islands = ["11000", "11000", "00100", "00011"].map(Array.init)
  #expect(countIslands(islands) == 3)
  #expect(countIslands([]) == 0)
  let large = Array(
    repeating: Array(repeating: Character("1"), count: 300), count: 300)
  #expect(countIslands(large) == 1)
}

@Test func topologicalOrderRespectsEdges() {
  for _ in 0..<200 {
    let count = Int.random(in: 1...8)
    let rank = (0..<count).map { _ in Double.random(in: 0...1) }
    var edges: [(Int, Int)] = []
    for a in 0..<count {
      for b in 0..<count where rank[a] < rank[b] && Bool.random() {
        edges.append((a, b))
      }
    }
    let order = topologicalOrder(count: count, edges: edges)!
    #expect(order.sorted() == Array(0..<count))
    let position = Dictionary(
      uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
    for (before, after) in edges {
      #expect(position[before]! < position[after]!)
    }
  }
  #expect(
    topologicalOrder(count: 3, edges: [(0, 1), (1, 2), (2, 0)]) == nil)
  #expect(topologicalOrder(count: 0, edges: []) == [])
}

@Test func dijkstraMatchesBellmanFord() {
  for _ in 0..<300 {
    let count = Int.random(in: 1...8)
    let edges = (0..<Int.random(in: 0...20)).map { _ in
      (
        Int.random(in: 0..<count), Int.random(in: 0..<count),
        Int.random(in: 0...9)
      )
    }
    var expected = [Int?](repeating: nil, count: count)
    expected[0] = 0
    for _ in 0..<count {
      for (from, to, weight) in edges {
        if let known = expected[from],
          known + weight < expected[to] ?? .max
        {
          expected[to] = known + weight
        }
      }
    }
    let graph = buildWeightedGraph(count: count, edges: edges)
    #expect(dijkstra(graph, source: 0) == expected)
  }
}

@Test func backtracking() {
  #expect(subsets([1, 2, 3]).count == 8)
  #expect(Set(subsets([1, 2, 3])).count == 8)
  #expect(subsets([]) == [[]])
  #expect(combinations([1, 2, 3, 4], size: 2).count == 6)
  #expect(Set(combinations([1, 2, 3, 4], size: 2)).count == 6)
  #expect(Set(permutations([1, 2, 3])).count == 6)
  #expect(permutations([]) == [[]])
}

@Test func dynamicProgramming() {
  for (steps, ways) in [1, 1, 2, 3, 5, 8, 13].enumerated() {
    #expect(climbStairs(steps) == ways)
    #expect(climbStairsMemo(steps) == ways)
  }
  for _ in 0..<200 {
    let values = randomArray(0...8, 0...9)
    var robbed = 0
    for mask in 0..<(1 << values.count) where mask & (mask >> 1) == 0 {
      var total = 0
      for index in values.indices where mask >> index & 1 == 1 {
        total += values[index]
      }
      robbed = max(robbed, total)
    }
    #expect(houseRobber(values) == robbed)
    let count = Int.random(in: 0...6)
    let weights = (0..<count).map { _ in Int.random(in: 1...6) }
    let worth = (0..<count).map { _ in Int.random(in: 0...9) }
    let capacity = Int.random(in: 0...12)
    let best = (0..<(1 << count)).compactMap { mask -> Int? in
      let chosen = (0..<count).filter { mask >> $0 & 1 == 1 }
      let weight = chosen.reduce(0) { $0 + weights[$1] }
      return weight <= capacity
        ? chosen.reduce(0) { $0 + worth[$1] } : nil
    }.max()!
    #expect(knapsack(weights, worth, capacity: capacity) == best)
    let sequence = randomArray(0...10, 0...6)
    var lengths = sequence.map { _ in 1 }
    for i in sequence.indices {
      for j in 0..<i where sequence[j] < sequence[i] {
        lengths[i] = max(lengths[i], lengths[j] + 1)
      }
    }
    #expect(
      longestIncreasingSubsequence(sequence) == (lengths.max() ?? 0))
  }
  #expect(coinChange([1, 2, 5], 11) == 3)
  #expect(coinChange([2], 3) == -1)
  #expect(coinChange([1], 0) == 0)
  #expect(uniqueGridPaths(rows: 3, cols: 7) == 28)
  #expect(uniqueGridPaths(rows: 1, cols: 1) == 1)
  #expect(longestCommonSubsequence("abcde", "ace") == 3)
  #expect(longestCommonSubsequence("", "abc") == 0)
}

@Test func sortingSelectionAndBits() {
  for _ in 0..<300 {
    let values = randomArray(0...15, -5...5)
    #expect(mergeSort(values) == values.sorted())
    let ranked = values.sorted(by: >)
    for k in stride(from: 1, through: values.count, by: 1) {
      #expect(kthLargest(values, k) == ranked[k - 1])
    }
    for k in 0...(values.count + 1) {
      #expect(topKLargest(values, k) == Array(ranked.prefix(k)))
    }
  }
  #expect(singleNumber([4, 1, 2, 1, 2]) == 4)
}
