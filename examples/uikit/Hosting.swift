import SwiftUI
import UIKit

final class HostingExampleController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let host = UIHostingController(
      rootView: Text("SwiftUI inside UIKit").padding())
    addChild(host)
    host.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(host.view)
    NSLayoutConstraint.activate([
      host.view.leadingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      host.view.trailingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      host.view.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor),
      host.view.bottomAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    host.didMove(toParent: self)
  }
}
