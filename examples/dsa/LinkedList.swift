final class ListNode<Value> {
  var value: Value
  var next: ListNode<Value>?

  init(_ value: Value, next: ListNode<Value>? = nil) {
    self.value = value
    self.next = next
  }
}

func reverseList<Value>(_ head: ListNode<Value>?) -> ListNode<Value>? {
  var previous: ListNode<Value>?
  var current = head
  while let node = current {
    let following = node.next
    node.next = previous
    previous = node
    current = following
  }
  return previous
}
