import SwiftUI

struct ExpandingCard: View {
  @State private var isExpanded = false

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Button(isExpanded ? "Hide details" : "Show details") {
        withAnimation(.spring(duration: 0.3)) { isExpanded.toggle() }
      }
      if isExpanded {
        Text("Details appear with a slide and fade.")
          .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
  }
}

/// Drag sideways to dismiss; let go early and it springs back.
struct SwipeToDismissCard: View {
  @State private var offset = CGSize.zero
  @State private var isDismissed = false

  var body: some View {
    if !isDismissed {
      RoundedRectangle(cornerRadius: 16)
        .fill(.blue.gradient)
        .frame(height: 120)
        .offset(x: offset.width)
        .rotationEffect(.degrees(offset.width / 20))
        .gesture(
          DragGesture()
            .onChanged { offset = $0.translation }
            .onEnded { value in
              withAnimation(.spring) {
                if abs(value.translation.width) > 120 {
                  isDismissed = true
                } else {
                  offset = .zero
                }
              }
            }
        )
        .accessibilityAction(named: "Dismiss") { isDismissed = true }
    }
  }
}

/// matchedGeometryEffect: one view appears to move between two places.
struct SegmentedPicker: View {
  let options = ["Day", "Week", "Month"]
  @State private var selected = "Day"
  @Namespace private var indicator

  var body: some View {
    HStack {
      ForEach(options, id: \.self) { option in
        Button(option) {
          withAnimation(.snappy) { selected = option }
        }
        .padding(8)
        .background {
          if selected == option {
            Capsule().fill(.thinMaterial)
              .matchedGeometryEffect(id: "pill", in: indicator)
          }
        }
      }
    }
  }
}
