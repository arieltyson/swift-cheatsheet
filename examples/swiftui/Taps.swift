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

/// Every common tap API in one list. Tap each row to see which fired.
struct TapKinds: View {
  @State private var last = "Tap something"

  var body: some View {
    List {
      Text(last).font(.headline)
      // 1. Button: preferred. Accessible, highlights, works in Lists
      Button("Button { }") { last = "Button" }
      // 2. Plain tap on any view
      Text("onTapGesture { }")
        .onTapGesture { last = "single tap" }
      // 3. Double tap (count:). Single taps on it are delayed
      Text("onTapGesture(count: 2) { }")
        .onTapGesture(count: 2) { last = "double tap" }
      // 4. Where inside the view, in its own coordinates
      Text("onTapGesture { location in }")
        .onTapGesture { location in
          last = "at x \(Int(location.x)), y \(Int(location.y))"
        }
      // 5. Press and hold
      Text("onLongPressGesture { }")
        .onLongPressGesture { last = "long press" }
    }
  }
}

/// Which part of a row is tappable. Tinted = answers taps.
/// Taps land on drawn content only; a Spacer or clear area is a hole
/// until `.contentShape(.rect)` makes the whole frame count.
struct TapRegions: View {
  @State private var last = "Tap the rows"

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text(last).font(.headline)
      Text("No contentShape: only the text").font(.caption)
      HStack {
        Text("Tap me").background(.green.opacity(0.35))
        Spacer()  // a hole: taps here do nothing
      }
      .frame(height: 44)
      .border(.gray)
      .onTapGesture { last = "row 1" }

      Text(".contentShape(.rect): the whole frame").font(.caption)
      HStack {
        Text("Tap me")
        Spacer()
      }
      .frame(height: 44)
      .background(.green.opacity(0.35))
      .contentShape(.rect)  // AFTER the frame, so it covers all of it
      .onTapGesture { last = "row 2" }

      Text("Button: its label's shape, so widen the label")
        .font(.caption)
      Button { last = "row 3" } label: {
        Text("Tap me")
          .frame(
            maxWidth: .infinity, minHeight: 44, alignment: .leading)
          .contentShape(.rect)  // inside the label
          .background(.green.opacity(0.35))
      }
      .border(.gray)
    }
    .padding()
  }
}
