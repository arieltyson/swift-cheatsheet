func demoCreateArrays() {
  assert(Array(repeating: 0, count: 3) == [0, 0, 0])
  assert(Array(0..<4) == [0, 1, 2, 3])
  assert((0..<4).map { $0 * $0 } == [0, 1, 4, 9])
  var grid = Array(repeating: Array(repeating: 0, count: 3), count: 2)
  grid[0][1] = 7
  // Rows are values, so changing one never changes another
  assert(grid == [[0, 7, 0], [0, 0, 0]])
  assert((grid.count, grid[0].count) == (2, 3))

  // Checking every cell: the outer closure gets a ROW, not a cell
  let cells: [[Int?]] = [[1, nil], [3, 4]]
  assert(!cells.allSatisfy { row in row.allSatisfy { $0 != nil } })
  assert(cells.contains { row in row.contains(nil) })
  assert(cells.joined().filter { $0 == nil }.count == 1)
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
  // reversed() can return a lazy view, so wrap it to get an array
  let backwards = Array(items.reversed())
  assert(backwards == [2, 4])
  items.reverse()
  assert(items == [2, 4])
  assert(items.isEmpty == false)
}

func demoRemoveByValue() {
  // Remove by VALUE: find the index first, or let removeAll search
  var tags = ["a", "b", "c", "b"]
  if let index = tags.firstIndex(of: "b") { tags.remove(at: index) }
  assert(tags == ["a", "c", "b"])  // first match only
  tags.removeAll { $0 == "b" }  // every match, one O(n) pass
  assert(tags == ["a", "c"])
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

/// Python comprehensions in Swift. Read `xs.map { x in f(x) }` as
/// `[f(x) for x in xs]`; the closure's value is the new element.
func demoComprehensions() {
  let n = 4
  // [i * i for i in range(n)]
  assert((0..<n).map { i in i * i } == [0, 1, 4, 9])
  // [i for i in range(n) if i % 2 == 0]
  assert((0..<n).filter { $0 % 2 == 0 } == [0, 2])
  // [i * 10 for i in range(n) if i > 1]: filter first, then map
  assert((0..<n).filter { $0 > 1 }.map { $0 * 10 } == [20, 30])
  // ["even" if i % 2 == 0 else "odd" for i in range(3)]
  let labels = (0..<3).map { $0 % 2 == 0 ? "even" : "odd" }
  assert(labels == ["even", "odd", "even"])
  // [[i, i] for i in range(3)]: each element is itself an array
  assert((0..<3).map { i in [i, i] } == [[0, 0], [1, 1], [2, 2]])
  // [[0] * 3 for _ in range(2)]: `_` when the index isn't used
  assert((0..<2).map { _ in [0, 0, 0] } == [[0, 0, 0], [0, 0, 0]])
  // [(r, c) for r in range(2) for c in range(2)]: nested loops
  let cells = (0..<2).flatMap { r in (0..<2).map { c in [r, c] } }
  assert(cells == [[0, 0], [0, 1], [1, 0], [1, 1]])
  // [x for row in grid for x in row]: flatten
  assert([[1, 2], [3]].flatMap { $0 } == [1, 2, 3])
}

/// Dict and set comprehensions, enumerate, and all/any/sum.
func demoComprehensionsMore() {
  let n = 4
  // {w: len(w) for w in words}
  let words = ["hi", "hey"]
  let lengths = Dictionary(uniqueKeysWithValues: words.map {
    ($0, $0.count)
  })
  assert(lengths == ["hi": 2, "hey": 3])
  // {len(w) for w in words}
  assert(Set(words.map(\.count)) == [2, 3])
  // [f"{i}:{w}" for i, w in enumerate(words)]
  let numbered = words.enumerated().map { i, w in "\(i):\(w)" }
  assert(numbered == ["0:hi", "1:hey"])
  // all(...), any(...), sum(...) take a generator in Python
  assert((0..<n).allSatisfy { $0 < n })
  assert((0..<n).contains { $0 == 3 })
  assert((0..<n).reduce(0, +) == 6)
}

struct Reservation: Identifiable {
  let id: Int  // in an app: UUID(), needs Foundation
  var name: String
}

/// "Is it already there?" Match by id for structs; a Set for speed.
func demoExistence() {
  let saved = Reservation(id: 1, name: "Dentist")
  let bookings = [saved, Reservation(id: 2, name: "Gym")]
  let fresh = Reservation(id: 3, name: "Dentist")  // new id
  // contains(where:) for structs that aren't Equatable
  assert(bookings.contains { $0.id == saved.id })
  assert(!bookings.contains { $0.id == fresh.id })  // so it's new
  let isNew = !bookings.contains { $0.id == fresh.id }
  assert(isNew)
  // contains(_:) needs Equatable elements
  assert(["a", "b"].contains("b"))
  // Many lookups: build a Set once, then each check is O(1)
  let ids = Set(bookings.map(\.id))
  assert(ids.contains(saved.id))
}

func demoSearchArrays() {
  let values = [3, -1, 4, -1]
  assert(values.contains(4))
  assert(values.first(where: { $0 > 3 }) == 4)
  assert(values.firstIndex(of: -1) == 1)
  assert(values.lastIndex(of: -1) == 3)
  // allSatisfy: does EVERY element pass? Stops at the first failure.
  assert(values.allSatisfy { $0 != 0 })
  assert(!values.allSatisfy { $0 > 0 })
  assert([Int]().allSatisfy { $0 > 100 })  // empty: always true
  assert((1...4).allSatisfy { 12 % $0 == 0 })  // ranges work too
  // "all pass" is the same as "none fail"
  assert(values.allSatisfy { $0 != 0 } == !values.contains { $0 == 0 })
  assert(values.min() == -1)
  assert(values.max() == 4)
  assert(values.count(where: { $0 < 0 }) == 2)
}

func demoIteration() {
  let names = ["ada", "bo"]
  // enumerated() pairs each element with its position
  let numbered = names.enumerated().map {
    "\($0.offset): \($0.element)"
  }
  assert(numbered == ["0: ada", "1: bo"])
  assert(Array(names.indices) == [0, 1])
  assert(Array(stride(from: 0, to: 6, by: 2)) == [0, 2, 4])
  assert(Array(stride(from: 3, through: 0, by: -1)) == [3, 2, 1, 0])
  assert(Array((0..<3).reversed()) == [2, 1, 0])
}

func demoZip() {
  let names = ["ada", "bo"]
  let scores = [90, 85, 70]
  // zip walks two sequences side by side, one pair per step:
  // ("ada", 90), then ("bo", 85). It stops at the SHORTER one,
  // so 70 has no partner and is left out.
  var lines: [String] = []
  for (name, score) in zip(names, scores) {
    lines.append("\(name) scored \(score)")
  }
  assert(lines == ["ada scored 90", "bo scored 85"])
  // Each pair is a tuple: .0 from the first sequence, .1 the second
  let firstPair = Array(zip(names, scores))[0]
  assert(firstPair.0 == "ada")
  assert(firstPair.1 == 90)
  // Pairs straight into a dictionary
  let byName = Dictionary(uniqueKeysWithValues: zip(names, scores))
  assert(byName == ["ada": 90, "bo": 85])
  // Neighbours: zip an array with itself shifted by one
  let gaps = zip(scores, scores.dropFirst()).map { $0 - $1 }
  assert(gaps == [5, 15])
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

/// A small record for the reduce and key path examples.
struct Purchase {
  let item: String
  let cents: Int
  var isReturned = false
}

func demoReduce() {
  let cart = [Purchase(item: "Tea", cents: 300),
              Purchase(item: "Jam", cents: 450)]
  // reduce(start, combine): combine runs once per element and gets
  // (the running result so far, the next element), then returns the
  // new running result. Xcode's placeholder names them
  // partialResult and the element type; name them yourself.
  let longhand = cart.reduce(0) { partialResult, purchase in
    partialResult + purchase.cents
  }
  // Same thing: $0 is the running result, $1 the next element
  let shorthand = cart.reduce(0) { $0 + $1.cents }
  // Or map to the numbers first, then pass the + operator itself
  let operatorForm = cart.map(\.cents).reduce(0, +)
  assert(longhand == 750 && shorthand == 750 && operatorForm == 750)
  // Steps: 0 + 300 = 300, then 300 + 450 = 750
  assert([Purchase]().reduce(0) { $0 + $1.cents } == 0)  // empty
}

func demoKeyPathMap() {
  let cart = [Purchase(item: "Tea", cents: 300),
              Purchase(item: "Jam", cents: 450, isReturned: true)]
  // map builds a NEW array: one output per element, in the same
  // order. These three all mean "give me each purchase's item".
  assert(cart.map { purchase in purchase.item } == ["Tea", "Jam"])
  assert(cart.map { $0.item } == ["Tea", "Jam"])
  assert(cart.map(\.item) == ["Tea", "Jam"])
  // \.item is a key path: a name for the item property. Swift
  // accepts it wherever the closure { $0.item } would go.
  assert(cart.map(\.cents) == [300, 450])
  // A Bool property works with filter and contains(where:)
  assert(cart.filter(\.isReturned).map(\.item) == ["Jam"])
  assert(cart.contains(where: \.isReturned))
  // Paths chain: the character count of each item
  assert(cart.map(\.item.count) == [3, 3])
  // Store a key path, then read one value through it
  let price = \Purchase.cents
  assert(cart[0][keyPath: price] == 300)
}

func demoSortedInsert() {
  var scores = [90, 70, 50]  // kept high to low
  // firstIndex(of:) finds an exact value (elements must be Equatable)
  assert(scores.firstIndex(of: 70) == 1)
  assert(scores.firstIndex(of: 60) == nil)
  // firstIndex(where:) finds the first element passing a test
  assert(scores.firstIndex { $0 <= 60 } == 2)
  assert(scores.firstIndex { $0 <= 10 } == nil)
  // insert(_:at:) puts the value AT that index and shifts the rest
  // right. Valid indexes are 0...endIndex; endIndex (== count) is
  // one past the last element, so inserting there appends.
  scores.insert(
    60, at: scores.firstIndex { $0 <= 60 } ?? scores.endIndex)
  assert(scores == [90, 70, 60, 50])
  scores.insert(
    10, at: scores.firstIndex { $0 <= 10 } ?? scores.endIndex)
  assert(scores == [90, 70, 60, 50, 10])
  // <= puts a new tie BEFORE old equals (newest first); < after
  scores.insert(
    70, at: scores.firstIndex { $0 <= 70 } ?? scores.endIndex)
  assert(scores.firstIndex(of: 70) == 1)
}

func demoUpdateInPlace() {
  struct Song {
    let id: Int
    var title: String
  }
  var songs = [Song(id: 1, title: "Hey"), Song(id: 2, title: "Yo")]
  // Find the position by id, then write through the subscript.
  // The element keeps its index, so the order doesn't change.
  if let index = songs.firstIndex(where: { $0.id == 2 }) {
    songs[index].title = "Yo!"  // change one var property
  }
  assert(songs.map(\.title) == ["Hey", "Yo!"])
  // Or replace the whole element (needed when fields are let)
  if let index = songs.firstIndex(where: { $0.id == 1 }) {
    songs[index] = Song(id: 1, title: "Hello")
  }
  assert(songs.map(\.title) == ["Hello", "Yo!"])
  assert(songs.count == 2)  // updated, not duplicated
  // An unknown id finds nothing, so nothing changes
  assert(songs.firstIndex(where: { $0.id == 9 }) == nil)
}
