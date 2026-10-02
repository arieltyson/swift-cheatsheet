import Foundation
import Synchronization
import Testing

@testable import AppExamples

@Test func demosRun() async throws {
  await demoViewModelWithFake()
  demoUserDefaults()
  try demoFileStore()
}

@MainActor
@Test func viewModelShowsAnErrorAndClearsIt() async {
  let model = ReposViewModel(
    service: FakeRepoService(result: .failure(URLError(.timedOut))))
  await model.load(user: "x")
  #expect(model.names.isEmpty)
  #expect(model.errorMessage != nil)
}

@Test func imageLoaderDownloadsEachURLOnce() async throws {
  let downloads = Mutex(0)
  let loader = ImageLoader { url in
    downloads.withLock { $0 += 1 }
    try await Task.sleep(for: .milliseconds(50))
    return Data(url.absoluteString.utf8)
  }
  let url = try #require(URL(string: "https://example.com/a.png"))
  // Ten callers at once share one download
  try await withThrowingTaskGroup(of: Data.self) { group in
    for _ in 0..<10 {
      group.addTask { try await loader.data(for: url) }
    }
    for try await data in group {
      #expect(data == Data(url.absoluteString.utf8))
    }
  }
  _ = try await loader.data(for: url)
  #expect(downloads.withLock { $0 } == 1)
}

struct Row: Identifiable, Sendable {
  let id: Int
}

@MainActor
@Test func paginatorLoadsOnlyAtTheEndAndStops() async {
  let calls = Mutex(0)
  let paginator = Paginator<Row> { page in
    calls.withLock { $0 += 1 }
    let rows = (0..<3).map { Row(id: (page - 1) * 3 + $0) }
    return Page(items: rows, hasMore: page < 2)
  }
  await paginator.loadMoreIfNeeded()
  #expect(paginator.items.map(\.id) == [0, 1, 2])
  // A row that is not last does not trigger a load
  await paginator.loadMoreIfNeeded(after: paginator.items[0])
  #expect(calls.withLock { $0 } == 1)
  await paginator.loadMoreIfNeeded(after: paginator.items[2])
  #expect(paginator.items.count == 6)
  #expect(!paginator.hasMore)
  await paginator.loadMoreIfNeeded(after: paginator.items[5])
  #expect(calls.withLock { $0 } == 2)
}

@MainActor
@Test func paginatorIgnoresOverlappingLoads() async {
  let calls = Mutex(0)
  let paginator = Paginator<Row> { _ in
    calls.withLock { $0 += 1 }
    try await Task.sleep(for: .milliseconds(50))
    return Page(items: [Row(id: 0)], hasMore: true)
  }
  async let first: Void = paginator.loadMoreIfNeeded()
  async let second: Void = paginator.loadMoreIfNeeded()
  _ = await (first, second)
  #expect(calls.withLock { $0 } == 1)
  #expect(paginator.items.count == 1)
}

@Test func fileStoreRoundTripsCodable() throws {
  struct Settings: Codable, Equatable { var volume: Int }
  let url = URL.temporaryDirectory.appending(path: "\(UUID()).json")
  defer { try? FileManager.default.removeItem(at: url) }
  let store = FileStore<Settings>(url: url)
  try store.save(Settings(volume: 7))
  #expect(try store.load() == Settings(volume: 7))
}
