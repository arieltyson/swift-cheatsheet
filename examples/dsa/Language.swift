enum LookupResult: Equatable {
  case found(index: Int)
  case missing
}

struct Candidate: Hashable {
  let name: String
  var score: Int
}

final class ScoreBox {
  var value = 0
}

func firstMatch<Value: Equatable>(
  _ values: [Value], target: Value
) -> LookupResult {
  guard let index = values.firstIndex(of: target) else {
    return .missing
  }
  return .found(index: index)
}

func increment(_ count: inout Int) {
  count += 1
}

func languageExample() -> (label: String, score: Int) {
  let original = Candidate(name: "Ari", score: 3)
  var copy = original
  increment(&copy.score)
  let parsed = Int("42")
  let label = parsed.map { "Answer: \($0)" } ?? "Not a number"
  return (label, copy.score)
}
