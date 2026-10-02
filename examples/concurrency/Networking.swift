import Foundation

/// Rename JSON keys with CodingKeys; optionals accept missing or null.
struct Repo: Codable, Equatable {
  let name: String
  let stars: Int
  let summary: String?
  let updatedAt: Date

  enum CodingKeys: String, CodingKey {
    case name
    case stars = "stargazers_count"
    case summary = "description"
    case updatedAt = "updated_at"
  }
}

func demoDecoding() throws {
  let json = """
    [{"name": "swift", "stargazers_count": 68000,
      "description": null, "updated_at": "2026-10-01T09:30:00Z"}]
    """
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  let repos = try decoder.decode([Repo].self, from: Data(json.utf8))
  assert(repos.count == 1)
  assert(repos[0].stars == 68_000)
  assert(repos[0].summary == nil)
  // A missing required key throws DecodingError.keyNotFound
  let broken = Data(#"[{"name": "swift"}]"#.utf8)
  assert((try? decoder.decode([Repo].self, from: broken)) == nil)
}

func demoEncoding() throws {
  let repo = Repo(
    name: "swift", stars: 1, summary: nil,
    updatedAt: Date(timeIntervalSince1970: 0))
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601
  encoder.outputFormatting = [.sortedKeys]
  let text = String(decoding: try encoder.encode(repo), as: UTF8.self)
  assert(text.hasPrefix(#"{"name":"swift","stargazers_count":1"#))
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  let copy = try decoder.decode(Repo.self, from: Data(text.utf8))
  assert(copy == repo)
}

enum APIError: LocalizedError, Equatable {
  case badStatus(Int)

  var errorDescription: String? {
    switch self {
    case .badStatus(let code): "The server returned \(code)"
    }
  }
}

/// GETs a URL and decodes JSON. Pass a session to stub it in tests.
struct APIClient: Sendable {
  var session = URLSession.shared

  func get<Value: Decodable>(_ type: Value.Type, from url: URL)
    async throws -> Value
  {
    let (data, response) = try await session.data(from: url)
    if let http = response as? HTTPURLResponse,
      !(200..<300).contains(http.statusCode)
    {
      throw APIError.badStatus(http.statusCode)
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(Value.self, from: data)
  }
}

/// Builds a URL with query items; they are percent-encoded for you.
func searchURL(_ query: String, page: Int) -> URL? {
  var components = URLComponents(
    string: "https://api.example.com/search")
  components?.queryItems = [
    URLQueryItem(name: "q", value: query),
    URLQueryItem(name: "page", value: String(page)),
  ]
  return components?.url
}
