import Combine
import Foundation
import Testing

@testable import ConcurrencyExamples

// Each demo's asserts are the results shown on the page.
@Test func asyncDemosRun() async {
  await demoAsyncAwait()
  await demoTasks()
  await demoCancellation()
  await demoTimeout()
  await demoAsyncStream()
  await demoActor()
  await demoMainActor()
}

@Test func syncDemosRun() {
  demoMutex()
  demoSubjects()
  demoCancellables()
  demoOperators()
  demoErrorHandling()
  demoRetainCycles()
}

/// Asserts that work ran in parallel: well under the serial time.
func elapsed(_ work: () async -> Void) async -> Duration {
  let clock = ContinuousClock()
  let start = clock.now
  await work()
  return clock.now - start
}

@Test func asyncLetRunsInParallel() async {
  var items: [String] = []
  let time = await elapsed { items = await fetchThreePages() }
  #expect(items.count == 12)
  #expect(items.first == "page 1 item 1")
  #expect(time < .milliseconds(250))
}

@Test func taskGroupKeepsPageOrderAndRunsInParallel() async {
  var items: [String] = []
  let time = await elapsed { items = await fetchPages([3, 1, 2]) }
  #expect(items.count == 12)
  #expect(items.first == "page 3 item 1")
  #expect(Set(items).count == 12)
  #expect(time < .milliseconds(250))
}

@Test func throwingGroupFailsFast() async throws {
  #expect(try await fetchUsers([2, 1]) == ["user 1", "user 2"])
  await #expect(throws: FetchError.notFound) {
    try await fetchUsers([1, 0, 2])
  }
}

@Test func limitedGroupProcessesEverything() async {
  #expect(await countItems(inPages: Array(1...10), limit: 3) == 40)
  #expect(await countItems(inPages: [], limit: 3) == 0)
}

@Test func continuationBridgesTheCallback() async {
  #expect(await page(2) == (1...4).map { "page 2 item \($0)" })
}

@Test func callbacksJoinWithADispatchGroup() async {
  let items = await withCheckedContinuation { continuation in
    fetchPagesWithCallbacks([1, 2, 3]) {
      continuation.resume(returning: $0)
    }
  }
  #expect(items.count == 12)
  #expect(items.first == "page 1 item 1")
  #expect(items.last == "page 3 item 4")
}

@Test func combineMergesInParallelInOrder() async {
  var items: [String] = []
  for await value in pagesPublisher([2, 1, 3]).values {
    items = value
  }
  #expect(items.count == 12)
  #expect(items.first == "page 1 item 1")
  #expect(Set(items).count == 12)
}

@MainActor
@Test func tickerStopsAndFreesItsOwner() async throws {
  let ticker = Ticker()
  ticker.start(every: .milliseconds(5))
  try await Task.sleep(for: .milliseconds(60))
  ticker.stop()
  let ticks = ticker.ticks
  #expect(ticks > 0)
  try await Task.sleep(for: .milliseconds(30))
  #expect(ticker.ticks == ticks)
  weak var released: Ticker?
  do {
    let running = Ticker()
    running.start(every: .milliseconds(5))
    released = running
  }
  #expect(released == nil)
}
