final class Trie {
  private final class Node {
    var children: [Character: Node] = [:]
    var isWord = false
  }

  private let root = Node()

  func insert(_ word: String) {
    var node = root
    for char in word {
      if let child = node.children[char] {
        node = child
      } else {
        let child = Node()
        node.children[char] = child
        node = child
      }
    }
    node.isWord = true
  }

  func search(_ word: String) -> Bool {
    walk(word)?.isWord ?? false
  }

  func startsWith(_ prefix: String) -> Bool {
    walk(prefix) != nil
  }

  private func walk(_ prefix: String) -> Node? {
    var node = root
    for char in prefix {
      guard let child = node.children[char] else { return nil }
      node = child
    }
    return node
  }
}

func demoTrie() {
  let words = Trie()
  words.insert("apple")
  assert(words.search("apple") == true)
  assert(words.search("app") == false)
  assert(words.startsWith("app") == true)
  words.insert("app")
  assert(words.search("app") == true)
}
