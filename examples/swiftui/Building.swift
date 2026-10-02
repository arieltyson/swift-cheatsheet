import SwiftUI

/// An n x n board of tappable, square cells.
struct BoardGridView: View {
  let size: Int
  let marks: [String?]
  let onTap: (Int) -> Void

  private var columns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: 0), count: size)
  }

  var body: some View {
    LazyVGrid(columns: columns, spacing: 0) {
      ForEach(marks.indices, id: \.self) { index in
        Button {
          onTap(index)
        } label: {
          Text(marks[index] ?? " ")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .border(.secondary.opacity(0.4), width: 0.5)
        .disabled(marks[index] != nil)
        .accessibilityLabel(cellLabel(index))
      }
    }
    .aspectRatio(1, contentMode: .fit)
  }

  private func cellLabel(_ index: Int) -> String {
    let position = "Row \(index / size + 1), column \(index % size + 1)"
    return "\(position), \(marks[index] ?? "empty")"
  }
}

/// Switches between a setup screen and a game screen.
struct GameRootView: View {
  enum Screen { case setup, game }

  @State private var screen = Screen.setup
  @State private var size = 3

  var body: some View {
    Group {
      switch screen {
      case .setup:
        VStack(spacing: 24) {
          Stepper("Board: \(size) x \(size)", value: $size, in: 3...10)
          Button("Start") { withAnimation { screen = .game } }
            .buttonStyle(.borderedProminent)
        }
        .transition(.opacity)
      case .game:
        VStack(spacing: 16) {
          let empty = [String?](repeating: nil, count: size * size)
          BoardGridView(size: size, marks: empty) { _ in }
          Button("Reset") { withAnimation { screen = .setup } }
        }
        .transition(.opacity)
      }
    }
    .padding()
  }
}

/// The turn line and the undo button below a board.
struct TurnFooter: View {
  let player: String
  let canUndo: Bool
  let undo: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      // Interpolate a styled Text; Text + Text is deprecated in iOS 26
      Text("Next turn: \(Text(player).bold())")
        .font(.title3)
      Button("Undo", action: undo)
        .disabled(!canUndo)
    }
  }
}

#Preview("Turn footer") {
  TurnFooter(player: "X", canUndo: false) {}
}
