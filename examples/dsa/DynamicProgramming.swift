/// Returns the ways to climb taking 1 or 2 steps (top-down).
func climbStairsMemo(_ steps: Int) -> Int {
  var memo = [0: 1, 1: 1]
  func ways(_ remaining: Int) -> Int {
    if let known = memo[remaining] { return known }
    let total = ways(remaining - 1) + ways(remaining - 2)
    memo[remaining] = total
    return total
  }
  return ways(steps)
}

/// Returns the ways to climb taking 1 or 2 steps (bottom-up).
func climbStairs(_ steps: Int) -> Int {
  var (previous, current) = (1, 1)
  for _ in stride(from: 2, through: steps, by: 1) {
    (previous, current) = (current, previous + current)
  }
  return current
}

/// Returns the largest sum with no two adjacent values taken.
func houseRobber(_ values: [Int]) -> Int {
  // Best totals up to two houses back and up to the previous house
  var (previous, current) = (0, 0)
  for value in values {
    (previous, current) = (current, max(current, previous + value))
  }
  return current
}

/// Returns the fewest coins that sum to amount, or -1.
func coinChange(_ coins: [Int], _ amount: Int) -> Int {
  let impossible = amount + 1
  var fewest = [0] + Array(repeating: impossible, count: amount)
  for total in stride(from: 1, through: amount, by: 1) {
    for coin in coins where coin <= total {
      fewest[total] = min(fewest[total], fewest[total - coin] + 1)
    }
  }
  return fewest[amount] == impossible ? -1 : fewest[amount]
}

/// Returns the best total value using each item at most once.
func knapsack(_ weights: [Int], _ values: [Int], capacity: Int) -> Int {
  var best = Array(repeating: 0, count: capacity + 1)
  for (weight, value) in zip(weights, values) where weight <= capacity {
    // Go downward so each item is counted at most once
    for room in stride(from: capacity, through: weight, by: -1) {
      best[room] = max(best[room], best[room - weight] + value)
    }
  }
  return best[capacity]
}

/// Returns the right/down paths from top-left to bottom-right.
func uniqueGridPaths(rows: Int, cols: Int) -> Int {
  var row = Array(repeating: 1, count: cols)
  for _ in 1..<rows {
    for col in 1..<cols {
      row[col] += row[col - 1]
    }
  }
  return row[cols - 1]
}

/// Returns the length of the longest common subsequence.
func longestCommonSubsequence(_ first: String, _ second: String) -> Int
{
  let a = Array(first)
  let b = Array(second)
  var table = Array(
    repeating: Array(repeating: 0, count: b.count + 1),
    count: a.count + 1
  )
  for i in stride(from: 1, through: a.count, by: 1) {
    for j in stride(from: 1, through: b.count, by: 1) {
      table[i][j] =
        a[i - 1] == b[j - 1]
        ? table[i - 1][j - 1] + 1
        : max(table[i - 1][j], table[i][j - 1])
    }
  }
  return table[a.count][b.count]
}

/// Returns the length of the longest strictly rising subsequence.
func longestIncreasingSubsequence(_ values: [Int]) -> Int {
  // tails[k] = smallest tail of any increasing run of length k + 1
  var tails: [Int] = []
  for value in values {
    let index = lowerBound(tails, value)
    if index == tails.count {
      tails.append(value)
    } else {
      tails[index] = value
    }
  }
  return tails.count
}
