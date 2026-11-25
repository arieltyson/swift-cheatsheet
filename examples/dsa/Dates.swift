import Foundation

func demoDateMath() {
  // TimeInterval is a typealias for Double: a count of seconds
  let window: TimeInterval = 5
  let now = Date(timeIntervalSince1970: 1_000)
  // A negative interval moves back: five seconds before now
  let cutoff = now.addingTimeInterval(-window)
  assert(cutoff.timeIntervalSince1970 == 995)
  assert(cutoff == now - window)
  // The gap between two dates, in seconds
  assert(now.timeIntervalSince(cutoff) == 5)
  assert(cutoff < now)
}

func demoElapsedTime() {
  let clock = ContinuousClock()
  let start = clock.now
  let cutoff = start - .seconds(5)
  assert(start - cutoff == .seconds(5))
  assert(cutoff < start)
  assert(Duration.milliseconds(1500) == .seconds(1.5))
}

func demoCalendarDay() {
  // A fixed time zone gives the same answers on every machine
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: "UTC")!
  let day = Date(timeIntervalSince1970: 0)  // Thu 1 Jan 1970, 00:00
  let meeting = calendar.date(
    bySettingHour: 9, minute: 30, second: 0, of: day)!
  assert(calendar.startOfDay(for: meeting) == day)
  // Minutes since midnight: 9 * 60 + 30
  let parts = calendar.dateComponents([.hour, .minute], from: meeting)
  assert((parts.hour ?? 0) * 60 + (parts.minute ?? 0) == 570)
  assert(meeting.timeIntervalSince(day) / 60 == 570)
  // Add calendar units, not multiples of 86,400 seconds
  let next = calendar.date(byAdding: .day, value: 1, to: meeting)!
  assert(!calendar.isDate(next, inSameDayAs: meeting))
  assert(calendar.isDate(meeting, inSameDayAs: day))
  assert(calendar.component(.weekday, from: day) == 5)  // Sunday is 1
  assert(calendar.range(of: .day, in: .month, for: day)?.count == 31)
}

/// Hour labels and a date header. Hours run 0...23; a 12-hour clock
/// shows 0 and 12 as "12", so map hour % 12 == 0 to 12.
func demoDateLabels() {
  func label(_ hour: Int) -> String {
    let twelve = hour % 12 == 0 ? 12 : hour % 12
    return "\(twelve) \(hour < 12 ? "AM" : "PM")"
  }
  let hours = [0, 1, 11, 12, 13, 23].map(label)
  assert(hours == ["12 AM", "1 AM", "11 AM", "12 PM", "1 PM", "11 PM"])

  // Or let Foundation do it. In an app, the whole header is:
  //   Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())
  // .dateTime starts empty; each call adds one part. Here the locale
  // and time zone are fixed so the result is the same on any machine.
  let day = Date(timeIntervalSince1970: 0)  // Thu 1 Jan 1970, UTC
  let english = Locale(identifier: "en_US")
  var style = Date.FormatStyle.dateTime.locale(english)
  style.timeZone = TimeZone(identifier: "UTC")!
  let header = day.formatted(style.weekday(.wide).month(.wide).day())
  assert(header == "Thursday, January 1")
  assert(day.formatted(style.month(.abbreviated).day()) == "Jan 1")
  // Newer systems put a narrow no-break space before AM/PM
  let hour = day.formatted(style.hour())
  let plain = hour.replacingOccurrences(of: "\u{202F}", with: " ")
  assert(plain == "12 AM")
}

/// Minute precision: store minutes since midnight (0...1440), step
/// by 15, and format "h:mm AM". A range uses an en dash with spaces.
func demoQuarterHours() {
  let quarters = Array(stride(from: 0, through: 24 * 60, by: 15))
  assert(quarters.count == 97 && quarters[1] == 15)
  func label(_ minutes: Int) -> String {
    let (hour, minute) = (minutes / 60 % 24, minutes % 60)
    let twelve = hour % 12 == 0 ? 12 : hour % 12
    let period = hour < 12 ? "AM" : "PM"
    return minute == 0
      ? "\(twelve) \(period)"
      : "\(twelve):\(String(format: "%02d", minute)) \(period)"
  }
  assert(label(9 * 60 + 5) == "9:05 AM")
  assert(label(13 * 60) == "1 PM")
  assert(label(24 * 60) == "12 AM")  // midnight at the END of the day
  let range = "\(label(9 * 60)) – \(label(11 * 60 + 30))"
  assert(range == "9 AM – 11:30 AM")
  // Points from minutes, with 60 pt per hour: 1 pt per minute
  let hourHeight = 60.0
  assert(Double(9 * 60 + 30) / 60 * hourHeight == 570)
}

/// The numbers a month grid needs: how many days, and how many blank
/// cells before day 1 (Sunday-first weeks).
func demoMonthGrid() {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: "UTC")!
  calendar.firstWeekday = 1  // Sunday; the user's locale may differ
  let parts = DateComponents(year: 2026, month: 2, day: 10)
  let date = calendar.date(from: parts)!
  let monthStart = calendar.dateInterval(of: .month, for: date)!.start
  let days = calendar.range(of: .day, in: .month, for: date)!.count
  assert(days == 28)
  // weekday: 1 = Sunday ... 7 = Saturday
  let weekday = calendar.component(.weekday, from: monthStart)
  let blanks = (weekday - calendar.firstWeekday + 7) % 7
  assert(blanks == 0)  // 1 Feb 2026 is a Sunday
  let cells = blanks + days
  assert((cells + 6) / 7 == 4)  // rows needed
  // Next and previous month or day: add calendar units
  let next = calendar.date(byAdding: .month, value: 1, to: monthStart)!
  assert(calendar.component(.month, from: next) == 3)
}
