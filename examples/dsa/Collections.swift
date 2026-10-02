func collectionExample() -> (
    counts: [String: Int], unique: [Int], total: Int
) {
    var values = [3, 1, 3, 2]
    values.append(5)
    let slice = values[1..<3]
    let owned = Array(slice)
    let doubled = owned.map { $0 * 2 }
    let positive = doubled.filter { $0 > 0 }
    let parsed = ["7", "bad", "9"].compactMap(Int.init)
    let total = (positive + parsed).reduce(0, +)

    let words = ["swift", "code", "swift"]
    let counts = words.reduce(into: [String: Int]()) { result, word in
        result[word, default: 0] += 1
    }
    let grouped = Dictionary(grouping: words, by: { $0.count })
    precondition(grouped[5]?.count == 2)

    var unique = Set(values)
    unique.formUnion([4, 5])
    unique.subtract([1])
    let shared = unique.intersection([2, 3, 4])
    precondition(shared.isSubset(of: unique))

    let ranked = values.sorted(by: >)
    for (offset, value) in ranked.enumerated() {
        precondition(ranked[offset] == value)
    }
    let pairs = Array(zip(["first", "second"], [1, 2]))
    precondition(pairs.count == 2)
    let backwards = Array(stride(from: 3, through: 0, by: -1))
    precondition(backwards == [3, 2, 1, 0])
    return (counts, unique.sorted(), total)
}
