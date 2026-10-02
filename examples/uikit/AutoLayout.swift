import UIKit

final class ProfileController: UIViewController {
  let titleLabel = UILabel()
  let nameField = UITextField()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    titleLabel.text = "Name"
    titleLabel.font = .preferredFont(forTextStyle: .body)
    titleLabel.adjustsFontForContentSizeCategory = true
    nameField.placeholder = "Ariel"
    nameField.accessibilityLabel = "Name"
    nameField.font = .preferredFont(forTextStyle: .body)
    nameField.adjustsFontForContentSizeCategory = true
    nameField.borderStyle = .roundedRect
    titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    titleLabel.setContentCompressionResistancePriority(
      .required, for: .horizontal)
    nameField.setContentHuggingPriority(.defaultLow, for: .horizontal)
    let row = UIStackView(arrangedSubviews: [titleLabel, nameField])
    row.spacing = 12
    row.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(row)
    let safeArea = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      row.leadingAnchor.constraint(
        equalTo: safeArea.leadingAnchor, constant: 16),
      row.trailingAnchor.constraint(
        equalTo: safeArea.trailingAnchor, constant: -16),
      row.topAnchor.constraint(
        equalTo: safeArea.topAnchor, constant: 16),
    ])
  }
}
