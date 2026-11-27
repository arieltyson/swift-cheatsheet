import Testing

/// Parameterized tests: one function, run once per argument. Each
/// run is its own test case, so one failing value doesn't hide the
/// others, and the report names the value that failed.
@Suite("Arguments")
struct ArgumentsTests {
  // The display name comes first, then arguments:. The function takes
  // one parameter whose type matches the array's elements.
  @Test("Counts below one are rejected", arguments: [0, -1, -50])
  func rejects(count: Int) {
    let pantry = Pantry()
    #expect(throws: PantryError.nonPositiveCount) {
      try pantry.add("rice", count: count)
    }
    #expect(pantry.names.isEmpty)
  }

  // zip pairs each input with its expected result: 3 runs
  @Test(arguments: zip([1, 2, 5], [2, 3, 6]))
  func addsToOne(extra: Int, expected: Int) throws {
    let pantry = Pantry()
    try pantry.add("tea", count: 1)
    try pantry.add("tea", count: extra)
    #expect(pantry.count(of: "tea") == expected)
  }

  // Two separate collections run EVERY combination: 2 x 2 = 4 runs
  @Test(arguments: ["rice", "tea"], [1, 3])
  func storesAnyItem(name: String, count: Int) throws {
    let pantry = Pantry()
    try pantry.add(name, count: count)
    #expect(pantry.count(of: name) == count)
  }
}
