final class Downloader {
  var onFinish: (() -> Void)?
  private(set) var finished = false

  func start() {
    // [weak self]: a stored closure must not keep its owner alive
    onFinish = { [weak self] in self?.finished = true }
  }
}

final class LeakyDownloader {
  var onFinish: (() -> Void)?
  private(set) var finished = false

  func start() {
    // Strong self: self -> onFinish -> self, a retain cycle
    onFinish = { self.finished = true }
  }
}

func demoRetainCycles() {
  weak var freed: Downloader?
  weak var leaked: LeakyDownloader?
  do {
    let downloader = Downloader()
    downloader.start()
    freed = downloader
    let leaky = LeakyDownloader()
    leaky.start()
    leaked = leaky
  }
  assert(freed == nil)
  assert(leaked != nil)
  // Break a cycle by clearing the closure
  leaked?.onFinish = nil
  assert(leaked == nil)
}

/// Repeats work every interval until stopped or deallocated.
@MainActor
final class Ticker {
  private(set) var ticks = 0
  private var loop: Task<Void, Never>?

  func start(every interval: Duration) {
    loop = Task { [weak self] in
      // Sleep throws once cancelled, which ends the loop
      while (try? await Task.sleep(for: interval)) != nil {
        // Stopped, or owner gone: end instead of ticking forever
        guard let self, !Task.isCancelled else { return }
        self.ticks += 1
      }
    }
  }

  func stop() {
    loop?.cancel()
    loop = nil
  }
}
