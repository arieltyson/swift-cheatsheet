func demoDictionary() {
  var ages = ["ada": 36]
  ages["bo"] = 25
  assert(ages["ada"] == 36)
  assert(ages["cy"] == nil)
  assert(ages["cy", default: 0] == 0)
  ages["cy", default: 0] += 1
  assert(ages["cy"] == 1)
  assert(ages.removeValue(forKey: "bo") == 25)
  assert(ages.keys.contains("ada"))
  assert(ages.count == 2)
  // Dictionary order is not stable: sort keys before showing them
  assert(ages.keys.sorted() == ["ada", "cy"])
  for (name, age) in ages where name == "ada" {
    assert(age == 36)
  }
}

func demoCounting() {
  var counts: [Character: Int] = [:]
  for char in "banana" {
    counts[char, default: 0] += 1
  }
  assert(counts["a"] == 3)
  assert(counts["z", default: 0] == 0)
  let byCount = counts.sorted { $0.value > $1.value }
  assert(byCount.first?.key == "a")
  let words = ["eat", "tea", "tan"]
  let tally = Dictionary(
    words.map { ($0.count, 1) }, uniquingKeysWith: +)
  assert(tally[3] == 3)
}

func demoGrouping() {
  let words = ["eat", "tea", "tan"]
  let groups = Dictionary(grouping: words) { String($0.sorted()) }
  assert(groups["aet"] == ["eat", "tea"])
  assert(groups["ant"] == ["tan"])
  var buckets: [Int: [String]] = [:]
  for word in words {
    buckets[word.count, default: []].append(word)
  }
  assert(buckets[3]?.count == 3)
}

func demoSet() {
  var seen: Set = [1, 2]
  assert(seen.insert(3).inserted == true)
  assert(seen.insert(1).inserted == false)
  assert(seen.contains(2))
  seen.remove(2)
  let first: Set = [1, 2, 3]
  let second: Set = [2, 3, 4]
  assert(first.union(second) == [1, 2, 3, 4])
  assert(first.intersection(second) == [2, 3])
  assert(first.subtracting(second) == [1])
  assert(first.symmetricDifference(second) == [1, 4])
  assert(first.isSuperset(of: [1, 2]))
  assert(Set([3, 1, 3]).sorted() == [1, 3])
}

struct GridPoint: Hashable {
  let row: Int
  let col: Int
}

func demoHashableKeys() {
  var visited: Set<GridPoint> = [GridPoint(row: 0, col: 0)]
  visited.insert(GridPoint(row: 0, col: 1))
  assert(visited.contains(GridPoint(row: 0, col: 1)))
  let distance = [GridPoint(row: 0, col: 0): 0]
  assert(distance[GridPoint(row: 0, col: 0)] == 0)
  // Tuples are not Hashable; arrays are, but cost O(n) to hash
  let seenPairs: Set<[Int]> = [[0, 1]]
  assert(seenPairs.contains([0, 1]))
}
