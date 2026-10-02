import SwiftUI

struct ReviewSummary: View {
  let completed: Int
  let review: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Label("Practice", systemImage: "checkmark.circle")
        .font(.headline)
      Text("\(completed) problems completed")
        .font(.body)
        .fixedSize(horizontal: false, vertical: true)
      Button(action: review) {
        Label("Review completed problems", systemImage: "arrow.right")
          .frame(maxWidth: .infinity, minHeight: 44)
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
