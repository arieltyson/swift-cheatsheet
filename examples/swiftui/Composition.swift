import SwiftUI

/// 1. Everything inline: one body, read top to bottom. Best for small
/// screens and interviews, where the reader follows one flow.
struct ReceiptInline: View {
  let merchant: String
  let cents: Int
  let isRefund: Bool

  var body: some View {
    VStack(alignment: .leading) {
      Text(merchant).font(.headline)
      Text(Decimal(cents) / 100, format: .currency(code: "USD"))
      if isRefund {
        Text("Refund").foregroundStyle(.green)
      }
    }
  }
}

/// 2. A computed view property and a @ViewBuilder helper split the body
/// inside the same type. They share its state with no parameters.
struct ReceiptSplit: View {
  let merchant: String
  let cents: Int
  let isRefund: Bool

  var body: some View {
    VStack(alignment: .leading) {
      title
      badge(isRefund)
    }
  }

  private var title: some View {
    Text(merchant).font(.headline)
  }

  // @ViewBuilder lets an if (or switch) return different views
  // without wrapping them in a Group or AnyView
  @ViewBuilder
  private func badge(_ refund: Bool) -> some View {
    if refund {
      Text("Refund").foregroundStyle(.green)
    } else {
      Text(Decimal(cents) / 100, format: .currency(code: "USD"))
    }
  }
}

/// 3. An extracted subview: its own struct, reusable on any screen,
/// with its own inputs, previews and (if needed) its own @State.
struct AmountLabel: View {
  let cents: Int

  var body: some View {
    Text(Decimal(cents) / 100, format: .currency(code: "USD"))
      .monospacedDigit()
  }
}

/// 4. A container that takes views from its caller, like VStack does.
struct Panel<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 4) { content }
      .padding()
      .background(.quaternary, in: .rect(cornerRadius: 12))
  }
}

struct ReceiptCardScreen: View {
  var body: some View {
    Panel {
      Text("Cafe").font(.headline)
      AmountLabel(cents: 450)
    }
  }
}
