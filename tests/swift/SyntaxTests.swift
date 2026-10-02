import Foundation
import Testing

@testable import InterviewExamples

@Test func syntaxAndValueSemantics() {
  #expect(firstMatch([2, 3, 2], target: 2) == .found(index: 0))
  #expect(firstMatch([Int](), target: 2) == .missing)
  #expect(languageExample().label == "Answer: 42")
  #expect(languageExample().score == 4)
  let original = [1, 2, 3]
  var copy = original
  copy[0] = 9
  #expect(original == [1, 2, 3])
  let box = ScoreBox()
  let alias = box
  alias.value = 7
  #expect(box.value == 7)
}

@Test func collectionsAndUnicode() {
  let result = collectionExample()
  #expect(result.counts == ["swift": 2, "code": 1])
  #expect(result.unique == [2, 3, 4, 5])
  #expect(result.total == 24)
  let text = stringExample()
  #expect(text.count == 3)
  #expect(text.character == "👨‍👩‍👧‍👦")
  #expect(text.joined == "  swift / code / repeat ")
  let slice = [0, 1, 2, 3][2...]
  #expect(slice.startIndex == 2)
  #expect(Array(slice).startIndex == 0)
}

@Test func mathBoundaries() {
  #expect(greatestCommonDivisor(54, 24) == 6)
  #expect(greatestCommonDivisor(0, 0) == 0)
  #expect(greatestCommonDivisor(UInt.max, 1) == 1)
  let result = numberExample()
  #expect(result.quotient == -2)
  #expect(result.remainder == -1)
  #expect(result.rounded == 2)
}

@Test func explicitMoneyAndNumberFormatting() {
  #expect(currencyFromCents(1_999) == "$19.99")
  #expect(currencyFromCents(-1) == "-$0.01")
  #expect(currencyFromCents(0) == "$0.00")
  #expect(
    currencyFromCents(1_999, currencyCode: "CAD", locale: Locale(identifier: "en_CA")) == "$19.99")
  #expect(decimalExample() == Decimal(string: "59.97"))
  #expect(
    formattingExample() == [
      "12,345", "12.5%", "+42", "3.50", "00042", "FF", "Processed 12,345 items; success 12.5%.",
    ])
}
