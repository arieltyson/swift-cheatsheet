import SwiftUI

struct Article: Decodable, Identifiable {
  let id: Int
  let title: String
  let imageURL: URL?
}

/// Owns the load; the view only switches on its phase.
@MainActor
@Observable
final class ArticlesModel {
  enum Phase {
    case loading
    case loaded([Article])
    case failed(String)
  }

  private(set) var phase = Phase.loading
  private let url = URL(string: "https://api.example.com/articles")!

  func load() async {
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
      }
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      phase = .loaded(try decoder.decode([Article].self, from: data))
    } catch is CancellationError {
      return
    } catch {
      phase = .failed(error.localizedDescription)
    }
  }
}

struct ArticlesScreen: View {
  @State private var model = ArticlesModel()

  var body: some View {
    NavigationStack {
      content
        .navigationTitle("Articles")
        .task { await model.load() }
    }
  }

  @ViewBuilder private var content: some View {
    switch model.phase {
    case .loading:
      ProgressView()
    case .loaded(let articles) where articles.isEmpty:
      ContentUnavailableView("No articles", systemImage: "doc")
    case .loaded(let articles):
      List(articles) { article in
        ArticleRow(article: article)
      }
      .refreshable { await model.load() }
    case .failed(let message):
      ContentUnavailableView {
        Label("Couldn't load", systemImage: "wifi.slash")
      } description: {
        Text(message)
      } actions: {
        Button("Try again") { Task { await model.load() } }
      }
    }
  }
}

struct ArticleRow: View {
  let article: Article

  var body: some View {
    HStack(spacing: 12) {
      AsyncImage(url: article.imageURL) { image in
        image.resizable().scaledToFill()
      } placeholder: {
        Color.secondary.opacity(0.2)
      }
      .frame(width: 44, height: 44)
      .clipShape(.rect(cornerRadius: 8))
      .accessibilityHidden(true)
      Text(article.title)
    }
  }
}
