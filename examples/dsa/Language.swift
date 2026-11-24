func demoOptionals() {
  let parsed = Int("42")
  assert(parsed == 42)
  assert(Int("4x") == nil)
  assert((Int("4x") ?? 0) == 0)
  if let parsed {
    assert(parsed + 1 == 43)
  }
  let ages = ["ada": 36]
  assert(ages["bo"] == nil)
  assert(ages["bo", default: 0] == 0)

  // popLast() returns Int?, so unwrap it before using the value.
  // guard continues when its condition is TRUE, and exits otherwise.
  // Conditions run left to right: check first, then pop (it removes).
  var stack = [1, 2]
  guard !stack.isEmpty, let top = stack.popLast() else { return }
  assert(top == 2 && stack == [1])
}

/// Returns the first even value, or nil.
func firstEven(_ values: [Int]) -> Int? {
  guard let even = values.first(where: { $0 % 2 == 0 }) else {
    return nil
  }
  return even
}

func demoValueSemantics() {
  struct Point { var x = 0 }
  final class Counter { var count = 0 }
  var original = Point()
  var copy = original
  copy.x = 9
  assert(original.x == 0)
  original.x = 1
  let counter = Counter()
  let alias = counter
  alias.count = 9
  assert(counter.count == 9)
  // Arrays are values too, copied lazily on write
  let numbers = [1, 2]
  var changed = numbers
  changed.append(3)
  assert(numbers == [1, 2])
}

func demoClosures() {
  let values = [3, 1, 2]
  assert(values.sorted(by: >) == [3, 2, 1])
  assert(values.map { $0 * 2 } == [6, 2, 4])
  let isLarge: (Int) -> Bool = { value in value > 2 }
  assert(values.filter(isLarge) == [3])
  let total = values.reduce(0) { sum, value in sum + value }
  assert(total == 6)

  // One expression: its value is returned. More than one statement:
  // write `return`, or the closure returns nothing.
  let doubledOdds = values.map { value in
    let isOdd = value % 2 == 1
    return isOdd ? value * 2 : value
  }
  assert(doubledOdds == [6, 2, 2])
  // Names declared inside a closure don't exist outside it.
}

/// Tuples destructure; arrays don't. Use a tuple for a pair.
func demoTuples() {
  let cell = (row: 1, col: 2)
  let (row, col) = cell
  assert(row == 1 && col == 2 && cell.col == 2)
  let pair = [1, 2]
  let (first, second) = (pair[0], pair[1])
  assert(first + second == 3)
}

/// Associated values: `Equatable` must be declared (then `==` is
/// synthesized, since every value is Equatable).
enum Shape: Equatable {
  case point
  case circle(radius: Double)
  case square(side: Double)

  var area: Double {
    switch self {
    case .point: 0
    case .circle(let radius): Double.pi * radius * radius
    case let .square(side): side * side
    }
  }
}

/// Raw values: one fixed value per case, declared after the type.
/// Without `: String` (or Int), `case on = "On"` doesn't compile.
enum Switch: String, CaseIterable {
  case on = "On"
  case off  // defaults to "off", the case name
}

func demoEnums() {
  assert(Shape.square(side: 3).area == 9)
  let shapes: [Shape] = [.point, .circle(radius: 1), .square(side: 2)]
  assert(shapes.count == 3)

  // Check one case and pull its value out.
  var radius = 0.0
  if case .circle(let r) = shapes[1] { radius = r }
  assert(radius == 1)

  // == compares the case and its values.
  assert(shapes[0] == .point && shapes[2] != .square(side: 3))

  assert(Switch.on.rawValue == "On" && Switch.off.rawValue == "off")
  assert(Switch(rawValue: "On") == .on)  // failable: String -> case?
  assert(Switch(rawValue: "nope") == nil)
  assert(Switch.allCases == [.on, .off])  // from CaseIterable
}

/// No keyword (internal): visible to the whole module, views too.
/// private: only inside this type. private(set): anyone can read,
/// only this type can change it.
struct Tally {
  private(set) var count = 0
  private var log: [Int] = []
  // A yes/no question with no side effects: a computed property, not
  // a func. Name it for when it's TRUE; negate at the call site.
  var hasEntries: Bool { !log.isEmpty }

  mutating func add() {
    count += 1
    log.append(count)
  }
}

func demoAccessControl() {
  var tally = Tally()
  assert(!tally.hasEntries)
  tally.add()
  assert(tally.count == 1 && tally.hasEntries)
  // tally.count = 5  // error: the setter is private
  // tally.log        // error: 'log' is inaccessible
}

/// Sorts by priority, then by name, so it works with sorted() and Heap.
struct Job: Comparable, Hashable {
  let priority: Int
  let name: String

  static func < (lhs: Job, rhs: Job) -> Bool {
    (lhs.priority, lhs.name) < (rhs.priority, rhs.name)
  }
}

func demoComparable() {
  let jobs = [
    Job(priority: 2, name: "write"), Job(priority: 1, name: "plan"),
  ]
  assert(jobs.min()?.name == "plan")
  assert(jobs.sorted().map(\.name) == ["plan", "write"])
}
