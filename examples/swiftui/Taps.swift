import SwiftUI

/// Tapping empty space and tapping an item on top of it.
/// Layers later in a ZStack are in front, so they get taps first.
struct SlotBoard: View {
  let slotHeight: CGFloat = 50
  @State private var taken: Set<Int> = [2]
  @State private var message = "Tap a slot"

  var body: some View {
    VStack {
      Text(message)
      ZStack(alignment: .topLeading) {
        // Back layer: the whole board answers taps, even where it's
        // empty, because of contentShape
        Rectangle().fill(.clear)
          .contentShape(.rect)
          .onTapGesture { location in
            // Which slot? Divide the y position by the slot height
            let slot = Int(location.y / slotHeight)
            message = "Empty slot \(slot)"
          }
        // Front layer: items catch their own taps first
        ForEach(Array(taken), id: \.self) { slot in
          Button("Booked \(slot)") { message = "Item in slot \(slot)" }
            .frame(maxWidth: .infinity, minHeight: slotHeight)
            .background(.orange.opacity(0.3))
            .offset(y: CGFloat(slot) * slotHeight)
        }
      }
      .frame(height: slotHeight * 6)
    }
  }
}
