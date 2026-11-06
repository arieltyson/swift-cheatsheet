import Testing

@testable import InterviewExamples

// Each demo's asserts are the results shown on the page. swift test
// builds in debug, where assert is checked.
@Test(
  arguments: [
    ("Arrays", demoArrayOperations), ("BoardIndex", demoBoardIndex),
    ("Protocols", demoProtocols),
    ("Extensions", demoExtensions), ("Generics", demoGenerics),
    ("LRUCache", demoLRUCache), ("DoCatch", demoDoCatch),
    ("TryVariants", demoTryVariants),
    ("Defer", demoDefer), ("Result", demoResult),
    ("TicTacToe", demoTicTacToe),
    ("BitmaskSubsets", demoBitmaskSubsets),
    ("Bits", demoBits), ("BuildStrings", demoBuildStrings),
    ("Cents", demoCents), ("Characters", demoCharacters),
    ("Closures", demoClosures), ("Comparable", demoComparable),
    ("Counting", demoCounting), ("CreateArrays", demoCreateArrays),
    ("DateMath", demoDateMath), ("Dictionary", demoDictionary),
    ("ElapsedTime", demoElapsedTime), ("Enums", demoEnums),
    ("Gcd", demoGcd), ("Graphs", demoGraphs),
    ("Grouping", demoGrouping),
    ("HashableKeys", demoHashableKeys),
    ("HeadIndexQueue", demoHeadIndexQueue), ("Heap", demoHeap),
    ("HeapOfTuples", demoHeapOfTuples),
    ("IntegerDivision", demoIntegerDivision),
    ("Iteration", demoIteration),
    ("LetterCounts", demoLetterCounts), ("Math", demoMath),
    ("Money", demoMoney), ("NumberFormats", demoNumberFormats),
    ("Optionals", demoOptionals), ("Overflow", demoOverflow),
    ("PaddingAndRadix", demoPaddingAndRadix), ("Queue", demoQueue),
    ("RingBuffer", demoRingBuffer),
    ("RangeSum", demoRangeSum), ("Rounding", demoRounding),
    ("SearchArrays", demoSearchArrays), ("Set", demoSet),
    ("Slices", demoSlices), ("Sorting", demoSorting),
    ("SortKeys", demoSortKeys), ("Stack", demoStack),
    ("StringBasics", demoStringBasics),
    ("StringIndexing", demoStringIndexing),
    ("Transforms", demoTransforms),
    ("Trie", demoTrie), ("UnionFind", demoUnionFind),
    ("ValueSemantics", demoValueSemantics),
    ("VectorLength", demoVectorLength),
  ] as [(String, @Sendable () -> Void)])
func demoRuns(name: String, demo: @Sendable () -> Void) {
  demo()
}
