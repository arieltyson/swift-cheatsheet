import UIKit

@MainActor
final class LifecycleController: UIViewController {
  let statusLabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    statusLabel.text = "Ready"
    statusLabel.font = .preferredFont(forTextStyle: .body)
    statusLabel.adjustsFontForContentSizeCategory = true
    statusLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(statusLabel)
    NSLayoutConstraint.activate([
      statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    statusLabel.text = "Visible soon"
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    statusLabel.preferredMaxLayoutWidth = view.bounds.width - 32
  }
}

@MainActor
final class RoundedPanel: UIView {
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = min(bounds.width, bounds.height) * 0.1
  }
}
