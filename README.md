# Swift CheatSheet

A small, fast interview reference for **Pure DSA Swift**, **SwiftUI**, and **UIKit**. All content is rendered together: native ⌘F / Ctrl+F searches every example without opening panels.

## Architecture

- `examples/`: original, compilable Swift examples; the displayed code is read directly from these files.
- `content/entries.json`: visible aliases, answers, assumptions, complexity, availability, and official sources.
- `web/`: semantic HTML, token-driven CSS, and optional clipboard enhancement. No runtime dependencies.
- `tools/`: deterministic Python standard-library build and verification.
- `tests/`: Swift behavior tests, site guardrails, and an Apple SDK fixture.
- `dist/`: ignored, public-only output for GitHub Pages.

## Development

Requires Python 3.11+ and Swift 6.0+. Native examples require Xcode and an iOS simulator. Development verification uses Xcode 27.0 / Swift 6.4 in Swift 6 language mode. Foundation examples target macOS 13+; UI examples target iOS 17+ unless an entry says otherwise.

```sh
python3 tools/build.py
python3 -m unittest discover -s tests/site -v
swift test
python3 -m http.server 8000 --directory dist --bind 127.0.0.1
```

Open http://127.0.0.1:8000. Website usage does not require Python, Swift, or JavaScript.

## Content rules

Each entry has an independent Swift source file and complete metadata. Helpers shared by examples are linked as visible prerequisites. DSA uses the standard library; Foundation is used only for basic formatting. SwiftUI, UIKit, and Observation are the native framework subjects, not website dependencies. No third-party Swift packages.

Explain actual time, auxiliary space, and output space rather than claiming universal optimality. State Unicode, overflow, ownership, and cancellation assumptions. Keep code selectable, aliases visible, links stable, and every entry rendered without scripts. Do not add exclusive tabs, accordions, runtime source fetching, analytics, or remote fonts.

## Scope

The initial release covers essential language/collection/formatting syntax, core data structures and algorithm patterns, and focused native UI examples. Trie, union-find, topological sort, monotonic stacks, advanced graph structures, and larger DP collections remain deliberate follow-up scope.

No third-party license is selected on the owner's behalf. This is an independent reference, not an Apple product.
