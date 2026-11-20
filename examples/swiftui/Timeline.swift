import SwiftUI

/// Places blocks on a scrolling day by their minutes since midnight.
struct DayTimeline: View {
  struct Block: Identifiable {
    let id: Int
    let title: String
    let startMinute: Int
    let endMinute: Int
    // From assignColumns, so overlapping blocks sit side by side
    var column = 0
    var columnCount = 1
  }

  let blocks: [Block]
  let hourHeight: CGFloat = 60  // 1 point per minute
  let gutter: CGFloat = 52

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        // Top leading: every child starts at minute 0, left edge
        ZStack(alignment: .topLeading) {
          hourRows
          GeometryReader { geometry in
            let width = geometry.size.width - gutter
            ForEach(blocks) { block in
              blockView(block, width: width)
            }
          }
          nowLine
        }
        .frame(height: hourHeight * 24)
      }
      .onAppear { proxy.scrollTo(8, anchor: .top) }
    }
  }

  private var hourRows: some View {
    // Zero spacing keeps every row exactly hourHeight tall
    VStack(spacing: 0) {
      ForEach(0..<24, id: \.self) { hour in
        HStack(alignment: .top) {
          Text("\(hour):00")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(width: gutter - 8, alignment: .trailing)
          Rectangle().fill(.quaternary).frame(height: 1)
        }
        .frame(height: hourHeight, alignment: .top)
        .id(hour)
      }
    }
  }

  private func blockView(_ block: Block, width: CGFloat) -> some View {
    let columnWidth = width / CGFloat(block.columnCount)
    let minutes = block.endMinute - block.startMinute
    return Text(block.title)
      .font(.caption)
      .padding(4)
      .frame(
        width: columnWidth - 2, height: max(y(minutes), 20),
        alignment: .topLeading
      )
      .background(.blue.opacity(0.25), in: .rect(cornerRadius: 6))
      // offset moves where it draws, not where layout puts it
      .offset(
        x: gutter + columnWidth * CGFloat(block.column),
        y: y(block.startMinute))
  }

  private var nowLine: some View {
    // Redraws its content once a minute, no Timer needed
    TimelineView(.everyMinute) { context in
      let parts = Calendar.current.dateComponents(
        [.hour, .minute], from: context.date)
      let minute = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
      Rectangle()
        .fill(.red)
        .frame(height: 2)
        .padding(.leading, gutter)
        .offset(y: y(minute))
    }
  }

  private func y(_ minute: Int) -> CGFloat {
    CGFloat(minute) / 60 * hourHeight
  }
}
