import SwiftUI

struct StudyTopic: Identifiable, Hashable {
  let id: Int
  let title: String
}

@MainActor
struct TopicsScreen: View {
  private let topics = [
    StudyTopic(id: 1, title: "Arrays"),
    StudyTopic(id: 2, title: "Heaps"),
  ]
  @State private var path: [StudyTopic] = []
  @State private var selectedTopic: StudyTopic?

  var body: some View {
    NavigationStack(path: $path) {
      List(topics) { topic in
        NavigationLink(topic.title, value: topic)
      }
      .navigationTitle("Topics")
      .navigationDestination(for: StudyTopic.self) { topic in
        Button("Review \(topic.title)") {
          selectedTopic = topic
        }
        .navigationTitle(topic.title)
      }
      .sheet(item: $selectedTopic) { topic in
        TopicSheet(topic: topic)
      }
    }
  }
}

@MainActor
struct TopicSheet: View {
  let topic: StudyTopic
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack(spacing: 16) {
      Text(topic.title).font(.title)
      Button("Done") { dismiss() }
    }
    .padding()
  }
}
