import SwiftUI

/// Frame tuning. A frame proposes a size to the view inside it;
/// min/max set the range it accepts, alignment places the content.
/// Text hugs: without a frame it is only as big as its letters.
struct FrameTuning: View {
  var body: some View {
    VStack(spacing: 12) {
      // Exactly 120 x 44, whatever the parent offers
      Text("Fixed").frame(width: 120, height: 44)
      // As wide as the parent allows: full-width buttons and rows
      Text("Fill width").frame(maxWidth: .infinity)
      // At least 44 tall (a touch target), taller if text wraps
      Text("Tall enough").frame(minHeight: 44)
      // Grows with the screen, but stops at 400 (iPad, landscape)
      Text("Capped").frame(maxWidth: 400)
      // Fill the width, then put the content at the leading edge
      Text("Leading").frame(maxWidth: .infinity, alignment: .leading)
      // Never truncate: take the text's own (ideal) size
      Text("A long label that must not cut off").fixedSize()
      // Take all the space left over, in both directions
      Color.gray.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .padding()
  }
}

/// One fill, placed in the same 160 x 100 slot six ways. The
/// dashed box is the space offered; the colour is what the view
/// chose. `.fit` stays inside the slot, `.fill` covers it.
struct AspectRatioGallery: View {
  var body: some View {
    Grid(horizontalSpacing: 16, verticalSpacing: 20) {
      GridRow {
        slot("no modifier") { fill }
        slot("16/9, .fit") {
          fill.aspectRatio(16 / 9, contentMode: .fit)
        }
      }
      GridRow {
        slot("1, .fit") { fill.aspectRatio(1, contentMode: .fit) }
        slot("1, .fill") { fill.aspectRatio(1, contentMode: .fill) }
      }
      GridRow {
        slot("3/4, .fit") {
          fill.aspectRatio(3 / 4, contentMode: .fit)
        }
        slot("scaledToFit()") {
          Image(systemName: "mountain.2.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.teal)
        }
      }
    }
    .padding()
  }

  private var fill: some View {
    LinearGradient(
      colors: [.teal, .indigo],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private func slot(
    _ caption: String, @ViewBuilder content: () -> some View
  ) -> some View {
    VStack(spacing: 6) {
      content()
        .frame(width: 160, height: 100)
        .clipped()
        .overlay {
          Rectangle().stroke(.secondary, style: .init(dash: [4]))
        }
      Text(caption).font(.caption.monospaced())
    }
  }
}

/// A greedy control in a centred VStack, three ways. Each grey box
/// is the screen. Stepper takes the full width it's offered, so
/// "centred" still means edge to edge.
struct GreedyControls: View {
  @State private var count = 3

  var body: some View {
    VStack(spacing: 20) {
      screen("no modifier: touches both edges") {
        Stepper("Count: \(count)", value: $count)
      }
      screen(".padding(): inset from the edges") {
        Stepper("Count: \(count)", value: $count).padding()
      }
      screen(".fixedSize(): hugs, so it centres") {
        Stepper("Count: \(count)", value: $count).fixedSize()
      }
    }
    .padding()
  }

  private func screen(
    _ caption: String, @ViewBuilder content: () -> some View
  ) -> some View {
    VStack(spacing: 6) {
      VStack { content() }
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(.gray.opacity(0.15))
      Text(caption).font(.caption.monospaced())
    }
  }
}

/// Conditional styling: pick the VALUE with a ternary and keep one
/// modifier, rather than `if selected { view.background(...) }`.
struct HighlightedRow: View {
  let items = ["Mon", "Tue", "Wed", "Thu", "Fri"]
  @State private var picked: Set<Int> = [1, 3]

  var body: some View {
    HStack {
      ForEach(items.indices, id: \.self) { index in
        let isOn = picked.contains(index)
        Button {
          if isOn { picked.remove(index) } else { picked.insert(index) }
        } label: {
          Text(items[index])
            .frame(maxWidth: .infinity, minHeight: 44)
            // Both branches must be the same type (Color here)
            .background(isOn ? Color.green.opacity(0.4) : .clear)
            .foregroundStyle(isOn ? .primary : .secondary)
            .fontWeight(isOn ? .bold : .regular)
        }
      }
    }
    .padding()
  }
}
