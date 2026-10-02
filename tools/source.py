"""Extract a Swift declaration's source by name, as the page shows it.

Attributes, modifiers and /// comments above a declaration are kept.
Functions named demo* are shown as their body only.
"""

import textwrap
from pathlib import Path

from tools.lexer import Token, significant, tokenize
from tools.manifest import CodeRef

DECLARATIONS = {
    "func",
    "struct",
    "class",
    "enum",
    "protocol",
    "actor",
    "typealias",
}
MODIFIERS = {
    "final",
    "private",
    "fileprivate",
    "public",
    "internal",
    "static",
    "mutating",
    "nonisolated",
    "override",
    "indirect",
}
CLOSERS = {"(": ")", "[": "]", "{": "}"}


class SnippetNotFoundError(LookupError):
    """Raised when a manifest code ref names a missing declaration."""


def extract(snippets_root: Path, ref: CodeRef) -> str:
    source = (snippets_root / ref.path).read_text(encoding="utf-8")
    return extract_from_source(source, ref)


def extract_from_source(source: str, ref: CodeRef) -> str:
    tokens = tokenize(source)
    code = significant(tokens)
    keyword_index = _find_declaration(code, ref.name)
    if keyword_index == -1:
        raise SnippetNotFoundError(f"{ref.path} has no {ref.name}")
    first = code[_first_modifier(code, keyword_index)]
    body_start, end = _extent(source, code, keyword_index)
    if ref.is_demo:
        body = source[body_start + 1 : end - 1]
        return textwrap.dedent(body).strip("\n")
    start = _leading_comment_start(tokens, first)
    line_start = source.rfind("\n", 0, start) + 1
    return source[line_start:end]


def _find_declaration(code: list[Token], name: str) -> int:
    depth = 0
    for index, token in enumerate(code):
        if token.kind == "punctuation" and token.text in CLOSERS:
            depth += 1
        elif token.kind == "punctuation" and token.text in ")]}":
            depth -= 1
        elif (
            depth == 0
            and token.text in DECLARATIONS
            and index + 1 < len(code)
            and code[index + 1].text == name
        ):
            return index
    return -1


def _first_modifier(code: list[Token], keyword_index: int) -> int:
    index = keyword_index
    while index > 0:
        previous = code[index - 1]
        if previous.kind == "attribute" or previous.text in MODIFIERS:
            index -= 1
        elif previous.text == ")":
            opener = _matching_open(code, index - 1)
            if opener > 0 and code[opener - 1].kind == "attribute":
                index = opener - 1
            else:
                break
        else:
            break
    return index


def _matching_open(code: list[Token], close_index: int) -> int:
    depth = 0
    for index in range(close_index, -1, -1):
        if code[index].text == ")":
            depth += 1
        elif code[index].text == "(":
            depth -= 1
            if depth == 0:
                return index
    return -1


def _extent(
    source: str, code: list[Token], keyword_index: int
) -> tuple[int, int]:
    if code[keyword_index].text == "typealias":
        newline = source.find("\n", code[keyword_index].start)
        return -1, len(source) if newline == -1 else newline
    stack: list[str] = []
    body_start = -1
    for token in code[keyword_index + 1 :]:
        if token.kind != "punctuation":
            continue
        if token.text in CLOSERS:
            if token.text == "{" and not stack and body_start == -1:
                body_start = token.start
            stack.append(CLOSERS[token.text])
        elif stack and token.text == stack[-1]:
            stack.pop()
            if not stack and token.text == "}" and body_start != -1:
                return body_start, token.end
    raise SnippetNotFoundError("unterminated declaration")


def _leading_comment_start(tokens: list[Token], first: Token) -> int:
    start = first.start
    for token in reversed(tokens[: tokens.index(first)]):
        if token.kind == "comment" and token.text.startswith("///"):
            start = token.start
        elif token.kind != "whitespace" or token.text.count("\n") > 1:
            break
    return start
