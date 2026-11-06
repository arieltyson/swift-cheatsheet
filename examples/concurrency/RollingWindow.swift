import Foundation

struct TimedValue: Sendable {
  let timestamp: Date
  let value: Double
}

/// Keeps only the values from the last `duration` seconds.
actor RollingWindow {
  private var items: [TimedValue] = []
  private var head = 0
  private let duration: TimeInterval

  init(duration: TimeInterval) {
    self.duration = duration
  }

  var count: Int { items.count - head }

  func append(_ item: TimedValue) {
    items.append(item)
    let cutoff = item.timestamp.addingTimeInterval(-duration)
    // Moving head is O(1); removeFirst() would shift every item
    while head < items.count, items[head].timestamp < cutoff {
      head += 1
    }
    // Drop the used half now and then so memory stays O(n)
    if head * 2 >= items.count {
      items.removeFirst(head)
      head = 0
    }
  }

  func hasValue(atLeast threshold: Double) -> Bool {
    items[head...].contains { $0.value >= threshold }
  }
}

/// Same window, but reads the largest value in O(1).
actor RollingMax {
  // Values strictly decrease from head to end
  private var candidates: [TimedValue] = []
  private var head = 0
  private let duration: TimeInterval

  init(duration: TimeInterval) {
    self.duration = duration
  }

  var peak: Double? {
    head < candidates.count ? candidates[head].value : nil
  }

  func append(_ item: TimedValue) {
    // A smaller, older value can never be the largest again
    while candidates.count > head,
      candidates[candidates.count - 1].value <= item.value
    {
      candidates.removeLast()
    }
    candidates.append(item)
    let cutoff = item.timestamp.addingTimeInterval(-duration)
    while head < candidates.count,
      candidates[head].timestamp < cutoff
    {
      head += 1
    }
    if head * 2 >= candidates.count {
      candidates.removeFirst(head)
      head = 0
    }
  }
}

/// One loop, so values reach the actor in the order they arrived.
func drain(
  _ stream: AsyncStream<TimedValue>,
  into window: RollingWindow
) async {
  for await item in stream {
    await window.append(item)
  }
}

func demoRollingWindow() async {
  let (stream, input) = AsyncStream.makeStream(
    of: TimedValue.self, bufferingPolicy: .bufferingNewest(256))
  let start = Date(timeIntervalSince1970: 0)
  // A callback cannot await, but it can always yield
  input.yield(TimedValue(timestamp: start, value: 5))
  input.yield(TimedValue(timestamp: start + 4, value: 1))
  input.yield(TimedValue(timestamp: start + 6, value: 2))
  input.finish()

  let window = RollingWindow(duration: 5)
  await drain(stream, into: window)
  // At 6 seconds the cutoff is 1 second, so the first value is gone
  let count = await window.count
  assert(count == 2)
  let hasFive = await window.hasValue(atLeast: 5)
  assert(hasFive == false)
  let hasTwo = await window.hasValue(atLeast: 2)
  assert(hasTwo == true)
}

func demoRollingMax() async {
  let start = Date(timeIntervalSince1970: 0)
  let window = RollingMax(duration: 5)
  await window.append(TimedValue(timestamp: start, value: 5))
  await window.append(TimedValue(timestamp: start + 4, value: 1))
  let before = await window.peak
  assert(before == 5)
  await window.append(TimedValue(timestamp: start + 6, value: 2))
  let after = await window.peak
  assert(after == 2)
}
