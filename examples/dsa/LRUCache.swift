/// Least recently used cache: get and put in O(1).
/// A dictionary finds nodes; a linked list keeps them by recency.
final class LRUCache<Key: Hashable, Value> {
  private final class Node {
    let key: Key
    var value: Value
    weak var newer: Node?
    var older: Node?

    init(key: Key, value: Value) {
      self.key = key
      self.value = value
    }
  }

  private let capacity: Int
  private var nodes: [Key: Node] = [:]
  private var newest: Node?
  private var oldest: Node?

  init(capacity: Int) {
    self.capacity = max(1, capacity)
  }

  var count: Int { nodes.count }

  func get(_ key: Key) -> Value? {
    guard let node = nodes[key] else { return nil }
    moveToFront(node)
    return node.value
  }

  func put(_ key: Key, _ value: Value) {
    if let node = nodes[key] {
      node.value = value
      moveToFront(node)
      return
    }
    if nodes.count == capacity, let evicted = oldest {
      unlink(evicted)
      nodes[evicted.key] = nil
    }
    let node = Node(key: key, value: value)
    nodes[key] = node
    pushFront(node)
  }

  /// Keys from most to least recently used.
  var keys: [Key] {
    Array(sequence(first: newest) { $0?.older }.compactMap { $0?.key })
  }

  private func pushFront(_ node: Node) {
    node.older = newest
    newest?.newer = node
    newest = node
    if oldest == nil { oldest = node }
  }

  private func unlink(_ node: Node) {
    node.newer?.older = node.older
    node.older?.newer = node.newer
    if newest === node { newest = node.older }
    if oldest === node { oldest = node.newer }
    node.newer = nil
    node.older = nil
  }

  private func moveToFront(_ node: Node) {
    guard newest !== node else { return }
    unlink(node)
    pushFront(node)
  }
}

func demoLRUCache() {
  let cache = LRUCache<String, Int>(capacity: 2)
  cache.put("a", 1)
  cache.put("b", 2)
  assert(cache.get("a") == 1)
  // b is now the least recently used, so c evicts it
  cache.put("c", 3)
  assert(cache.get("b") == nil)
  assert(cache.keys == ["c", "a"])
}
