import Testing

/// A suite groups related tests. Swift Testing makes a NEW instance
/// for every test, so each one starts with an empty pantry.
@Suite("Pantry")
struct PantryTests {
  let pantry = Pantry()

  @Test("An empty pantry has nothing in it")
  func startsEmpty() {
    #expect(pantry.names.isEmpty)
    #expect(pantry.count(of: "rice") == 0)
  }

  @Test func addingTheSameItemAddsUp() throws {
    try pantry.add("rice", count: 2)
    try pantry.add("rice", count: 3)
    #expect(pantry.count(of: "rice") == 5)
  }

  @Test func namesComeBackAToZ() throws {
    try pantry.add("tea", count: 1)
    try pantry.add("oats", count: 1)
    #expect(pantry.names == ["oats", "tea"])
    // #require stops the test here if the value is nil
    let first = try #require(pantry.names.first)
    #expect(first == "oats")
  }

  /// One test, run once per argument.
  @Test(arguments: [0, -1, -50])
  func rejectsCountsBelowOne(count: Int) {
    #expect(throws: PantryError.nonPositiveCount) {
      try pantry.add("rice", count: count)
    }
    #expect(pantry.names.isEmpty)  // nothing was stored
  }
}
