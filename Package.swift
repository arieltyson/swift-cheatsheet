// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "SwiftCheatSheet",
  platforms: [.macOS(.v15)],
  products: [
    .library(name: "InterviewExamples", targets: ["InterviewExamples"])
  ],
  targets: [
    .target(name: "InterviewExamples", path: "examples/dsa"),
    .target(name: "ConcurrencyExamples", path: "examples/concurrency"),
    .testTarget(
      name: "InterviewExamplesTests",
      dependencies: ["InterviewExamples"],
      path: "tests/swift"
    ),
    .testTarget(
      name: "ConcurrencyExamplesTests",
      dependencies: ["ConcurrencyExamples"],
      path: "tests/concurrency"
    ),
  ],
  swiftLanguageModes: [.v6]
)
