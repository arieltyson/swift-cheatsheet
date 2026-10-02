import UIKit

@MainActor
protocol TopicPickerDelegate: AnyObject {
  func topicPicker(_ picker: TopicPickerController, didSelect topic: String)
}

@MainActor
final class TopicPickerController: UIViewController {
  weak var delegate: (any TopicPickerDelegate)?

  func select(_ topic: String) {
    delegate?.topicPicker(self, didSelect: topic)
  }
}

@MainActor
final class PracticeCoordinator: TopicPickerDelegate {
  let picker = TopicPickerController()
  private(set) var selectedTopic: String?

  init() { picker.delegate = self }

  func topicPicker(_ picker: TopicPickerController, didSelect topic: String) {
    selectedTopic = topic
  }
}
