import Foundation

func demoMoney() {
  let usd = Locale(identifier: "en_US")
  let amount: Decimal = 1234.5
  let style = Decimal.FormatStyle.Currency(code: "USD").locale(usd)
  assert(amount.formatted(style) == "$1,234.50")
  assert(Decimal(0.5).formatted(style) == "$0.50")
  // The sign goes before the dollar sign
  assert(Decimal(-42.5).formatted(style) == "-$42.50")
  let canada = Decimal.FormatStyle.Currency(code: "CAD")
    .locale(Locale(identifier: "en_CA"))
  assert(amount.formatted(canada) == "$1,234.50")
}

func demoCents() {
  // Doubles cannot store 0.1 exactly: keep money in integer cents
  assert(0.1 + 0.2 != 0.3)
  assert(abs(0.1 + 0.2 - 0.3) < .ulpOfOne)
  let totalCents = 1999 * 3
  let (dollars, cents) = totalCents.quotientAndRemainder(
    dividingBy: 100)
  assert((dollars, cents) == (59, 97))
  let style = Decimal.FormatStyle.Currency(code: "USD")
    .locale(Locale(identifier: "en_US"))
  assert((Decimal(totalCents) / 100).formatted(style) == "$59.97")
  // Decimal from a string is exact; Decimal(19.99) goes through Double
  let price = Decimal(string: "19.99")!
  assert(price * 3 == Decimal(string: "59.97")!)
}

func demoNumberFormats() {
  let us = Locale(identifier: "en_US")
  let twoPlaces = FloatingPointFormatStyle<Double>.number
    .precision(.fractionLength(2)).locale(us)
  assert(3.14159.formatted(twoPlaces) == "3.14")
  assert(1_234_567.formatted(.number.locale(us)) == "1,234,567")
  let percent = FloatingPointFormatStyle<Double>.Percent()
    .precision(.fractionLength(1)).locale(us)
  assert(0.256.formatted(percent) == "25.6%")
  let plain = IntegerFormatStyle<Int>.number.grouping(.never)
  assert(1_234_567.formatted(plain.locale(us)) == "1234567")
}

func demoPaddingAndRadix() {
  let name = "ada"
  let padded = name + String(repeating: " ", count: 6 - name.count)
  assert(padded + "|" == "ada   |")
  let digits = String(7)
  let zeroPadded =
    String(repeating: "0", count: 3 - digits.count) + digits
  assert(zeroPadded == "007")
  assert(String(10, radix: 2) == "1010")
  assert(String(255, radix: 16) == "ff")
  assert(Int("1011", radix: 2) == 11)
  assert(Int("ff", radix: 16) == 255)
}

func demoRounding() {
  // rounded() rounds half away from zero
  assert((2.5).rounded() == 3)
  assert((-2.5).rounded() == -3)
  assert((2.5).rounded(.toNearestOrEven) == 2)
  assert((2.7).rounded(.down) == 2)
  assert((2.1).rounded(.up) == 3)
  assert(Int(-2.9) == -2)
  assert((1234.5678 * 100).rounded() / 100 == 1234.57)
}
