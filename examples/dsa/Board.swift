func demoBoardIndex() {
  let size = 3
  // A flat array stores an n x n board row by row
  let (row, col) = (1, 2)
  let index = row * size + col
  assert(index == 5)
  assert(index / size == 1)
  assert(index % size == 2)
  var board = [Character?](repeating: nil, count: size * size)
  board[index] = "X"
  assert(board.compactMap { $0 } == ["X"])
}

enum Mark: Equatable {
  case x
  case o

  var next: Mark { self == .x ? .o : .x }
}

/// An n x n tic-tac-toe board: each move, undo and win check is O(1).
struct TicTacToe {
  let size: Int
  private(set) var cells: [Mark?]
  private(set) var current = Mark.x
  private(set) var winner: Mark?
  private var history: [Int] = []
  // Sum per line: +1 for each X, -1 for each O; +-size means a win
  private var rowSums: [Int]
  private var colSums: [Int]
  private var diagonal = 0
  private var antiDiagonal = 0

  init(size: Int) {
    self.size = max(3, size)
    cells = Array(repeating: nil, count: self.size * self.size)
    rowSums = Array(repeating: 0, count: self.size)
    colSums = Array(repeating: 0, count: self.size)
  }

  var isDraw: Bool { winner == nil && history.count == cells.count }
  var canUndo: Bool { !history.isEmpty }

  /// Places the current mark; returns false for an illegal move.
  @discardableResult
  mutating func play(row: Int, col: Int) -> Bool {
    let index = row * size + col
    guard winner == nil, cells[index] == nil else { return false }
    cells[index] = current
    history.append(index)
    update(current, row: row, col: col, by: 1)
    if winner == nil { current = current.next }
    return true
  }

  mutating func undo() {
    guard let index = history.popLast(), let mark = cells[index] else {
      return
    }
    cells[index] = nil
    update(mark, row: index / size, col: index % size, by: -1)
    winner = nil
    current = mark
  }

  private mutating func update(
    _ mark: Mark, row: Int, col: Int, by step: Int
  ) {
    let value = (mark == .x ? 1 : -1) * step
    rowSums[row] += value
    colSums[col] += value
    if row == col { diagonal += value }
    if row + col == size - 1 { antiDiagonal += value }
    let lines = [rowSums[row], colSums[col], diagonal, antiDiagonal]
    if step > 0 && lines.contains(where: { abs($0) == size }) {
      winner = mark
    }
  }
}

func demoTicTacToe() {
  var game = TicTacToe(size: 3)
  for (row, col) in [(0, 0), (1, 1), (0, 1), (2, 2), (0, 2)] {
    game.play(row: row, col: col)
  }
  assert(game.winner == .x)
  assert(game.play(row: 2, col: 0) == false)
  game.undo()
  assert(game.winner == nil)
  assert(game.current == .x)
}
