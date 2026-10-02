import Foundation

func demoUserDefaults() {
  // .standard in an app; a named suite keeps this demo separate
  let defaults = UserDefaults(suiteName: "cheatsheet.demo")!
  defaults.set(true, forKey: "prefersCompact")
  defaults.set(["swift", "ios"], forKey: "recentSearches")
  assert(defaults.bool(forKey: "prefersCompact"))
  let recent = defaults.stringArray(forKey: "recentSearches")
  assert(recent == ["swift", "ios"])
  // Missing keys return a default: false, 0 or nil
  assert(defaults.integer(forKey: "missing") == 0)
  defaults.removePersistentDomain(forName: "cheatsheet.demo")
}

/// Saves any Codable value as a JSON file.
struct FileStore<Value: Codable> {
  let url: URL

  func save(_ value: Value) throws {
    // .atomic writes a temp file first: no half-written file
    try JSONEncoder().encode(value).write(to: url, options: .atomic)
  }

  func load() throws -> Value? {
    guard FileManager.default.fileExists(atPath: url.path()) else {
      return nil
    }
    return try JSONDecoder().decode(
      Value.self, from: Data(contentsOf: url))
  }
}

func demoFileStore() throws {
  // In an app: URL.documentsDirectory.appending(path: "favorites.json")
  let url = URL.temporaryDirectory.appending(path: "\(UUID()).json")
  let store = FileStore<[String]>(url: url)
  let before = try store.load()
  assert(before == nil)
  try store.save(["Heap", "Trie"])
  let after = try store.load()
  assert(after == ["Heap", "Trie"])
  try FileManager.default.removeItem(at: url)
}
