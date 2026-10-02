import UIKit

final class NavigationExampleController: UIViewController {
  func pushDetail() {
    let detail = UIViewController()
    detail.title = "Detail"
    detail.view.backgroundColor = .systemBackground
    navigationController?.pushViewController(detail, animated: true)
  }

  func presentReview() {
    let review = UIViewController()
    review.title = "Review"
    review.view.backgroundColor = .systemBackground
    review.navigationItem.rightBarButtonItem = UIBarButtonItem(
      systemItem: .done,
      primaryAction: UIAction { [weak review] _ in
        review?.dismiss(animated: true)
      }
    )
    let navigation = UINavigationController(rootViewController: review)
    navigation.modalPresentationStyle = .pageSheet
    navigation.sheetPresentationController?.detents = [
      .medium(), .large(),
    ]
    present(navigation, animated: true)
  }
}
