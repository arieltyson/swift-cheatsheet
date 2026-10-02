func subsets<Element>(_ values: [Element]) -> [[Element]] {
    var result: [[Element]] = []
    var selected: [Element] = []
    func explore(_ index: Int) {
        guard index < values.count else {
            result.append(selected)
            return
        }
        explore(index + 1)
        selected.append(values[index])
        explore(index + 1)
        selected.removeLast()
    }
    explore(0)
    return result
}
