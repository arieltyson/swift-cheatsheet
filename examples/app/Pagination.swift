import Foundation
import Observation

struct Page<Item: Sendable>: Sendable {
  let items: [Item]
  let hasMore: Bool
}

/// Loads the next page when the last row appears, never twice at once.
@MainActor
@Observable
final class Paginator<Item: Identifiable & Sendable> {
  typealias Fetch = @Sendable (_ page: Int) async throws -> Page<Item>

  private(set) var items: [Item] = []
  private(set) var isLoading = false
  private(set) var hasMore = true
  private var nextPage = 1
  private let fetch: Fetch

  init(fetch: @escaping Fetch) {
    self.fetch = fetch
  }

  /// Call from each row's onAppear; nil loads the first page.
  func loadMoreIfNeeded(after item: Item? = nil) async {
    if let item, item.id != items.last?.id { return }
    guard !isLoading, hasMore else { return }
    isLoading = true
    defer { isLoading = false }
    do {
      let page = try await fetch(nextPage)
      items += page.items
      hasMore = page.hasMore
      nextPage += 1
    } catch {
      // Keep hasMore true, so scrolling again retries this page
    }
  }
}
