import SwiftUI

/// The same five rows two ways. A stack (and a ScrollView's
/// content) puts default spacing between children.
struct RowGaps: View {
  var body: some View {
    HStack(alignment: .top, spacing: 24) {
      column("VStack { }") { VStack { rows } }
      column("spacing: 0") { VStack(spacing: 0) { rows } }
    }
    .padding()
  }

  private var rows: some View {
    ForEach(0..<5, id: \.self) { row($0) }
  }

  private func row(_ index: Int) -> some View {
    Text("Row \(index)")
      .frame(maxWidth: .infinity, minHeight: 36)
      .background(.blue.opacity(index.isMultiple(of: 2) ? 0.25 : 0.12))
  }

  private func column(
    _ title: String, @ViewBuilder content: () -> some View
  ) -> some View {
    VStack(spacing: 8) {
      Text(title).font(.caption.monospaced())
        .multilineTextAlignment(.center)
      content()
    }
  }
}

/// ScrollView essentials: lazy rows, pinned headers, jump to a row.
struct ScrollEssentials: View {
  let sections = ["Morning", "Afternoon"]

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        // Lazy: builds rows as they appear. Pinned: headers stick.
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
          ForEach(sections, id: \.self) { name in
            Section {
              ForEach(0..<20, id: \.self) { item in
                Text("\(name) \(item)")
                  .frame(maxWidth: .infinity, minHeight: 44)
                  .id("\(name)-\(item)")  // a target for scrollTo
              }
            } header: {
              Text(name).font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.bar)
            }
          }
        }
      }
      .scrollIndicators(.hidden)
      .contentMargins(.horizontal, 16, for: .scrollContent)
      .onAppear { proxy.scrollTo("Afternoon-0", anchor: .top) }
    }
  }
}

/// A horizontal strip that snaps to each card.
struct CardStrip: View {
  var body: some View {
    ScrollView(.horizontal) {
      LazyHStack(spacing: 12) {
        ForEach(1...6, id: \.self) { number in
          Text("Card \(number)")
            .frame(width: 140, height: 90)
            .background(.teal.opacity(0.3), in: .rect(cornerRadius: 12))
        }
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned)
    .contentMargins(.horizontal, 16, for: .scrollContent)
    .scrollIndicators(.hidden)
  }
}
