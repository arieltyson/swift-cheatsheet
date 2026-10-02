import Testing

@testable import InterviewExamples

// Each demo's asserts are the results shown on the page. swift test
// builds in debug, where assert is checked.
@Test(
  arguments: [
    ("Arrays", demoArrayOperations), ("BoardIndex", demoBoardIndex),
    ("TicTacToe", demoTicTacToe),
    ("BitmaskSubsets", demoBitmaskSubsets),
    ("Bits", demoBits), ("BuildStrings", demoBuildStrings),
    ("Cents", demoCents), ("Characters", demoCharacters),
    ("Closures", demoClosures), ("Comparable", demoComparable),
    ("Counting", demoCounting), ("CreateArrays", demoCreateArrays),
    ("Dictionary", demoDictionary), ("Enums", demoEnums),
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
    ("RangeSum", demoRangeSum), ("Rounding", demoRounding),
    ("SearchArrays", demoSearchArrays), ("Set", demoSet),
    ("Slices", demoSlices), ("Sorting", demoSorting),
    ("SortKeys", demoSortKeys), ("Stack", demoStack),
    ("StringBasics", demoStringBasics),
    ("StringIndexing", demoStringIndexing),
    ("Transforms", demoTransforms),
    ("Trie", demoTrie), ("UnionFind", demoUnionFind),
    ("ValueSemantics", demoValueSemantics),
  ] as [(String, @Sendable () -> Void)])
func demoRuns(name: String, demo: @Sendable () -> Void) {
  demo()
}
