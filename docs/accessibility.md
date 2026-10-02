# Accessibility

Swift CheatSheet aims to meet WCAG 2.2 AA. This page lists what is in
place, what the tests check, and what still needs a person to verify.

## In place

- Every entry is plain text in the first HTML response. Nothing is
  collapsed, tabbed or loaded later, so browser find and screen readers
  reach all of it, with or without JavaScript.
- One `h1`, then sections (`h2`), topics (`h3`) and entries (`h4`), a
  skip link, landmarks, table headers and labelled buttons.
- Keyboard: `/` opens the jump list; arrow keys move, Enter jumps and
  Escape closes. Focus is always visible.
- Text and code use `rem` sizes and follow the browser's text size.
  Code wraps with a hanging indent instead of scrolling sideways.
- Light and dark appearance follow the system, with a manual toggle.
  The only motion, a fading highlight after a jump, is removed under
  reduced motion.
- Syntax colour is an aid only; code reads correctly in greyscale.

## Checked automatically

`python3 -m unittest discover -s tests/site -t .` runs on every push
and fails the deploy if:

- any text or syntax colour is below 4.5:1 on its background, in light
  or dark;
- a heading level is skipped, an id repeats, a button has no name, or
  anything inside `<main>` is hidden;
- the page uses inline styles or exceeds its size budget.

The layout is also checked at 320 CSS pixels wide (the reflow width for
a 1280-pixel window at 400% zoom).

## Still to check by hand

- A full VoiceOver (macOS) and NVDA (Windows) pass.
- Zoom behaviour in Safari and Firefox.
- The SwiftUI and UIKit examples are compiled and run on a simulator,
  but not audited with VoiceOver or at every Dynamic Type size.

## Report a problem

[Open an issue](https://github.com/arieltyson/swift-cheatsheet/issues)
with the browser, assistive technology, zoom or text size, and a link
to the entry.
