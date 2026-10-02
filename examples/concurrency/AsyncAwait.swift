/// Simulates a network call: waits, then returns one page of items.
func fetchPage(_ number: Int, delayMs: Int = 100) async -> [String] {
  try? await Task.sleep(for: .milliseconds(delayMs))
  return (1...4).map { "page \(number) item \($0)" }
}

enum FetchError: Error {
  case notFound
}

/// Throws for an invalid id, like a failing request.
func fetchUser(id: Int) async throws -> String {
  guard id > 0 else { throw FetchError.notFound }
  return "user \(id)"
}

func demoAsyncAwait() async {
  let page = await fetchPage(1)
  assert(page.count == 4)
  let name = try? await fetchUser(id: 7)
  assert(name == "user 7")
  do {
    _ = try await fetchUser(id: 0)
  } catch {
    assert(error as? FetchError == .notFound)
  }
}

func demoTasks() async {
  // A Task starts immediately and runs alongside the caller
  let task = Task { await fetchPage(1) }
  let page = await task.value
  assert(page.count == 4)
  // Errors come back through value (rethrows) or result
  let failing = Task { try await fetchUser(id: 0) }
  let result = await failing.result
  assert((try? result.get()) == nil)
  // Swift 6.2: name tasks so they show up in the debugger
  let named = Task(name: "load profile") { try await fetchUser(id: 3) }
  let user = try? await named.value
  assert(user == "user 3")
}
