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

  // Or let Foundation format it. In an app, skip .locale and
  // .timeZone so the user's settings apply.
  let day = Date(timeIntervalSince1970: 0)  // Thu 1 Jan 1970, UTC
  let style = Date.FormatStyle(timeZone: TimeZone(identifier: "UTC")!)
    .locale(Locale(identifier: "en_US"))
  let header = day.formatted(style.weekday(.wide).month(.wide).day())
  assert(header == "Thursday, January 1")
  // Newer systems put a narrow no-break space before AM/PM
  let hour = day.formatted(style.hour())
  let plain = hour.replacingOccurrences(of: "\u{202F}", with: " ")
  assert(plain == "12 AM")
}
