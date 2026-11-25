import SwiftUI

struct Contact: Identifiable {
  let id = UUID()
  var name: String
}

@MainActor @Observable
final class ContactBook {
  private(set) var contacts: [Contact] = []
  func add(_ contact: Contact) { contacts.append(contact) }
}

/// Three ways a child view (often a sheet) sends data back.
struct ContactsScreen: View {
  @State private var book = ContactBook()
  @State private var showingForm = false
  @State private var favourite = ""

  var body: some View {
    NavigationStack {
      List(book.contacts) { Text($0.name) }
        .toolbar {
          Button("Add", systemImage: "plus") { showingForm = true }
        }
        .sheet(isPresented: $showingForm) {
          // 1. A closure: the child says WHAT happened, the parent
          //    decides what to do. Most reusable; easy to preview.
          ContactForm { contact in book.add(contact) }
        }
      // 2. A @Binding: the child edits one value the parent owns
      FavouriteField(favourite: $favourite)
      // 3. The model itself: the child calls its methods directly.
      //    Least code; ties the child to this model.
      ContactCount(book: book)
    }
  }
}

struct ContactForm: View {
  // Stored closure property: Swift's memberwise init takes it, so
  // ContactForm { ... } works with no init of your own
  let onSave: (Contact) -> Void
  @State private var name = ""
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      Form { TextField("Name", text: $name) }
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
              onSave(Contact(name: name))
              dismiss()
            }
          }
        }
    }
  }
}

struct FavouriteField: View {
  @Binding var favourite: String
  var body: some View { TextField("Favourite", text: $favourite) }
}

struct ContactCount: View {
  let book: ContactBook  // reading an @Observable needs no wrapper
  var body: some View { Text("\(book.contacts.count) contacts") }
}

/// Writing your own init? A closure that is stored and called later
/// must be marked @escaping, or Swift says "converting non-escaping
/// parameter to generic parameter may allow it to escape".
struct RenameForm: View {
  let original: String
  let onRename: (String) -> Void
  @State private var draft: String

  init(original: String, onRename: @escaping (String) -> Void) {
    self.original = original
    self.onRename = onRename
    _draft = State(initialValue: original)  // seed @State once
  }

  var body: some View {
    TextField(original, text: $draft)
      .onSubmit { onRename(draft) }
  }
}
