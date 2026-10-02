import Foundation

/// Memory cache plus in-flight sharing: one download per URL.
actor ImageLoader {
  typealias Download = @Sendable (URL) async throws -> Data

  private let cache = NSCache<NSURL, NSData>()
  private var inFlight: [URL: Task<Data, any Error>] = [:]
  private let download: Download

  init(download: @escaping Download = ImageLoader.fromNetwork) {
    cache.countLimit = 200
    self.download = download
  }

  static let fromNetwork: Download = { url in
    try await URLSession.shared.data(from: url).0
  }

  func data(for url: URL) async throws -> Data {
    if let cached = cache.object(forKey: url as NSURL) {
      return cached as Data
    }
    // A second caller awaits the same task instead of downloading
    if let running = inFlight[url] {
      return try await running.value
    }
    let task = Task { try await download(url) }
    inFlight[url] = task
    defer { inFlight[url] = nil }
    let data = try await task.value
    cache.setObject(data as NSData, forKey: url as NSURL)
    return data
  }
}
