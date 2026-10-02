func minimumCoins(_ coins: [Int], amount: Int) -> Int? {
  precondition(amount >= 0 && amount < Int.max)
  precondition(coins.allSatisfy { $0 > 0 })
  var best = Array(repeating: amount + 1, count: amount + 1)
  best[0] = 0
  guard amount > 0 else { return 0 }
  for subtotal in 1...amount {
    for coin in coins where coin <= subtotal {
      if best[subtotal - coin] < amount {
        best[subtotal] = min(best[subtotal], best[subtotal - coin] + 1)
      }
    }
  }
  return best[amount] <= amount ? best[amount] : nil
}
