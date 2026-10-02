final class ListNode {
  var val: Int
  var next: ListNode?

  init(_ val: Int, _ next: ListNode? = nil) {
    self.val = val
    self.next = next
  }
}

/// Returns the head of a linked list holding values in order.
func buildList(_ values: [Int]) -> ListNode? {
  let dummy = ListNode(0)
  var tail = dummy
  for value in values {
    let node = ListNode(value)
    tail.next = node
    tail = node
  }
  return dummy.next
}

/// Returns the values of a linked list as an array.
func listValues(_ head: ListNode?) -> [Int] {
  var values: [Int] = []
  var node = head
  while let current = node {
    values.append(current.val)
    node = current.next
  }
  return values
}

/// Returns the new head after reversing the list in place.
func reverseList(_ head: ListNode?) -> ListNode? {
  var previous: ListNode?
  var current = head
  while let node = current {
    current = node.next
    node.next = previous
    previous = node
  }
  return previous
}

/// Returns the middle node (the second middle for even length).
func middleNode(_ head: ListNode?) -> ListNode? {
  var slow = head
  var fast = head
  while let next = fast?.next {
    slow = slow?.next
    fast = next.next
  }
  return slow
}

/// Returns true if following next pointers ever loops.
func hasCycle(_ head: ListNode?) -> Bool {
  var slow = head
  var fast = head
  while let next = fast?.next {
    slow = slow?.next
    fast = next.next
    if slow === fast { return true }
  }
  return false
}

/// Returns one sorted list made from two sorted lists.
func mergeSorted(_ first: ListNode?, _ second: ListNode?) -> ListNode? {
  let dummy = ListNode(0)
  var tail = dummy
  var (first, second) = (first, second)
  while let a = first, let b = second {
    if a.val <= b.val {
      tail.next = a
      first = a.next
    } else {
      tail.next = b
      second = b.next
    }
    tail = tail.next!
  }
  tail.next = first ?? second
  return dummy.next
}
