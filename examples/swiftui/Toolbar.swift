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
