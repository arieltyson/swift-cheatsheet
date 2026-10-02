final class TreeNode {
  var val: Int
  var left: TreeNode?
  var right: TreeNode?

  init(_ val: Int, _ left: TreeNode? = nil, _ right: TreeNode? = nil) {
    self.val = val
    self.left = left
    self.right = right
  }
}

/// Returns the root of a tree given in level order, nil = gap.
func buildTree(_ values: [Int?]) -> TreeNode? {
  guard let first = values.first, let rootValue = first else {
    return nil
  }
  let root = TreeNode(rootValue)
  var queue = [root]
  var head = 0
  var index = 1
  while head < queue.count, index < values.count {
    let node = queue[head]
    head += 1
    if let value = values[index] {
      node.left = TreeNode(value)
      queue.append(node.left!)
    }
    if index + 1 < values.count, let value = values[index + 1] {
      node.right = TreeNode(value)
      queue.append(node.right!)
    }
    index += 2
  }
  return root
}

/// Returns the (preorder, inorder, postorder) values.
func traversals(
  _ root: TreeNode?
) -> (preorder: [Int], inorder: [Int], postorder: [Int]) {
  var preorder: [Int] = []
  var inorder: [Int] = []
  var postorder: [Int] = []
  func visit(_ node: TreeNode?) {
    guard let node else { return }
    preorder.append(node.val)
    visit(node.left)
    inorder.append(node.val)
    visit(node.right)
    postorder.append(node.val)
  }
  visit(root)
  return (preorder, inorder, postorder)
}

/// Returns inorder values without recursion.
func inorderIterative(_ root: TreeNode?) -> [Int] {
  var values: [Int] = []
  var stack: [TreeNode] = []
  var node = root
  while node != nil || !stack.isEmpty {
    while let current = node {
      stack.append(current)
      node = current.left
    }
    let visited = stack.removeLast()
    values.append(visited.val)
    node = visited.right
  }
  return values
}

/// Returns the values of each level, top to bottom.
func levelOrder(_ root: TreeNode?) -> [[Int]] {
  var levels: [[Int]] = []
  var level = [root].compactMap { $0 }
  while !level.isEmpty {
    levels.append(level.map(\.val))
    level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
  }
  return levels
}

/// Returns the number of nodes on the longest root-to-leaf path.
func maxDepth(_ root: TreeNode?) -> Int {
  guard let root else { return 0 }
  return 1 + max(maxDepth(root.left), maxDepth(root.right))
}

/// Inserts val and returns the (possibly new) root.
func bstInsert(_ root: TreeNode?, _ val: Int) -> TreeNode {
  guard let root else { return TreeNode(val) }
  if val < root.val {
    root.left = bstInsert(root.left, val)
  } else {
    root.right = bstInsert(root.right, val)
  }
  return root
}

/// Returns true if every node is strictly between its bounds.
func isValidBST(
  _ root: TreeNode?, low: Int = .min, high: Int = .max
) -> Bool {
  guard let root else { return true }
  guard low < root.val, root.val < high else { return false }
  return isValidBST(root.left, low: low, high: root.val)
    && isValidBST(root.right, low: root.val, high: high)
}
