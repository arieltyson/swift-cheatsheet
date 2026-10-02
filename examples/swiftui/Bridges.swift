import SwiftUI
import UIKit

@MainActor
struct ActivityIndicator: UIViewRepresentable {
  var isAnimating: Bool

  func makeUIView(context: Context) -> UIActivityIndicatorView {
    UIActivityIndicatorView(style: .medium)
  }

  func updateUIView(_ view: UIActivityIndicatorView, context: Context) {
    if isAnimating { view.startAnimating() } else { view.stopAnimating() }
  }
}

@MainActor
struct ShareSheet: UIViewControllerRepresentable {
  let text: String

  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: [text], applicationActivities: nil)
  }

  func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
