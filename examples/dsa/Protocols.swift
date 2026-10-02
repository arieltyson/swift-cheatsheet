protocol Describable {
  var title: String { get }
  func summary() -> String
}

extension Describable {
  // Default implementation: conforming types get it for free
  func summary() -> String { "Item: \(title)" }
  // Not a requirement: always this version, even if a type redefines it
  func badge() -> String { "default badge" }
}

struct Book: Describable {
  let title: String
}

struct Movie: Describable {
  let title: String
  let minutes: Int

  func summary() -> String { "\(title) (\(minutes) min)" }
  func badge() -> String { "movie badge" }
}

func demoProtocols() {
  let items: [any Describable] = [
    Book(title: "Dune"), Movie(title: "Up", minutes: 96),
  ]
  assert(items.map { $0.summary() } == ["Item: Dune", "Up (96 min)"])
  // Requirements dispatch dynamically; extension-only methods do not
  assert(items[1].badge() == "default badge")
  assert(Movie(title: "Up", minutes: 96).badge() == "movie badge")
}

extension Int {
  var isEven: Bool { self % 2 == 0 }
}

extension Array where Element == Int {
  var total: Int { reduce(0, +) }
}

func demoExtensions() {
  assert(4.isEven)
  assert([1, 2, 3].total == 6)
}

/// Generic with a where clause: any sequence of hashable values.
func mostCommon<Values: Sequence>(_ values: Values) -> Values.Element?
where Values.Element: Hashable {
  var counts: [Values.Element: Int] = [:]
  for value in values {
    counts[value, default: 0] += 1
  }
  return counts.max { $0.value < $1.value }?.key
}

protocol Store {
  // Each conforming type picks its own Item type
  associatedtype Item
  var all: [Item] { get }
  mutating func add(_ item: Item)
}

struct MemoryStore<Item>: Store {
  private(set) var all: [Item] = []

  mutating func add(_ item: Item) { all.append(item) }
}

func addAll<S: Store>(_ items: [S.Item], to store: inout S) {
  for item in items {
    store.add(item)
  }
}

/// some: one hidden concrete type, chosen by this function.
func makeStore() -> some Store {
  MemoryStore<String>()
}

func demoGenerics() {
  assert(mostCommon([3, 1, 3, 2]) == 3)
  assert(mostCommon("hello") == "l")
  var store = MemoryStore<String>()
  addAll(["a", "b"], to: &store)
  assert(store.all == ["a", "b"])
  // any: a box that can hold different types at run time
  let stores: [any Store] = [MemoryStore<Int>(), makeStore()]
  assert(stores.count == 2)
}
