func demoCreateArrays() {
  assert(Array(repeating: 0, count: 3) == [0, 0, 0])
  assert(Array(0..<4) == [0, 1, 2, 3])
  assert((0..<4).map { $0 * $0 } == [0, 1, 4, 9])
  var grid = Array(repeating: Array(repeating: 0, count: 3), count: 2)
  grid[0][1] = 7
  // Rows are values, so changing one never changes another
  assert(grid == [[0, 7, 0], [0, 0, 0]])
  assert((grid.count, grid[0].count) == (2, 3))
}

func demoArrayOperations() {
  var items = [3, 1]
  items.append(4)
  items.append(contentsOf: [5, 9])
  assert(items.removeLast() == 9)
  assert(items.removeFirst() == 3)
  items.insert(2, at: 0)
  assert(items == [2, 1, 4, 5])
  assert(items.popLast() == 5)
  assert(items.last == 4)
  assert(items.first == 2)
  items.remove(at: 1)
  assert(items == [2, 4])
  items.swapAt(0, 1)
  assert(items == [4, 2])
  assert(items.isEmpty == false)
}

func demoSorting() {
  var values = [10, 9, 1]
  assert(values.sorted() == [1, 9, 10])
  assert(values.sorted(by: >) == [10, 9, 1])
  values.sort()
  assert(values == [1, 9, 10])
  assert(values.reversed() == [10, 9, 1])
  let words = ["pear", "Fig", "apple"]
  assert(words.sorted() == ["Fig", "apple", "pear"])
  let caseless = words.sorted { $0.lowercased() < $1.lowercased() }
  assert(caseless == ["apple", "Fig", "pear"])
}

func demoSortKeys() {
  let people = [("bo", 85), ("ada", 90), ("cy", 85)]
  // Score descending, then name ascending
  let ranked = people.sorted { a, b in
    a.1 != b.1 ? a.1 > b.1 : a.0 < b.0
  }
  assert(ranked.map(\.0) == ["ada", "bo", "cy"])
  let intervals = [[5, 6], [1, 3], [2, 4]]
  let byStart = intervals.sorted { $0[0] < $1[0] }
  assert(byStart == [[1, 3], [2, 4], [5, 6]])
}

func demoTransforms() {
  let values = [3, -1, 4]
  assert(values.map { $0 * 2 } == [6, -2, 8])
  assert(values.filter { $0 > 0 } == [3, 4])
  assert(values.reduce(0, +) == 6)
  assert(["7", "x", "9"].compactMap { Int($0) } == [7, 9])
  assert([[1, 2], [3]].flatMap { $0 } == [1, 2, 3])
  let squares = values.reduce(into: [Int]()) { result, value in
    result.append(value * value)
  }
  assert(squares == [9, 1, 16])
}

func demoSearchArrays() {
  let values = [3, -1, 4, -1]
  assert(values.contains(4))
  assert(values.first(where: { $0 > 3 }) == 4)
  assert(values.firstIndex(of: -1) == 1)
  assert(values.lastIndex(of: -1) == 3)
  assert(values.allSatisfy { $0 != 0 })
  assert(values.min() == -1)
  assert(values.max() == 4)
  assert(values.count(where: { $0 < 0 }) == 2)
}

func demoIteration() {
  let names = ["ada", "bo"]
  for (index, name) in names.enumerated() {
    assert(names[index] == name)
  }
  let pairs = Array(zip(names, [90, 85]))
  assert(pairs.map(\.1) == [90, 85])
  assert(Array(stride(from: 0, to: 6, by: 2)) == [0, 2, 4])
  assert(Array(stride(from: 3, through: 0, by: -1)) == [3, 2, 1, 0])
  assert(Array(names.indices) == [0, 1])
  assert(Array((0..<3).reversed()) == [2, 1, 0])
}

func demoSlices() {
  let values = [10, 20, 30, 40]
  let middle = values[1...2]
  // A slice keeps the original indices
  assert(middle.startIndex == 1)
  assert(middle.first == 20)
  assert(Array(middle) == [20, 30])
  assert(Array(values.prefix(2)) == [10, 20])
  assert(Array(values.suffix(1)) == [40])
  assert(Array(values.dropFirst()) == [20, 30, 40])
}
