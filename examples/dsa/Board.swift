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

/// 0-based (row, col) in a 3 x 3 grid, read as grid[row][col]:
///
///            col 0    col 1    col 2
///   row 0   (0, 0)   (0, 1)   (0, 2)
///   row 1   (1, 0)   (1, 1)   (1, 2)
///   row 2   (2, 0)   (2, 1)   (2, 2)
///
/// Row r: row fixed, col varies.   Col c: col fixed, row varies.
/// Main diagonal (\): row == col.
/// Anti-diagonal (/): row + col == n - 1.
func demoGridLines() {
  let n = 3
  let isMain = { (row: Int, col: Int) in row == col }
  let isAnti = { (row: Int, col: Int) in row + col == n - 1 }
  assert(isMain(1, 1) && isAnti(1, 1))  // the centre is on both
  assert(isAnti(0, 2) && isAnti(2, 0) && !isAnti(0, 0))
  assert(!isMain(0, 1) && !isAnti(0, 1))  // edge middles: neither

  // Coordinates of each line, built from 0..<n
  let row1 = (0..<n).map { col in [1, col] }
  let col2 = (0..<n).map { row in [row, 2] }
  let main = (0..<n).map { i in [i, i] }
  // Solve the rule for col: row + col == n - 1, row = i,
  // so col = n - 1 - i. (abs(i - (n - 1)) is the same, but longer.)
  let anti = (0..<n).map { i in [i, n - 1 - i] }
  assert(row1 == [[1, 0], [1, 1], [1, 2]])
  assert(col2 == [[0, 2], [1, 2], [2, 2]])
  assert(main == [[0, 0], [1, 1], [2, 2]])
  assert(anti == [[0, 2], [1, 1], [2, 0]])
}

/// A direction is how row and col change for ONE step: (dr, dc).
/// Right (0, 1), down (1, 0), down-right (1, 1), down-left (1, -1).
/// Its opposite negates both. 4 lines = 4 directions x 2 ways.
func demoGridSteps() {
  let n = 4
  let lines = [(0, 1), (1, 0), (1, 1), (1, -1)]
  let opposites = lines.map { (dr, dc) in (-dr, -dc) }
  assert(opposites[3] == (-1, 1))  // up-right

  // Walk from (1, 1) until the next step leaves the grid
  let (dr, dc) = (1, 1)
  var (row, col) = (1 + dr, 1 + dc)  // start at the NEXT cell
  var steps = 0
  while (0..<n).contains(row) && (0..<n).contains(col) {
    steps += 1
    row += dr
    col += dc
  }
  assert(steps == 2)  // (2, 2) and (3, 3); the start isn't counted
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
