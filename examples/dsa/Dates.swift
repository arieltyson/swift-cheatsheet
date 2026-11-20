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
