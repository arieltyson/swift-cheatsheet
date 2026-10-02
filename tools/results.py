"""Show demo asserts as `expression  // result` lines.

Example files keep real assert(...) calls so `swift test` checks every
documented result. On the page `assert(total == 3)` reads as
`total  // 3`, which is shorter and copies as working Swift.
"""

from tools.lexer import tokenize

MAX_LINE_LENGTH = 72
COMMENT_GAP = "  // "
OPENERS = {"(", "[", "{"}
CLOSERS = {")", "]", "}"}


def asserts_as_results(source: str) -> str:
    lines = source.split("\n")
    rewritten: dict[int, tuple[str, str, str]] = {}
    for index, line in enumerate(lines):
        parsed = _parse_assert(line)
        if parsed:
            rewritten[index] = parsed

    for run in _consecutive_runs(sorted(rewritten)):
        parts = [rewritten[index] for index in run]
        width = max(len(indent + expr) for indent, expr, _ in parts)
        fits = all(
            width + len(COMMENT_GAP) + len(result) <= MAX_LINE_LENGTH
            for _, _, result in parts
        )
        for index, (indent, expr, result) in zip(run, parts, strict=True):
            code = indent + expr
            padded = code.ljust(width) if fits else code
            lines[index] = f"{padded}{COMMENT_GAP}{result}"
    return "\n".join(lines)


def _parse_assert(line: str) -> tuple[str, str, str] | None:
    stripped = line.lstrip(" ")
    if not (stripped.startswith("assert(") and stripped.endswith(")")):
        return None
    indent = line[: len(line) - len(stripped)]
    inner = stripped[len("assert(") : -1]
    if not _is_single_argument(inner):
        return None
    split = _top_level_equals(inner)
    if split is None:
        return indent, inner.strip(), "true"
    left, right = split
    return indent, left, right


def _is_single_argument(text: str) -> bool:
    """True if brackets balance and there is no top-level comma."""
    depth = 0
    for token in tokenize(text):
        if token.kind != "punctuation":
            continue
        if token.text in OPENERS:
            depth += 1
        elif token.text in CLOSERS:
            depth -= 1
            if depth < 0:
                return False
        elif token.text == "," and depth == 0:
            return False
    return depth == 0


def _top_level_equals(text: str) -> tuple[str, str] | None:
    depth = 0
    tokens = tokenize(text)
    for index, token in enumerate(tokens):
        if token.kind != "punctuation":
            continue
        if token.text in OPENERS:
            depth += 1
        elif token.text in CLOSERS:
            depth -= 1
        elif token.text == "=" and depth == 0:
            following = tokens[index + 1] if index + 1 < len(tokens) else None
            before = text[token.start - 1] if token.start else ""
            if (
                following
                and following.text == "="
                and before not in "=!<>"
                and text[following.end : following.end + 1] != "="
            ):
                left = text[: token.start].strip()
                right = text[following.end :].strip()
                return left, right
    return None


def _consecutive_runs(indexes: list[int]) -> list[list[int]]:
    runs: list[list[int]] = []
    for index in indexes:
        if runs and runs[-1][-1] == index - 1:
            runs[-1].append(index)
        else:
            runs.append([index])
    return runs
