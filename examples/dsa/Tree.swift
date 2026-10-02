final class TreeNode<Value> {
  let value: Value
  var left: TreeNode<Value>?
  var right: TreeNode<Value>?

  init(_ value: Value) {
    self.value = value
  }
}

func inorder<Value>(_ root: TreeNode<Value>?) -> [Value] {
  var stack: [TreeNode<Value>] = []
  var current = root
  var values: [Value] = []
  while current != nil || !stack.isEmpty {
    while let node = current {
      stack.append(node)
      current = node.left
    }
    guard let node = stack.popLast() else { break }
    values.append(node.value)
    current = node.right
  }
  return values
}
