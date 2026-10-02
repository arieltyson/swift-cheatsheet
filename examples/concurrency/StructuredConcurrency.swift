/// Fetches three pages in parallel and returns all their items.
func fetchThreePages() async -> [String] {
  async let first = fetchPage(1)
  async let second = fetchPage(2)
  async let third = fetchPage(3)
  return await first + second + third
}

/// Fetches every page in parallel, keeping the results in page order.
func fetchPages(_ numbers: [Int]) async -> [String] {
  await withTaskGroup(of: (Int, [String]).self) { group in
    for number in numbers {
      group.addTask { (number, await fetchPage(number)) }
    }
    var pages: [Int: [String]] = [:]
    for await (number, items) in group {
      pages[number] = items
    }
    return numbers.flatMap { pages[$0] ?? [] }
  }
}

/// Returns every user, or throws the first error and cancels the rest.
func fetchUsers(_ ids: [Int]) async throws -> [String] {
  try await withThrowingTaskGroup(of: String.self) { group in
    for id in ids {
      group.addTask { try await fetchUser(id: id) }
    }
    var users: [String] = []
    for try await user in group {
      users.append(user)
    }
    return users.sorted()
  }
}

/// Fetches all pages but runs at most `limit` requests at a time.
func countItems(inPages numbers: [Int], limit: Int) async -> Int {
  await withTaskGroup(of: Int.self) { group in
    var pending = numbers.makeIterator()
    for _ in 0..<limit {
      guard let number = pending.next() else { break }
      group.addTask { await fetchPage(number).count }
    }
    var total = 0
    while let count = await group.next() {
      total += count
      if let number = pending.next() {
        group.addTask { await fetchPage(number).count }
      }
    }
    return total
  }
}
