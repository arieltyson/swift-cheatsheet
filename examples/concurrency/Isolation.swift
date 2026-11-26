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

actor Tally {
  // Readable without await from anywhere. A plain let can only
  // skip await inside its own module.
  nonisolated let name: String
  private(set) var total: Int
  // A default value means init does not have to set it
  private var count = 0

  /// A plain init sets properties; it cannot call the actor's methods.
  init(name: String, total: Int = 0) {
    self.name = name
    self.total = total
  }

  /// An async init runs on the actor, so it can call its methods.
  init(name: String, adding values: [Int]) async {
    self.name = name
    total = 0
    for value in values {
      add(value)
    }
  }

  func add(_ value: Int) {
    total += value
    count += 1
  }
}

func demoActorInit() async {
  // Creating an actor needs no await
  let plain = Tally(name: "plain", total: 5)
  // Reading a nonisolated let needs no await; a var does
  assert(plain.name == "plain")
  let plainTotal = await plain.total
  assert(plainTotal == 5)
  // An async init does need await
  let summed = await Tally(name: "summed", adding: [1, 2, 3])
  let summedTotal = await summed.total
  assert(summedTotal == 6)
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

/// Sendable: safe to hand to another task or actor. Structs and enums
/// whose stored values are all Sendable get it automatically inside
/// their module; writing it out makes it part of the public promise.
struct Receipt: Sendable, Equatable {
  let merchant: String
  let cents: Int
}

enum ReceiptError: Error, Equatable, Sendable {
  case empty
}

/// A class is Sendable only if it is final and every stored property
/// is a constant (let) of a Sendable type.
final class Settings: Sendable {
  let currency: String
  init(currency: String) { self.currency = currency }
}

func demoSendable() async {
  let receipt = Receipt(merchant: "Cafe", cents: 450)
  let settings = Settings(currency: "USD")
  // Both cross into a new task: allowed because both are Sendable
  let label = await Task.detached {
    "\(receipt.merchant) \(receipt.cents) \(settings.currency)"
  }.value
  assert(label == "Cafe 450 USD")
  // A closure that runs elsewhere is marked @Sendable and may only
  // capture Sendable values
  let double: @Sendable (Int) -> Int = { $0 * 2 }
  assert(double(receipt.cents) == 900)
  assert(ReceiptError.empty == .empty)
}
