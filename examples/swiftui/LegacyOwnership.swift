import SwiftUI

@MainActor
final class LegacyCounter: ObservableObject {
  @Published var count = 0
}

@MainActor
struct LegacyOwner: View {
  @StateObject private var model = LegacyCounter()

  var body: some View {
    LegacyChild(model: model)
  }
}

@MainActor
struct LegacyChild: View {
  @ObservedObject var model: LegacyCounter

  var body: some View {
    Button("Count: \(model.count)") { model.count += 1 }
  }
}
