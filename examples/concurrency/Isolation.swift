actor BankAccount {
  private(set) var balanceCents = 0

  func deposit(_ cents: Int) {
    balanceCents += cents
  }

  /// Returns false instead of letting the balance go negative.
  func withdraw(_ cents: Int) -> Bool {
    guard balanceCents >= cents else { return false }
    balanceCents -= cents
    return true
  }
}

func demoActor() async {
  let account = BankAccount()
  // 100 parallel deposits, no data race: the actor runs one at a time
  await withTaskGroup(of: Void.self) { group in
    for _ in 0..<100 {
      group.addTask { await account.deposit(1) }
    }
  }
  let balance = await account.balanceCents
  assert(balance == 100)
  let withdrew = await account.withdraw(500)
  assert(withdrew == false)
}

/// UI state lives on the main actor; slow work moves off it.
@MainActor
final class SearchModel {
  private(set) var results: [String] = []
  private(set) var isLoading = false

  func search(_ query: String) async {
    isLoading = true
    // Suspends without blocking the main thread
    results = await rankMatches(for: query)
    isLoading = false
  }
}

/// Always runs on the global executor, even when called from
/// the main actor (Swift 6.2).
@concurrent
func rankMatches(for query: String) async -> [String] {
  ["array", "hash map", "heap"].filter { $0.contains(query) }.sorted()
}

@MainActor
func demoMainActor() async {
  let model = SearchModel()
  await model.search("ha")
  assert(model.results == ["hash map"])
  assert(model.isLoading == false)
}
