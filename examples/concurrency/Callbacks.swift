import Dispatch
import Synchronization

/// Pages stored from callbacks that may arrive on any thread.
final class PageStore: Sendable {
  private let pages = Mutex<[Int: [String]]>([:])

  func save(_ items: [String], forPage number: Int) {
    pages.withLock { $0[number] = items }
  }

  func items(inOrder numbers: [Int]) -> [String] {
    pages.withLock { pages in numbers.flatMap { pages[$0] ?? [] } }
  }
}

/// Requests every page in parallel; calls completion once, on main.
func fetchPagesWithCallbacks(
  _ numbers: [Int],
  completion: @escaping @Sendable ([String]) -> Void
) {
  let group = DispatchGroup()
  let store = PageStore()
  for number in numbers {
    group.enter()
    requestPage(number) { items in
      store.save(items, forPage: number)
      group.leave()
    }
  }
  group.notify(queue: .main) {
    completion(store.items(inOrder: numbers))
  }
}

/// A counter that many threads can update at once.
final class HitCounter: Sendable {
  private let hits = Mutex(0)

  func record() {
    hits.withLock { $0 += 1 }
  }

  var count: Int { hits.withLock { $0 } }
}

func demoMutex() {
  let counter = HitCounter()
  DispatchQueue.concurrentPerform(iterations: 1_000) { _ in
    counter.record()
  }
  assert(counter.count == 1_000)
}
