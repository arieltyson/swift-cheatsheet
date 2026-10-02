# Decisions

Reversals are recorded as new entries, not edits.

## 01: One document, three sections

Context: browser find must reach every answer under interview time
pressure.
Decision: all entries are in one HTML document. Pure DSA Swift, SwiftUI
and UIKit are header links to sections, not tabs or hidden panels.
Consequence: a long page, navigated with the contents list, `/` and
Cmd+F.

## 02: The displayed code is the tested code

Context: pasted documentation drifts from tests.
Decision: the build extracts declarations by name from `examples/`.
DSA demos keep real `assert` calls that `swift test` runs; the page
shows them as `expression  // result`.
Consequence: no hand-written duplicate snippets. A wrong result fails
CI.

## 03: Native checks are developer tooling

Context: UIKit cannot run in a web page or a macOS Swift package.
Decision: `tools/native.py` type-checks every SwiftUI and UIKit example
against the iOS SDK in strict Swift 6 mode, then runs behaviour checks
on an isolated simulator.
Consequence: the public artifact never contains the fixture.

## 04: Avoid SwiftPM's reserved Snippets directory

Context: on case-insensitive macOS, SwiftPM treats `snippets/` as its
reserved `Snippets/` directory.
Decision: examples live in `examples/`.

## 05: Reversed: one design system with Python and TypeScript CheatSheet

Context: the first version used its own layout, green palette, nine
parts per entry and one large example function per topic. It was hard
to scan in an interview.
Decision: port the shared design system from Python CheatSheet and
TypeScript CheatSheet. Swift orange (#F05138) replaces their identity
colour; link and highlight colours are derived from it and contrast
tested. Each entry has at most five parts: title, one meta line,
use-when, code, gotcha.
Consequence: knowing one site means knowing the others. Design fixes
are shared between the three.

## 06: Redundant @MainActor removed

Context: SwiftUI's `View` and UIKit's `UIViewController`, `UIView` and
cells are already main-actor isolated.
Decision: only types that need it (an `@Observable` model, an
`ObservableObject`, a delegate protocol and its non-UIKit conformer)
keep `@MainActor`.
Consequence: less noise in every UI example. Strict Swift 6 type
checking with warnings as errors still passes.

## 07: A fourth section for concurrency and debugging

Context: iOS debugging interviews test parallel fetching in three
styles (callbacks, Combine, async/await), thread safety and leaks.
Decision: add a Concurrency & debugging section, in its own SwiftPM
target (macOS 15 for `Mutex`). Its tests also check timing, so an
example labelled parallel cannot silently run serially.
Consequence: four header links instead of three. Entries for Swift 6.2
features state the version they need.
