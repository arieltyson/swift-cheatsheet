import SwiftUI
import UIKit

@main
@MainActor
struct NativeFixtureApp: App {
  var body: some Scene {
    WindowGroup { FixtureScreen() }
  }
}

@MainActor
struct FixtureScreen: View {
  @State private var completed = false

  var body: some View {
    TabView {
      CounterScreen().tabItem { Label("State", systemImage: "number") }
      SessionScreen().tabItem { Label("Model", systemImage: "pencil") }
      TopicsScreen().tabItem { Label("Topics", systemImage: "list.bullet") }
      TopicSearchScreen().tabItem { Label("Search", systemImage: "magnifyingglass") }
    }
    .task {
      guard !completed else { return }
      completed = true
      await runNativeChecks()
    }
  }
}

@MainActor
func runNativeChecks() async {
  var results: [String: Bool] = [:]
  let session = StudySession()
  session.completed = true
  results["observationModel"] = session.completed && session.topic == "Binary search"
  let legacy = LegacyCounter()
  legacy.count += 1
  results["legacyModel"] = legacy.count == 1
  let topic = StudyTopic(id: 2, title: "Heaps")
  results["stableIdentity"] = topic.id == 2 && Set([topic, topic]).count == 1

  let lifecycle = LifecycleController()
  lifecycle.loadViewIfNeeded()
  lifecycle.loadViewIfNeeded()
  results["lifecycleSetup"] =
    lifecycle.view.subviews.count == 1 && lifecycle.statusLabel.text == "Ready"
  lifecycle.beginAppearanceTransition(true, animated: false)
  lifecycle.endAppearanceTransition()
  results["appearanceCallback"] = lifecycle.statusLabel.text == "Visible soon"

  let panel = RoundedPanel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
  panel.setNeedsLayout()
  panel.layoutIfNeeded()
  results["layoutGeometry"] = panel.layer.cornerRadius == 5

  let profile = ProfileController()
  profile.loadViewIfNeeded()
  profile.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
  profile.view.setNeedsLayout()
  profile.view.layoutIfNeeded()
  results["layoutPriorities"] =
    profile.titleLabel.contentHuggingPriority(for: .horizontal)
    > profile.nameField.contentHuggingPriority(for: .horizontal)
  results["layoutFrames"] =
    profile.nameField.bounds.width > profile.titleLabel.bounds.width
    && !profile.nameField.hasAmbiguousLayout

  let topics = TopicsController()
  topics.loadViewIfNeeded()
  topics.renameTopic(id: 2, title: "Priority queues")
  topics.renameTopic(id: 99, title: "Ignored")
  results["diffableSnapshot"] = topics.collectionView?.numberOfItems(inSection: 0) == 2

  var coordinator: PracticeCoordinator? = PracticeCoordinator()
  let picker = coordinator?.picker
  picker?.select("Heaps")
  results["delegateCallback"] = coordinator?.selectedTopic == "Heaps"
  coordinator = nil
  results["delegateLifetime"] = picker?.delegate == nil

  let navigationRoot = NavigationExampleController()
  let navigation = UINavigationController(rootViewController: navigationRoot)
  navigationRoot.pushDetail()
  results["navigationPush"] = navigation.viewControllers.count == 2
  let hosting = HostingExampleController()
  hosting.loadViewIfNeeded()
  results["hostingContainment"] =
    hosting.children.count == 1
    && hosting.children.first?.parent === hosting

  let hostedViews: [AnyView] = [
    AnyView(CounterScreen()), AnyView(SessionScreen()), AnyView(TopicsScreen()),
    AnyView(ReviewSummary(completed: 3, review: {})), AnyView(TopicSearchScreen()),
    AnyView(LegacyOwner()), AnyView(ActivityIndicator(isAnimating: true)),
  ]
  for (index, rootView) in hostedViews.enumerated() {
    let host = UIHostingController(rootView: rootView)
    host.loadViewIfNeeded()
    host.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    host.view.setNeedsLayout()
    host.view.layoutIfNeeded()
    results["swiftuiMount\(index)"] = !host.view.bounds.isEmpty
  }

  let cell = ThumbnailCell(style: .default, reuseIdentifier: "Thumbnail")
  let freshImage = UIImage(systemName: "checkmark") ?? UIImage()
  let staleImage = UIImage(systemName: "xmark") ?? UIImage()
  var continuation: CheckedContinuation<UIImage, Never>?
  cell.configure(id: 1) {
    await withCheckedContinuation { continuation = $0 }
  }
  for _ in 0..<20 where continuation == nil { await Task.yield() }
  results["imageLoaderStarted"] = continuation != nil
  cell.configure(id: 1) { freshImage }
  for _ in 0..<20 { await Task.yield() }
  continuation?.resume(returning: staleImage)
  for _ in 0..<20 { await Task.yield() }
  let content = cell.contentConfiguration as? UIListContentConfiguration
  results["sameIDStaleResultRejected"] = content?.image === freshImage
  cell.prepareForReuse()
  results["reuseReset"] = cell.contentConfiguration == nil

  let destination = URL.documentsDirectory.appending(path: "native-results.json")
  do {
    let data = try JSONSerialization.data(
      withJSONObject: results, options: [.sortedKeys, .prettyPrinted])
    try data.write(to: destination, options: .atomic)
  } catch {
    fatalError("Unable to write native test results: \(error)")
  }
}
