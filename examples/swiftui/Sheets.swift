import SwiftUI

struct Memo: Identifiable {
  let id = UUID()
  var text: String
}

/// 1. sheet(isPresented:): a Bool switch, for "show THE form".
/// true shows it; swiping down or dismiss() sets it back to false.
struct SheetIsPresented: View {
  @State private var showingNew = false

  var body: some View {
    NavigationStack {
      Text("No notes yet")
        .navigationTitle("Notes")
        .toolbar {
          // Step 1: a button flips the Bool
          Button("New note", systemImage: "plus") {
            showingNew = true
          }
        }
        // Step 2: $ because the sheet writes false back
        .sheet(isPresented: $showingNew) {
          NoteForm(title: "New Note")
            .presentationDetents([.medium, .large])
        }
    }
  }
}

/// 2. sheet(item:): an optional value, for "show the form FOR THIS
/// thing". Non-nil shows it, nil hides it, and the closure gets the
/// unwrapped value. The type must be Identifiable.
struct SheetItem: View {
  @State private var editing: Memo?  // nil = no sheet
  private let notes = [Memo(text: "Buy milk"), Memo(text: "Call mum")]

  var body: some View {
    NavigationStack {
      List(notes) { note in
        // Step 1: setting the optional opens the sheet
        Button(note.text) { editing = note }
      }
      .navigationTitle("Notes")
      // Step 2: the closure receives the non-nil Memo
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
