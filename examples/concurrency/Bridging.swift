import Dispatch

/// An older callback API: delivers a page later on a background queue.
func requestPage(
  _ number: Int,
  completion: @escaping @Sendable ([String]) -> Void
) {
  let delay = Double.random(in: 0.01...0.05)
  DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
    completion((1...4).map { "page \(number) item \($0)" })
  }
}

/// Wraps the callback API so callers can `await` it.
func page(_ number: Int) async -> [String] {
  await withCheckedContinuation { continuation in
    requestPage(number) { items in
      continuation.resume(returning: items)
    }
  }
}

/// Emits a countdown, then finishes.
func countdown(from start: Int) -> AsyncStream<Int> {
  let (stream, continuation) = AsyncStream.makeStream(of: Int.self)
  Task {
    for value in stride(from: start, through: 0, by: -1) {
      continuation.yield(value)
    }
    continuation.finish()
  }
  return stream
}

func demoAsyncStream() async {
  var values: [Int] = []
  for await value in countdown(from: 3) {
    values.append(value)
  }
  assert(values == [3, 2, 1, 0])
}
