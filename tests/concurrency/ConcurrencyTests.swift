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
  await demoActorInit()
  await demoRollingWindow()
  await demoRollingMax()
  await demoMainActor()
}

func timed(_ seconds: Double, _ value: Double) -> TimedValue {
  TimedValue(
    timestamp: Date(timeIntervalSince1970: seconds), value: value)
}

@Test func rollingWindowKeepsValueExactlyAtCutoff() async {
  let window = RollingWindow(duration: 5)
  await window.append(timed(1, 5))
  await window.append(timed(6, 0))
  #expect(await window.count == 2)
  #expect(await window.hasValue(atLeast: 5))
  await window.append(timed(6.5, 0))
  #expect(await window.count == 2)
  #expect(await !window.hasValue(atLeast: 5))
}

@Test func tallyInitsSetTheSameState() async {
  let plain = Tally(name: "a")
  #expect(await plain.total == 0)
  await plain.add(2)
  #expect(await plain.total == 2)
  let empty = await Tally(name: "b", adding: [])
  #expect(await empty.total == 0)
  #expect(empty.name == "b")
}

@Test func emptyWindowsHaveNothing() async {
  let window = RollingWindow(duration: 5)
  #expect(await window.count == 0)
  #expect(await !window.hasValue(atLeast: 0))
  #expect(await RollingMax(duration: 5).peak == nil)
}

@Test func rollingWindowsMatchBruteForce() async {
  var generator = SystemRandomNumberGenerator()
  for _ in 0..<50 {
    let duration = Double.random(in: 0...3, using: &generator)
    let window = RollingWindow(duration: duration)
    let rollingMax = RollingMax(duration: duration)
    var all: [TimedValue] = []
    var time = 0.0
    for _ in 0..<200 {
      time += Double.random(in: 0...1, using: &generator)
      let value = Double(Int.random(in: 0...10, using: &generator))
      let item = timed(time, value)
      all.append(item)
      await window.append(item)
      await rollingMax.append(item)

      let cutoff = item.timestamp.addingTimeInterval(-duration)
      let live = all.filter { $0.timestamp >= cutoff }
      let peak = live.map(\.value).max()!
      #expect(await window.count == live.count)
      #expect(await window.hasValue(atLeast: peak))
      #expect(await !window.hasValue(atLeast: peak + 0.5))
      #expect(await rollingMax.peak == peak)
    }
  }
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
