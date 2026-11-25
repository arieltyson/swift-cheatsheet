import SwiftUI

/// A month grid: 7 columns, blank cells before day 1, a dot under
/// days that have items, and arrows to change month.
struct MonthGrid: View {
  let daysWithItems: Set<Int>
  @State private var month: Date
  @State private var selected: Int?
  private let calendar = Calendar.current
  private let columns = Array(
    repeating: GridItem(.flexible()), count: 7)

  init(daysWithItems: Set<Int>, showing date: Date = .now) {
    self.daysWithItems = daysWithItems
    let start = Calendar.current.dateInterval(of: .month, for: date)!
    _month = State(initialValue: start.start)
  }

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Button("Previous", systemImage: "chevron.left") { move(-1) }
        Spacer()
        Text(month.formatted(.dateTime.month(.wide).year()))
          .font(.headline)
        Spacer()
        Button("Next", systemImage: "chevron.right") { move(1) }
      }
      .labelStyle(.iconOnly)
      // Headers in their own grid: their ids (0...6) would clash
      // with day numbers if they shared one ForEach container
      LazyVGrid(columns: columns) {
        ForEach(weekdaySymbols.indices, id: \.self) {
          Text(weekdaySymbols[$0])
            .font(.caption).foregroundStyle(.secondary)
        }
      }
      LazyVGrid(columns: columns, spacing: 8) {
        // Negative ids for blanks, so they never equal a day number
        ForEach(-blanks..<0, id: \.self) { _ in Color.clear }
        ForEach(1...days, id: \.self) { day in dayCell(day) }
      }
    }
    .padding()
  }

  // Symbols always start on Sunday; rotate them to the locale's
  // first weekday so headers match the blank cells
  private var weekdaySymbols: [String] {
    let symbols = calendar.veryShortWeekdaySymbols
    let shift = calendar.firstWeekday - 1
    return Array(symbols[shift...] + symbols[..<shift])
  }

  private var days: Int {
    calendar.range(of: .day, in: .month, for: month)!.count
  }
  private var blanks: Int {
    let weekday = calendar.component(.weekday, from: month)
    return (weekday - calendar.firstWeekday + 7) % 7
  }

  private func dayCell(_ day: Int) -> some View {
    Button {
      selected = day
    } label: {
      VStack(spacing: 2) {
        Text("\(day)")
          .frame(width: 32, height: 32)
          .background(selected == day ? Color.accentColor : .clear,
                      in: .circle)
          .foregroundStyle(selected == day ? .white : .primary)
        Circle().fill(daysWithItems.contains(day) ? .gray : .clear)
          .frame(width: 5, height: 5)
      }
    }
    .buttonStyle(.plain)
  }

  private func move(_ months: Int) {
    month = calendar.date(byAdding: .month, value: months, to: month)!
    selected = nil
  }
}

/// Previous, Today and Next for one day at a time. Keep items keyed
/// by day and show only those where
/// `calendar.isDate(item.day, inSameDayAs: day)`.
struct DayPager: View {
  @State private var day = Calendar.current.startOfDay(for: .now)
  private let calendar = Calendar.current

  var body: some View {
    HStack {
      Button("Previous day", systemImage: "chevron.left") { step(-1) }
      Spacer()
      Text(day.formatted(.dateTime.weekday(.wide).month().day()))
        .font(.headline)
      Spacer()
      Button("Next day", systemImage: "chevron.right") { step(1) }
    }
    .labelStyle(.iconOnly)
    .overlay(alignment: .bottom) {
      if !calendar.isDateInToday(day) {
        Button("Today") { day = calendar.startOfDay(for: .now) }
          .font(.caption)
          .offset(y: 24)
      }
    }
    .padding()
  }

  private func step(_ days: Int) {
    day = calendar.date(byAdding: .day, value: days, to: day)!
  }
}
