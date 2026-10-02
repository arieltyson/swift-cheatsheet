import Foundation
import Synchronization
import Testing

@testable import ConcurrencyExamples

/// Answers every request with a canned status code and body.
final class StubProtocol: URLProtocol {
  static let reply = Mutex<(status: Int, body: Data)>((200, Data()))

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest)
    -> URLRequest
  { request }

  override func startLoading() {
    let (status, body) = Self.reply.withLock { $0 }
    let response = HTTPURLResponse(
      url: request.url!, statusCode: status, httpVersion: nil,
      headerFields: nil)!
    client?.urlProtocol(
      self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: body)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

func stubbedClient() -> APIClient {
  let configuration = URLSessionConfiguration.ephemeral
  configuration.protocolClasses = [StubProtocol.self]
  return APIClient(session: URLSession(configuration: configuration))
}

@Test func codableDemosRun() throws {
  try demoDecoding()
  try demoEncoding()
}

// One test, so the shared stub reply is never changed mid-request.
@Test func clientDecodesAndRejectsBadStatus() async throws {
  let url = try #require(URL(string: "https://api.example.com/repos"))
  let json =
    #"[{"name":"a","stargazers_count":2,"updated_at":"2026-01-01T00:00:00Z"}]"#
  StubProtocol.reply.withLock { $0 = (200, Data(json.utf8)) }
  let repos = try await stubbedClient().get([Repo].self, from: url)
  #expect(repos.map(\.stars) == [2])
  #expect(repos[0].summary == nil)
  StubProtocol.reply.withLock { $0 = (500, Data()) }
  await #expect(throws: APIError.badStatus(500)) {
    try await stubbedClient().get([Repo].self, from: url)
  }
  StubProtocol.reply.withLock { $0 = (200, Data("{}".utf8)) }
  await #expect(throws: DecodingError.self) {
    try await stubbedClient().get([Repo].self, from: url)
  }
}

@Test func searchURLEncodesQueryItems() {
  #expect(
    searchURL("a b&c", page: 2)?.absoluteString
      == "https://api.example.com/search?q=a%20b%26c&page=2")
}
