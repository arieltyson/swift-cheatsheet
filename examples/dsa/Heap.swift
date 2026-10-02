struct BinaryHeap<Element> {
    private var elements: [Element]
    private let orderedBefore: (Element, Element) -> Bool

    init(
        _ values: [Element] = [],
        orderedBefore: @escaping (Element, Element) -> Bool
    ) {
        elements = values
        self.orderedBefore = orderedBefore
        if elements.count > 1 {
            for parent in stride(from: elements.count / 2 - 1, through: 0, by: -1) {
                siftDown(from: parent)
            }
        }
    }

    var count: Int { elements.count }
    var peek: Element? { elements.first }

    mutating func push(_ value: Element) {
        elements.append(value)
        var child = elements.count - 1
        while child > 0 {
            let parent = (child - 1) / 2
            guard orderedBefore(elements[child], elements[parent]) else { break }
            elements.swapAt(child, parent)
            child = parent
        }
    }

    mutating func pop() -> Element? {
        guard !elements.isEmpty else { return nil }
        elements.swapAt(0, elements.count - 1)
        let result = elements.removeLast()
        if !elements.isEmpty { siftDown(from: 0) }
        return result
    }

    private mutating func siftDown(from index: Int) {
        var parent = index
        while parent < elements.count / 2 {
            let left = 2 * parent + 1
            let right = left + 1
            var preferred = left
            if right < elements.count,
               orderedBefore(elements[right], elements[left]) {
                preferred = right
            }
            guard orderedBefore(elements[preferred], elements[parent]) else { break }
            elements.swapAt(parent, preferred)
            parent = preferred
        }
    }
}
