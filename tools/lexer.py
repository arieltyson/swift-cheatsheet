"""A small lexer for the Swift used in examples/.

It drives highlighting, definition extraction and the assert-to-result
rewrite. A string literal, including any \\( ) interpolation, is one
token, so brackets inside strings never confuse the bracket matching.
"""

import re
from dataclasses import dataclass

NUMBER = re.compile(
    r"0[xob][0-9a-fA-F_]+|\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?"
)
IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z0-9_]*|\$[A-Za-z0-9_]+|`[^`]+`")
WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


@dataclass(frozen=True, slots=True)
class Token:
    kind: str
    text: str
    start: int
    end: int


def tokenize(source: str) -> list[Token]:
    tokens: list[Token] = []
    position = 0
    while position < len(source):
        kind, end = _scan(source, position)
        tokens.append(Token(kind, source[position:end], position, end))
        position = end
    return tokens


def significant(tokens: list[Token]) -> list[Token]:
    return [t for t in tokens if t.kind not in {"whitespace", "comment"}]


def _scan(source: str, position: int) -> tuple[str, int]:
    char = source[position]
    if char.isspace():
        end = position
        while end < len(source) and source[end].isspace():
            end += 1
        return "whitespace", end
    if source.startswith("//", position):
        newline = source.find("\n", position)
        return "comment", len(source) if newline == -1 else newline
    if source.startswith("/*", position):
        return "comment", _scan_block_comment(source, position)
    raw = re.match(r"#+\"", source[position:])
    if char == '"' or raw:
        return "string", _scan_string(source, position)
    if char.isdigit():
        match = NUMBER.match(source, position)
        return "number", match.end()
    if char in "@#":
        match = WORD.match(source, position + 1)
        if match:
            kind = "attribute" if char == "@" else "directive"
            return kind, match.end()
    match = IDENTIFIER.match(source, position)
    if match:
        return "identifier", match.end()
    return "punctuation", position + 1


def _scan_block_comment(source: str, start: int) -> int:
    depth = 0
    index = start
    while index < len(source):
        if source.startswith("/*", index):
            depth += 1
            index += 2
        elif source.startswith("*/", index):
            depth -= 1
            index += 2
            if depth == 0:
                return index
        else:
            index += 1
    return len(source)


def _scan_string(source: str, start: int) -> int:
    pounds = len(source[start:]) - len(source[start:].lstrip("#"))
    index = start + pounds
    multiline = source.startswith('"""', index)
    quote = '"""' if multiline else '"'
    closing = quote + "#" * pounds
    interpolation = "\\" + "#" * pounds + "("
    index += len(quote)
    while index < len(source):
        if source.startswith(interpolation, index):
            index = _scan_interpolation(source, index + len(interpolation))
        elif source[index] == "\\" and pounds == 0:
            index += 2
        elif source.startswith(closing, index):
            return index + len(closing)
        elif source[index] == "\n" and not multiline:
            return index
        else:
            index += 1
    return len(source)


def _scan_interpolation(source: str, start: int) -> int:
    depth = 1
    index = start
    while index < len(source):
        char = source[index]
        if char == '"' or re.match(r"#+\"", source[index:]):
            index = _scan_string(source, index)
            continue
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return index + 1
        index += 1
    return len(source)
