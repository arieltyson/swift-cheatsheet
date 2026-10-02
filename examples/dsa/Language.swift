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
  var total = 0
  values.forEach { total += $0 }
  assert(total == 6)
}

enum Shape {
  case circle(radius: Double)
  case square(side: Double)

  var area: Double {
    switch self {
    case .circle(let radius): Double.pi * radius * radius
    case .square(let side): side * side
    }
  }
}

func demoEnums() {
  assert(Shape.square(side: 3).area == 9)
  let shapes: [Shape] = [.circle(radius: 1), .square(side: 2)]
  assert(shapes.count == 2)
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
