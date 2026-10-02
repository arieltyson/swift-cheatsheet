# Accessibility

## Implemented

- One static document: all three domains, aliases, explanations, and code remain visible without JavaScript.
- Landmarks, a skip link, ordered section/entry headings, descriptive links, native buttons, and table headers.
- Exact selectable code, wrapping at narrow widths, rem-based typography, and system fonts.
- Visible keyboard focus, minimum 44 CSS-pixel copy controls, and non-color link cues.
- System light/dark appearance, stronger-contrast preference, and forced-color support.
- No animations or smooth scrolling, so reduced-motion preferences need no exception.
- Inline polite copy announcements that do not move focus or cover the code. Failure explicitly offers manual selection.

## Verified automatically

Python checks every text/syntax color against every relevant surface (at least 4.5:1), and focus/boundary colors (at least 3:1). Browser checks cover keyboard skip navigation, all-visible content, exact clipboard output, clipboard denial, blocked storage, no scripts, unknown hashes, back/forward, 320/720/1440-pixel widths, light/dark appearance, and 200% root text sizing. The 320-pixel layout is the reflow viewport corresponding to a 1280-pixel window at 400% zoom; it is not a substitute for testing every browser's actual zoom implementation.

axe-core checks WCAG A/AA rules in desktop, half-width, narrow, and dark layouts. Screenshots are reviewed for code legibility, focus, forced colors, and failure feedback.

## Remaining human checks

Automated scans do not establish WCAG conformance. A complete VoiceOver/NVDA reading-and-announcement pass, Safari/Firefox zoom behavior, user-timed interview lookup trials, and a broad native Dynamic Type/VoiceOver pass remain human acceptance work. Native examples compile and receive focused simulator checks, not exhaustive UI automation of every possible interaction.

[Report an accessibility problem](https://github.com/arieltyson/swift-cheatsheet/issues), including browser, assistive technology, zoom/text size, and the entry link when possible.
