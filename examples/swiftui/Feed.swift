import SwiftUI

struct Post: Decodable, Identifiable, Sendable {
  let id: Int
  let title: String
  let imageURL: URL
}

struct FeedScreen: View {
  @State private var feed = Paginator<Post> { page in
    try await PostsAPI.page(page)
  }

  var body: some View {
    List {
      ForEach(feed.items) { post in
        PostRow(post: post)
          .task { await feed.loadMoreIfNeeded(after: post) }
      }
      if feed.isLoading {
        ProgressView().frame(maxWidth: .infinity)
      }
    }
    .task { await feed.loadMoreIfNeeded() }
  }
}

enum PostsAPI {
  struct Response: Decodable {
    let posts: [Post]
    let hasMore: Bool
  }

  static func page(_ number: Int) async throws -> Page<Post> {
    let url = URL(
      string: "https://api.example.com/posts?page=\(number)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(Response.self, from: data)
    return Page(items: response.posts, hasMore: response.hasMore)
  }
}

let sharedImageLoader = ImageLoader()

/// Shows an image through the shared cache; reused cells stay correct.
struct CachedImage: View {
  let url: URL
  @State private var image: UIImage?

  var body: some View {
    Group {
      if let image {
        Image(uiImage: image).resizable().scaledToFill()
      } else {
        Color.secondary.opacity(0.2)
      }
    }
    // id: a new URL cancels the old load and starts a new one
    .task(id: url) {
      image = nil
      if let data = try? await sharedImageLoader.data(for: url) {
        image = UIImage(data: data)
      }
    }
  }
}

struct PostRow: View {
  let post: Post

  var body: some View {
    HStack {
      CachedImage(url: post.imageURL)
        .frame(width: 56, height: 56)
        .clipShape(.rect(cornerRadius: 8))
        .accessibilityHidden(true)
      Text(post.title)
    }
  }
}
