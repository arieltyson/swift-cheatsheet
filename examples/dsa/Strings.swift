func stringExample() -> (count: Int, character: Character, joined: String) {
    let text = "A👨‍👩‍👧‍👦é"
    let characters = Array(text)
    let secondIndex = text.index(after: text.startIndex)
    let second = text[secondIndex]
    let prefix = text[..<secondIndex]
    let ownedPrefix = String(prefix)
    let words = "  swift,code,,repeat ".split(separator: ",")
    let joined = words.map(String.init).joined(separator: " / ")
    let asciiBytes = Array("swift".utf8)
    precondition(asciiBytes[0] == 115)
    precondition(ownedPrefix == "A")
    precondition(characters[1] == second)
    return (text.count, second, joined)
}
