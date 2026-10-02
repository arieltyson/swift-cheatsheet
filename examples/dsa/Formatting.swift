import Foundation

func formattingExample() -> [String] {
  let locale = Locale(identifier: "en_US")
  let count = 12_345.formatted(.number.locale(locale))
  let rate = 0.125.formatted(
    .percent.precision(.fractionLength(1)).locale(locale)
  )
  let signed = 42.formatted(
    .number.sign(strategy: .always()).locale(locale)
  )
  let fixed = 3.5.formatted(
    .number.precision(.fractionLength(2))
      .grouping(.never).locale(locale)
  )
  let digits = String(42)
  let padded = String(repeating: "0", count: max(0, 5 - digits.count)) + digits
  let hexadecimal = String(255, radix: 16, uppercase: true)
  let message = "Processed \(count) items; success \(rate)."
  return [count, rate, signed, fixed, padded, hexadecimal, message]
}
