/// Fetches pages one by one; stops early if the task is cancelled.
func countFinishedPages(upTo limit: Int) async -> Int {
  var finished = 0
  for number in 1...limit {
    if Task.isCancelled { break }
    _ = await fetchPage(number, delayMs: 10)
    finished += 1
  }
  return finished
}

func demoCancellation() async {
  let task = Task { await countFinishedPages(upTo: 100) }
  try? await Task.sleep(for: .milliseconds(35))
  task.cancel()
  let finished = await task.value
  assert(finished < 100)
  // Task.sleep and Task.checkCancellation() throw CancellationError
  let sleeper = Task { try await Task.sleep(for: .seconds(10)) }
  sleeper.cancel()
  let outcome = await sleeper.result
  assert((try? outcome.get()) == nil)
}

/// Returns the operation's result, or nil if it is slower than limit.
func withTimeout<Value: Sendable>(
  _ limit: Duration,
  _ operation: @escaping @Sendable () async -> Value
) async -> Value? {
  await withTaskGroup(of: Value?.self) { group in
    group.addTask { await operation() }
    group.addTask {
      try? await Task.sleep(for: limit)
      return nil
    }
    let first = await group.next() ?? nil
    group.cancelAll()
    return first
  }
}

func demoTimeout() async {
  let fast = await withTimeout(.seconds(1)) { 42 }
  assert(fast == 42)
  let slow = await withTimeout(.milliseconds(10)) {
    await fetchPage(1, delayMs: 1_000).count
  }
  assert(slow == nil)
}
