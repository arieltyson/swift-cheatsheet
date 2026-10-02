import SwiftUI

struct TopicSearchScreen: View {
  @State private var query = ""
  @State private var results: [String] = []

  var body: some View {
    VStack {
      TextField("Find a topic", text: $query)
        .textFieldStyle(.roundedBorder)
      List(results, id: \.self) { title in
        Text(title)
      }
    }
    .padding()
    .task(id: query) {
      let requestedQuery = query
      results = []
      guard !requestedQuery.isEmpty else { return }
      do {
        try await Task.sleep(for: .milliseconds(250))
        let matches = ["Array", "Heap", "Dictionary"].filter {
          $0.localizedCaseInsensitiveContains(requestedQuery)
        }
        try Task.checkCancellation()
        results = matches
      } catch is CancellationError {
        return
      } catch {
        results = []
      }
    }
  }
}
