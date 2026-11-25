import SwiftUI

/// Title display modes. The modifiers go on the CONTENT inside the
/// NavigationStack, never on the NavigationStack itself.
struct TitleModeScreen: View {
  let mode: NavigationBarItem.TitleDisplayMode
  let add: () -> Void

  var body: some View {
    NavigationStack {
      List(1...12, id: \.self) { Text("Item \($0)") }
        // .large: big title under the bar, shrinks as you scroll
        // .inline: small and centred in the bar, always
        // .automatic: inherits from the screen it was pushed from
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(mode)
        .toolbar {
          // Title + symbol: the bar shows the symbol, VoiceOver
          // reads the title
          Button("Add item", systemImage: "plus", action: add)
        }
    }
  }
}

/// Three ways to write an icon button, and how labelStyle changes it.
struct IconButtons: View {
  @State private var count = 0

  var body: some View {
    VStack(spacing: 16) {
      // Shortest (iOS 17+): title, symbol, action
      Button("Add", systemImage: "plus") { count += 1 }
      // Same thing, written out: use when the label needs modifiers
      Button {
        count += 1
      } label: {
        Label("Add", systemImage: "plus")
      }
      .labelStyle(.iconOnly)
      // An Image alone has no text, so name it for VoiceOver
      Button {
        count += 1
      } label: {
        Image(systemName: "plus")
      }
      .accessibilityLabel("Add")
      Label("Added \(count)", systemImage: "checkmark")
        .labelStyle(.titleOnly)
    }
    .buttonStyle(.bordered)
  }
}

/// Where each ToolbarItem placement lands. `.toolbar { }` holds the
/// items; each `ToolbarItem(placement:)` wraps ONE view (usually a
/// Button). Use ToolbarItemGroup for several views in one spot.
struct ToolbarPlacements: View {
  // dismiss closes whatever presented this screen (a sheet, a push)
  @Environment(\.dismiss) private var dismiss
  @State private var text = ""

  var body: some View {
    NavigationStack {
      Form { TextField("Name", text: $text) }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          // Semantic placements: the system picks the side
          // (leading on iOS) and the style. Use these in sheets.
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
          }
          // Trailing, bold. Save work FIRST, then dismiss()
          ToolbarItem(placement: .confirmationAction) {
            Button("Save") { dismiss() }
              .disabled(text.isEmpty)
          }
          // Centre of the bar: replaces the title
          ToolbarItem(placement: .principal) {
            Text("Principal").font(.headline)
          }
          // Bottom of the screen; a group holds several views
          ToolbarItemGroup(placement: .bottomBar) {
            Button("Bottom", systemImage: "trash") {}
            Spacer()
            Text("bottomBar").font(.caption)
          }
          // Above the keyboard, only while it is up
          ToolbarItem(placement: .keyboard) {
            Button("Done") {}
          }
        }
    }
  }
}

/// Explicit sides when the button is not Cancel or Save.
struct ToolbarSides: View {
  var body: some View {
    NavigationStack {
      List(1...3, id: \.self) { Text("Row \($0)") }
        .navigationTitle("Sides")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button("Edit") {}
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button("Add", systemImage: "plus") {}
          }
        }
    }
  }
}
