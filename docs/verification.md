# Verification record

Initial local verification: 2026-10-02. No interview-success or human lookup-speed claim is made.

## Environment and observed checks

- Xcode 27.0 (27A266a), Apple Swift 6.4; Swift 6 language mode.
- 14 Swift Testing tests pass, including deterministic comparison cases for binary search, heaps, and shortest paths; Unicode, copy-on-write semantics, currency outputs, queue reference release, and overflow boundaries are covered.
- All 14 SwiftUI/UIKit files type-check for an iOS 17 deployment target with strict concurrency and warnings as errors.
- 23 native fixture assertions pass on an iOS 27 simulator: lifecycle, layout, data-source identity, delegation lifetime, hosting, same-item stale async results, reuse reset, model state, and SwiftUI mounting.
- Nine Python test groups pass: exact displayed source, manifest rejection, escaped HTML, unique/resolvable anchors, deterministic output, contrast, all-visible content, public-only output, and dependency/privacy budgets.
- Chromium/Chrome browser checks pass at 1440, 720, and 320 CSS pixels, in light and dark appearance: zero axe violations in the tested rules, no document overflow, no console errors, and no external runtime requests.
- Ten representative native `window.find` lookups succeed across the three domains. These are browser execution checks, not timed human usability trials.
- Copy succeeds with exact source bytes; denied clipboard access, disabled JavaScript, and blocked storage leave content usable. Hash links and history navigation work.
- Local load uses four same-origin resources; observed layout-shift total is zero in the controlled browser run. This is a lab observation, not a field-performance guarantee.
- Initial public artifact is about 28.3 KB gzip in aggregate; optional JavaScript is below 0.4 KB gzip. Build checks enforce 150 KB aggregate / 10 KB JavaScript budgets. Exact sizes are printed on every build.

## Phase reconciliation

| Plan phase | Implemented result |
| --- | --- |
| 0 — Scaffold/model/build | Separate project, SwiftPM, validated 35-entry manifest, deterministic standard-library generator. |
| 1 — Immediate access | Visible anchors, index, source on first response, explicit availability and system appearance. |
| 2 — Reference UI | Shared color tokens, semantic continuous reading flow, build-time escaped highlighting, exact copy. |
| 3 — DSA | Syntax, collections, strings, numbers/money, stack, queue, heap, lists, trees, graphs, core patterns and tests. |
| 4 — Native iOS | Observation-first SwiftUI, labeled older-code comparison, UIKit essentials, bidirectional bridges, simulator fixture. |
| 5 — Integration | Progressive clipboard enhancement only; no redundant search engine, storage, polling, or hidden panels. |
| 6 — Accessibility/quality | Automated checks and screenshot inspection complete; human/assistive-technology acceptance limitations are explicit. |
| 7 — Release | Public-only artifact, policy statements, pinned GitHub Actions, deployment gated on browser and native checks. See live Actions for release status. |

## Architectural adjustments

`examples/` replaces the proposed `snippets/` directory to avoid SwiftPM's automatic standalone snippet target discovery on case-insensitive macOS. The native fixture uses Xcode's compiler/SDK and a temporary simulator app rather than a generated Xcode project. This keeps the fixture dependency-free while running actual native code. CI may use a different installed stable Xcode version and records its exact toolchain; it still enforces Swift 6 mode and the same iOS 17 deployment target.

The plan's 22 proposed work units are grouped into coherent real commits, with corrective commits for issues observed during verification. No private planning exports are included. No license, alternate icon, custom domain, or additional feature backlog is silently selected.

## Deliberate limitations

- Foundation locale output is verified on the recorded Apple runtime; future locale data can alter presentation details.
- SwiftUI lifecycle/cancellation explanations and compiler checks do not prove every interactive UI state. Full screen-reader and native interaction acceptance is not claimed.
- Dijkstra rejects any explored distance overflow, even if another candidate route would fit. Prefix sums require representable running totals and differences. Preconditions and complexity match the visible implementations.
- [Accessibility acceptance work](accessibility.md) and measured personal lookup trials remain distinct from automated success.
