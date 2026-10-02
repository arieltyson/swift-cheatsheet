import Combine

func demoSubjects() {
  // Passthrough: no current value. CurrentValue: always has one.
  let taps = PassthroughSubject<String, Never>()
  let score = CurrentValueSubject<Int, Never>(0)
  var received: [String] = []
  let subscription = taps.sink { received.append($0) }
  taps.send("tap")
  assert(received == ["tap"])
  score.send(3)
  assert(score.value == 3)
  subscription.cancel()
  taps.send("ignored")
  assert(received == ["tap"])
}

func demoCancellables() {
  let ticks = PassthroughSubject<Int, Never>()
  var cancellables = Set<AnyCancellable>()
  var seen: [Int] = []
  // Discarding the AnyCancellable ends the subscription at once
  _ = ticks.sink { seen.append($0) }
  ticks.sink { seen.append($0 * 10) }.store(in: &cancellables)
  ticks.send(1)
  assert(seen == [10])
}

func demoOperators() {
  var output: [[Int]] = []
  let subscription = [1, 2, 2, 3, 4].publisher
    .removeDuplicates()
    .filter { $0 % 2 == 1 }
    .map { $0 * 10 }
    .collect()
    .sink { output.append($0) }
  assert(output == [[10, 30]])
  subscription.cancel()
}

func demoErrorHandling() {
  var values: [Int] = []
  let subscription = ["1", "x", "3"].publisher
    .tryMap { text -> Int in
      guard let value = Int(text) else { throw FetchError.notFound }
      return value
    }
    .catch { _ in Just(-1) }
    .sink { values.append($0) }
  // The first error ends the stream; catch replaces the rest
  assert(values == [1, -1])
  subscription.cancel()
}

/// Wraps the callback request in a publisher that starts on subscribe.
func pagePublisher(_ number: Int) -> AnyPublisher<[String], Never> {
  Deferred {
    Future { promise in
      // Promise is not Sendable; it is called once, from one callback
      nonisolated(unsafe) let promise = promise
      requestPage(number) { promise(.success($0)) }
    }
  }
  .eraseToAnyPublisher()
}

/// Requests every page in parallel; emits one array in page order.
func pagesPublisher(_ numbers: [Int]) -> AnyPublisher<[String], Never> {
  Publishers.MergeMany(
    numbers.map { number in
      pagePublisher(number).map { (number, $0) }
    }
  )
  .collect()
  .map { pairs in pairs.sorted { $0.0 < $1.0 }.flatMap(\.1) }
  .eraseToAnyPublisher()
}
