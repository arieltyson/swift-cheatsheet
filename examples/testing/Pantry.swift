/// A small type to test. In a real package it lives in the library
/// target, and the test file starts with `@testable import MyLibrary`.
final class Pantry {
  private var counts: [String: Int] = [:]

  /// Item names, A to Z.
  var names: [String] { counts.keys.sorted() }

  func count(of name: String) -> Int { counts[name, default: 0] }

  func add(_ name: String, count: Int) throws(PantryError) {
    guard count > 0 else { throw .nonPositiveCount }
    counts[name, default: 0] += count
  }
}

enum PantryError: Error, Equatable {
  case nonPositiveCount
}
