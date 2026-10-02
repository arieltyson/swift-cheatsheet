import SwiftUI

@MainActor
final class LegacyCounter: ObservableObject {
  @Published var count = 0
}

struct LegacyOwner: View {
  @StateObject private var model = LegacyCounter()

  var body: some View {
    LegacyChild(model: model)
  }
}

struct LegacyChild: View {
  @ObservedObject var model: LegacyCounter

  var body: some View {
    Button("Count: \(model.count)") { model.count += 1 }
  }
}
