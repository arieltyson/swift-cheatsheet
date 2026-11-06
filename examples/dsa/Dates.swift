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
