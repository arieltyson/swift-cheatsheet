import Foundation
import Observation

/// The view model depends on this protocol, not on URLSession.
protocol RepoService: Sendable {
  func repoNames(for user: String) async throws -> [String]
}

struct LiveRepoService: RepoService {
  struct Repo: Decodable { let name: String }

  func repoNames(for user: String) async throws -> [String] {
    let url = URL(string: "https://api.github.com/users/\(user)/repos")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Repo].self, from: data).map(\.name)
  }
}

@MainActor
@Observable
final class ReposViewModel {
  private(set) var names: [String] = []
  private(set) var errorMessage: String?
  private let service: any RepoService

  // Inject the dependency; the app passes LiveRepoService()
  init(service: any RepoService) {
    self.service = service
  }

  func load(user: String) async {
    do {
      names = try await service.repoNames(for: user).sorted()
      errorMessage = nil
    } catch {
      names = []
      errorMessage = error.localizedDescription
    }
  }
}

/// A test double: returns canned data or a canned error, instantly.
struct FakeRepoService: RepoService {
  var result: Result<[String], URLError>

  func repoNames(for user: String) async throws -> [String] {
    try result.get()
  }
}

func demoViewModelWithFake() async {
  let fake = FakeRepoService(result: .success(["b", "a"]))
  let model = await ReposViewModel(service: fake)
  await model.load(user: "any")
  let names = await model.names
  assert(names == ["a", "b"])
  let offline = FakeRepoService(
    result: .failure(URLError(.notConnectedToInternet)))
  let failing = await ReposViewModel(service: offline)
  await failing.load(user: "any")
  let message = await failing.errorMessage
  assert(message != nil)
}
