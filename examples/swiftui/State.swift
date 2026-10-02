import SwiftUI

struct CounterScreen: View {
  @State private var count = 0

  var body: some View {
    VStack(spacing: 16) {
      Text("Solved: \(count)")
        .font(.headline)
      CounterControl(count: $count)
    }
    .padding()
  }
}

struct CounterControl: View {
  @Binding var count: Int

  var body: some View {
    Stepper("Solved problems", value: $count, in: 0...100)
      .accessibilityValue("\(count)")
  }
}
