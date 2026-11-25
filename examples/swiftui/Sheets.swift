import SwiftUI

struct Memo: Identifiable {
  let id = UUID()
  var text: String
}

/// Two ways to present a sheet.
/// isPresented: a Bool switch, for "show THE form".
/// item: an optional value, for "show the form FOR THIS thing";
/// non-nil shows it, nil hides it, and the closure gets the value.
struct SheetBasics: View {
  @State private var showingNew = false
  @State private var editing: Memo?
  private let notes = [Memo(text: "Buy milk"), Memo(text: "Call mum")]

  var body: some View {
    NavigationStack {
      List(notes) { note in
        Button(note.text) { editing = note }
      }
      .navigationTitle("Notes")
      .toolbar {
        Button("New note", systemImage: "plus") { showingNew = true }
      }
      // $ because the sheet sets it back to false when dismissed
      .sheet(isPresented: $showingNew) {
        NoteForm(title: "New Note")
          .presentationDetents([.medium, .large])
      }
      .sheet(item: $editing) { note in
        NoteForm(title: note.text)
      }
    }
  }
}

/// A sheet closes itself with dismiss, from the environment.
struct NoteForm: View {
  let title: String
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {  // its own, for a title and toolbar buttons
      Form { Text("Fields go here") }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Save") { dismiss() }
          }
        }
    }
  }
}
