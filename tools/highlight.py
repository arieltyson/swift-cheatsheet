"""Turn Swift source into highlighted HTML lines at build time."""

import html

from tools.lexer import Token, tokenize

KEYWORDS = frozenset(
    """
    actor any as associatedtype async await break case catch class
    continue default defer deinit do else enum extension fallthrough
    false fileprivate final for func get guard if import in indirect
    init inout internal is lazy let mutating nil nonisolated open
    override private protocol public repeat required rethrows return
    self Self set some static struct subscript super switch throw
    throws true try typealias var weak unowned where while willSet
    didSet
    """.split()
)
BUILTINS = frozenset(
    """
    Int Int64 UInt Double Float Bool String Character Substring Array
    Dictionary Set Optional Range ClosedRange Decimal Result Error
    Never Void Task Equatable Hashable Comparable Identifiable
    Sendable Collection Sequence print min max abs zip stride
    precondition fatalError swap
    """.split()
)
DEFINERS = frozenset(
    {"func", "struct", "class", "enum", "protocol", "actor", "typealias"}
)
MAX_INDENT_LEVEL = 8


def classify(token: Token, previous: str) -> str | None:
    if token.kind == "comment":
        return "com"
    if token.kind == "string":
        return "str"
    if token.kind == "number":
        return "num"
    if token.kind in {"attribute", "directive"}:
        return "kw"
    if token.kind != "identifier":
        return None
    if previous in DEFINERS:
        return "fn"
    if token.text in KEYWORDS:
        return "kw"
    if token.text in BUILTINS:
        return "bi"
    return "fn" if token.text[:1].isupper() else None


def highlight(source: str) -> str:
    """Return one line span per source line, with tokens wrapped."""
    lines: list[list[str]] = [[]]
    previous = ""
    for token in tokenize(source):
        css_class = classify(token, previous)
        if token.kind not in {"whitespace", "comment"}:
            previous = token.text
        for index, part in enumerate(token.text.split("\n")):
            if index:
                lines.append([])
            if not part:
                continue
            escaped = html.escape(part, quote=False)
            lines[-1].append(
                f'<span class="{css_class}">{escaped}</span>'
                if css_class
                else escaped
            )
    raw_lines = source.split("\n")
    rendered = []
    for raw, parts in zip(raw_lines, lines, strict=True):
        spaces = len(raw) - len(raw.lstrip(" "))
        level = min(spaces // 2, MAX_INDENT_LEVEL)
        rendered.append(
            f'<span class="line i{level}">{"".join(parts)}</span>'
        )
    return "".join(rendered)
