import Foundation

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

/// trimmingCharacters(in:) removes a CharacterSet from BOTH ENDS only
/// and returns a new String (the original is unchanged).
func demoTrimming() {
  let raw = "  Lunch \n"
  assert(raw.trimmingCharacters(in: .whitespaces) == "Lunch \n")
  assert(raw.trimmingCharacters(in: .whitespacesAndNewlines) == "Lunch")
  assert("  a  b ".trimmingCharacters(in: .whitespaces) == "a  b")
  let dashes = CharacterSet(charactersIn: "-")
  assert("--note--".trimmingCharacters(in: dashes) == "note")
  assert("42!?".trimmingCharacters(in: .punctuationCharacters) == "42")
  // The "blank field" check: nothing left after trimming
  assert("   ".trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
  // Whitespace INSIDE the string: trimming can't reach it
  let spaced = "Team   Sync\t"
  // Remove all of it (Character.isWhitespace: space, tab, newline)
  assert(spaced.filter { !$0.isWhitespace } == "TeamSync")
  // Collapse runs to one space (also trims both ends)
  let words = spaced.split(whereSeparator: \.isWhitespace)
  assert(words.joined(separator: " ") == "Team Sync")
}

/// Extensions on YOUR types: group a feature (validation) apart from
/// the stored properties. Methods and computed properties only.
struct Meeting {
  var title: String
  var start: Int  // hour
  var end: Int
}

extension Meeting {
  /// nil means valid; otherwise the reason, ready to show the user.
  var problem: String? {
    if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return "Add a title."
    }
    if end <= start { return "End must be after start." }
    return nil
  }
  var isValid: Bool { problem == nil }
}

func demoValidation() {
  assert(Meeting(title: "Sync", start: 9, end: 10).isValid)
  let blank = Meeting(title: "  ", start: 9, end: 10)
  assert(blank.problem == "Add a title.")
  assert(Meeting(title: "Sync", start: 10, end: 10).problem
    == "End must be after start.")
}

/// static: belongs to the TYPE, not to one value. Call it on the
/// type name (`Workout.minutesLabel(90)`); no instance needed.
struct Workout {
  var name: String
  var minutes: Int

  static let sample = Workout(name: "Run", minutes: 45)  // shared
  static func minutesLabel(_ total: Int) -> String {  // a helper
    total < 60 ? "\(total) min" : "\(total / 60) h \(total % 60) min"
  }
  // Instance code reaches statics through `Self.` (or the type name)
  var label: String { "\(name), \(Self.minutesLabel(minutes))" }
}

func demoStatic() {
  assert(Workout.minutesLabel(90) == "1 h 30 min")  // on the type
  assert(Workout.sample.label == "Run, 45 min")
  // Workout.sample.minutesLabel(5): error, statics aren't on values
  // A free function (top level, outside any type) also works:
  // shorter calls, but it fills the global namespace.
}

/// Lowercase `self` is a VALUE: this instance, or after a type name
/// the type itself as a value. Capital `Self` is a TYPE: the type
/// these lines are written inside.
struct Score {
  var count = 0
  static func zero() -> Self { Self(count: 0) }  // Self == Score
  mutating func add(_ count: Int) {
    self.count += count  // self.count: the property, not the param
  }
}

func demoSelfKinds() {
  var score = Score.zero()
  score.add(2)
  assert(score.count == 2)
  // \.self: the identity key path. Each element IS its own value,
  // which is what ForEach(0..<24, id: \.self) uses as the ID.
  assert([3, 1, 2].map(\.self) == [3, 1, 2])
  // Type.self: the type passed as a value (decoders, adaptors)
  let data = Data("[1, 2]".utf8)
  let numbers = try? JSONDecoder().decode([Int].self, from: data)
  assert(numbers == [1, 2])
  // \.Self doesn't exist: Self is a type, not a property of a value
}

/// Argument labels: the name before the parameter is what the CALLER
/// writes. `_` means "no label". Reading a property is not calling.
final class SongQueue {
  private(set) var songs: [String] = []
  func add(_ song: String) { songs.append(song) }  // add("x")
  func add(song: String) { songs.append(song) }  // add(song: "x")
  func move(from start: Int, to end: Int) {  // inside: start, end
    songs.swapAt(start, end)
  }
}

func demoArgumentLabels() {
  let list = SongQueue()
  list.add("Intro")  // `_` label: nothing before the value
  list.add(song: "Outro")  // label = parameter name
  list.move(from: 0, to: 1)  // caller's words differ from inside
  assert(list.songs == ["Outro", "Intro"])
  // `list.songs` alone only READS (warning: unused); it adds nothing.
  // `list.songs.append("x")` fails: private(set). Call the method.
  let save: (String) -> Void = { song in list.add(song) }
  save("Bonus")  // closure types have no labels when called
  assert(list.songs.count == 3)
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

struct Song {
  let id = UUID()  // a let with a value is left out of the init
  var title: String
  var minutes: Int
}

/// Three ways to give a property its starting value.
final class Playlist {
  // 1. A default right on the property: any expression works,
  //    including an array literal of structs. No init needed.
  var songs: [Song] = [
    Song(title: "Intro", minutes: 2),
    Song(title: "Outro", minutes: 3),
  ]
  var name: String

  // 2. An init parameter with a default: callers may skip it.
  //    The default's type must match: [Song], so wrap it in [ ].
  init(name: String = "Mix", songs: [Song]? = nil) {
    self.name = name
    if let songs { self.songs = songs }  // 3. set it in the init
  }
}

func demoStartingValues() {
  assert(Playlist().songs.count == 2)  // the property's default
  assert(Playlist(name: "Run").name == "Run")
  let one = Playlist(songs: [Song(title: "Solo", minutes: 4)])
  assert(one.songs.map(\.title) == ["Solo"])
  // Memberwise init (structs only): every var, in order
  assert(Song(title: "Hi", minutes: 1).minutes == 1)
}

/// willSet runs just before a change (the incoming value is
/// `newValue`); didSet runs just after (the old one is `oldValue`).
struct Thermostat {
  private(set) var log: [String] = []
  var target: Int {
    willSet { log.append("will \(target)->\(newValue)") }
    didSet {
      // Setting it here doesn't call the observers again
      if target > 30 { target = 30 }
      log.append("did \(oldValue)->\(target)")
    }
  }

  init(target: Int) {
    self.target = target  // observers don't run inside init
  }
}

func demoPropertyObservers() {
  var room = Thermostat(target: 20)
  assert(room.log.isEmpty)
  room.target = 25
  assert(room.log == ["will 20->25", "did 20->25"])
  room.target = 40  // clamped in didSet
  assert(room.target == 30)
  assert(room.log.last == "did 25->30")
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

/// Identifiable says which record this is; Equatable says whether
/// two values match right now. All stored properties are Equatable,
/// so Swift writes == for free.
struct Note: Identifiable, Equatable, Hashable {
  let id: Int
  var text: String
}

func demoEquatable() {
  let saved = Note(id: 1, text: "Milk")
  var draft = saved
  assert(draft == saved)  // every property matches
  draft.text = "Oat milk"
  assert(draft.id == saved.id)  // same record...
  assert(draft != saved)  // ...but its values changed
  // Arrays of Equatable values compare element by element, in order
  assert([saved, draft] != [draft, saved])
  // Hashable (which includes Equatable) allows Set and Dictionary
  let unique: Set<Note> = [saved, saved, draft]
  assert(unique.count == 2)
}

/// Callers may ignore the returned value without a warning.
final class Clicker {
  private(set) var count = 0

  @discardableResult
  func click() -> Int {
    count += 1
    return count
  }
}

func demoDiscardableResult() {
  let clicker = Clicker()
  clicker.click()  // no "result unused" warning
  let latest = clicker.click()
  assert(latest == 2 && clicker.count == 2)
  // Without the attribute you'd write: _ = clicker.click()
}

/// Two ways to let callers read stored data but never change it.
struct Shelf {
  // 1. private(set): callers read the array exactly as stored
  private(set) var titles: [String] = []
  // 2. private storage + computed property: callers get a new value
  //    built on every read, so the stored shape can stay hidden
  private var pages: [String: Int] = [:]
  var totalPages: Int { pages.values.reduce(0, +) }

  mutating func add(_ title: String, pages count: Int) {
    titles.append(title)
    pages[title] = count
  }
}

func demoReadOnlyViews() {
  var shelf = Shelf()
  shelf.add("Dune", pages: 412)
  shelf.add("Emma", pages: 474)
  assert(shelf.titles == ["Dune", "Emma"])
  assert(shelf.totalPages == 886)
  // shelf.titles = []    // error: setter is private
  // shelf.pages          // error: 'pages' is inaccessible
}
