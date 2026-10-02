# Decisions

## 01 — One document, three destinations
Context: browser find must reach every answer under interview time pressure.
Decision: render all entries into one HTML document. Three section links are anchors, not ARIA tabs or hidden panels.
Consequence: a longer page, offset by a visible contents list, stable anchors, and native find. No custom search engine is needed.

## 02 — Source is the reference
Context: pasted documentation can drift from tests.
Decision: render entire Swift files from a validated manifest; explicitly link helper dependencies. Keep tests separate.
Consequence: no handwritten duplicate snippet text and no runtime Swift execution in the browser.

## 03 — Small static tooling
Context: this is a personal reference, not an app platform.
Decision: Python standard library builds semantic HTML, CSS, and a tiny optional clipboard script. System fonts and system appearance need no storage.
Consequence: zero website packages and no API, account, analytics, service worker, or framework maintenance.

## 04 — Native checks are developer tooling
Context: UIKit cannot run in a web page or a macOS-only Swift package.
Decision: use the installed Xcode SDK to compile a small simulator fixture separately from portable SwiftPM tests.
Consequence: the public artifact never contains the fixture, private planning documents, or build caches.

## 05 — Release authority
Context: the initial task was document-only; the later implementation request explicitly authorized a new GitHub repository and real pushed commits.
Decision: create a separate public `swift-cheatsheet` repository and publish only the verified static artifact through GitHub Pages.
Consequence: unrelated workspace repositories and source Google Docs stay untouched.
