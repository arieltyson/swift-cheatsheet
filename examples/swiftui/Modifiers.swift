import SwiftUI

/// .background draws a layer behind the view. .backgroundStyle only
/// SETS a style; something must use it, such as .background()
/// with no arguments, so on its own it draws nothing.
struct BackgroundVsStyle: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text(".background(.yellow)")
        .padding(8)
        .background(.yellow)
      Text(".background(.yellow, in: .capsule)")
        .padding(8)
        .background(.yellow, in: .capsule)
      Text(".backgroundStyle(.yellow) alone")
        .padding(8)
        .backgroundStyle(.yellow)  // nothing drawn
      Text(".background() + .backgroundStyle")
        .padding(8)
        .background()  // uses the style set below
        .backgroundStyle(.yellow)
    }
    .font(.callout.monospaced())
    .padding()
  }
}

/// Padding on chosen edges. The tinted box is the view's size after
/// padding; the text is where the content sits inside it.
struct TargetedPadding: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      sample(".padding()") { $0.padding() }
      sample(".padding(.leading, 40)") { $0.padding(.leading, 40) }
      sample(".padding(.horizontal, 40)") {
        $0.padding(.horizontal, 40)
      }
      sample(".padding(.vertical, 16)") { $0.padding(.vertical, 16) }
      sample(".padding([.top, .trailing], 24)") {
        $0.padding([.top, .trailing], 24)
      }
    }
    .padding()
  }

  private func sample(
    _ label: String, pad: (Text) -> some View
  ) -> some View {
    pad(Text(label).font(.callout.monospaced()))
      .background(.mint.opacity(0.35))
  }
}

/// .offset moves where a view is DRAWN, not where layout put it, so
/// neighbours don't move. The dashed box marks the original spot.
struct OffsetDirections: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 28) {
      sample(".offset(x: 40)") { $0.offset(x: 40) }
      sample(".offset(x: -20)") { $0.offset(x: -20) }
      sample(".offset(y: 12)") { $0.offset(y: 12) }
      sample(".offset(y: -12)") { $0.offset(y: -12) }
      sample(".offset(x: 40, y: 12)") { $0.offset(x: 40, y: 12) }
    }
    .padding(.horizontal, 40)
    .padding(.vertical)
  }

  private func sample(
    _ label: String, move: (AnyView) -> some View
  ) -> some View {
    let chip = AnyView(
      Text(label).font(.callout.monospaced()).padding(6)
        .background(.orange.opacity(0.35)))
    return move(chip)
      .background(alignment: .topLeading) {
        // Drawn behind, at the position layout chose
        chip.hidden().overlay {
          Rectangle().stroke(.secondary, style: .init(dash: [4]))
        }
      }
  }
}

/// Two different alignments. The STACK's alignment lines its
/// children up with each other; the FRAME's alignment places the
/// whole stack inside the frame. A left-aligned block needs both.
struct StackVsFrameAlignment: View {
  var body: some View {
    VStack(spacing: 12) {
      card("VStack { }", stack: .center)  // default: centred lines
      card("VStack(alignment: .leading)", stack: .leading)
    }
    .padding()
  }

  private func card(_ name: String, stack: HorizontalAlignment)
    -> some View
  {
    VStack(alignment: stack) {
      Text("Morning run").font(.headline)
      Text("7 AM – 8 AM").font(.caption).foregroundStyle(.secondary)
      Text(name).font(.caption2.monospaced())
    }
    .padding(6)
    .frame(maxWidth: .infinity, alignment: .topLeading)
    .background(.blue.opacity(0.15))
  }
}
