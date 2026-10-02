func demoStringBasics() {
  let text = "Interview"
  assert(text.count == 9)
  assert(text.lowercased() == "interview")
  assert(text.hasPrefix("Inter"))
  assert(text.contains("view"))
  assert(text.first == "I")
  assert(String(text.reversed()) == "weivretnI")
  assert(text.replacing("view", with: "act") == "Interact")
  let csv = "red,green,,blue"
  assert(csv.split(separator: ",").map(String.init).count == 3)
  let all = csv.split(separator: ",", omittingEmptySubsequences: false)
  assert(all.count == 4)
  assert(["a", "b"].joined(separator: "-") == "a-b")
}

func demoStringIndexing() {
  let text = "swift"
  // Strings have no Int subscript; use String.Index
  let second = text[text.index(text.startIndex, offsetBy: 1)]
  assert(second == "w")
  let start = text.index(text.startIndex, offsetBy: 1)
  let end = text.index(text.startIndex, offsetBy: 3)
  assert(text[start..<end] == "wi")
  // For many random reads, convert once: O(n), then O(1) per read
  let characters = Array(text)
  assert(characters[4] == "t")
  assert(String(characters[1...3]) == "wif")
}

func demoCharacters() {
  let char: Character = "a"
  assert(char.isLetter)
  assert(Character("7").isNumber)
  assert(Character("7").wholeNumberValue == 7)
  assert(char.asciiValue == 97)
  assert(Character(UnicodeScalar(98)) == "b")
  assert(Character("A").isUppercase)
  assert(Character(" ").isWhitespace)
  assert("Ab3".allSatisfy { $0.isLetter || $0.isNumber })
}

func demoBuildStrings() {
  var built = ""
  for word in ["fast", "join"] {
    built += word.uppercased()
  }
  assert(built == "FASTJOIN")
  let name = "ada"
  let count = 3
  assert("\(name) has \(count) items" == "ada has 3 items")
  assert(String(repeating: "ab", count: 3) == "ababab")
  let cleaned = "A man, a plan!".lowercased().filter {
    $0.isLetter || $0.isNumber
  }
  assert(cleaned == "amanaplan")
}

func demoLetterCounts() {
  var counts = Array(repeating: 0, count: 26)
  let base = Character("a").asciiValue!
  for char in "abca" {
    counts[Int(char.asciiValue! - base)] += 1
  }
  assert(Array(counts.prefix(3)) == [2, 1, 1])
  // Sorted letters are a key shared by all anagrams
  assert(String("listen".sorted()) == "eilnst")
}
