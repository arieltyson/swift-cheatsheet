import SwiftData
import SwiftUI

struct SettingsScreen: View {
  // Reads and writes UserDefaults; the view updates when it changes
  @AppStorage("prefersCompact") private var prefersCompact = false

  var body: some View {
    Toggle("Compact rows", isOn: $prefersCompact)
  }
}

@Model
final class Note {
  var text: String
  var createdAt: Date

  init(text: String, createdAt: Date = .now) {
    self.text = text
    self.createdAt = createdAt
  }
}

struct NotesScreen: View {
  @Environment(\.modelContext) private var context
  @Query(sort: \Note.createdAt, order: .reverse) private var notes:
    [Note]

  var body: some View {
    List {
      ForEach(notes) { note in
        Text(note.text)
      }
      .onDelete { offsets in
        for index in offsets { context.delete(notes[index]) }
      }
    }
    .toolbar {
      Button("Add") { context.insert(Note(text: "New note")) }
    }
  }
}
