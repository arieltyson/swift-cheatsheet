// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftCheatSheet",
    platforms: [.macOS(.v13)],
    products: [.library(name: "InterviewExamples", targets: ["InterviewExamples"])],
    targets: [
        .target(name: "InterviewExamples", path: "examples/dsa"),
        .testTarget(
            name: "InterviewExamplesTests",
            dependencies: ["InterviewExamples"],
            path: "tests/swift"
        )
    ],
    swiftLanguageModes: [.v6]
)
