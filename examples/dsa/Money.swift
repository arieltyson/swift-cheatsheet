import Foundation

func currencyFromCents(
  _ cents: Int,
  currencyCode: String = "USD",
  locale: Locale = Locale(identifier: "en_US")
) -> String {
  let amount = Decimal(cents) / 100
  return amount.formatted(
    .currency(code: currencyCode)
      .locale(locale)
      .precision(.fractionLength(2))
  )
}

func decimalExample() -> Decimal? {
  guard
    let unitPrice = Decimal(
      string: "19.99", locale: Locale(identifier: "en_US_POSIX")
    )
  else {
    return nil
  }
  return unitPrice * 3
}
