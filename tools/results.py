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
    lines = _expand_asserts(source.split("\n"))
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


def _expand_asserts(lines: list[str]) -> list[str]:
    """Give every assert one check per line, with no trailing note.

    A note after an assert (`assert(x)  // why`) moves to its own
    comment line above, and `assert(a == 1 && b == 2)` becomes one
    assert per condition, so each shows its own result.
    """
    expanded: list[str] = []
    for line in lines:
        stripped = line.lstrip(" ")
        indent = line[: len(line) - len(stripped)]
        if not stripped.startswith("assert("):
            expanded.append(line)
            continue
        code, note = _split_trailing_comment(stripped)
        if not code.endswith(")"):
            expanded.append(line)
            continue
        if note:
            expanded.append(f"{indent}{note}")
        inner = code[len("assert(") : -1]
        parts = _top_level_and(inner)
        if parts and _is_single_argument(inner):
            expanded.extend(f"{indent}assert({part})" for part in parts)
        else:
            expanded.append(f"{indent}{code}")
    return expanded


def _split_trailing_comment(text: str) -> tuple[str, str]:
    tokens = [t for t in tokenize(text) if t.kind != "whitespace"]
    if tokens and tokens[-1].kind == "comment":
        comment = tokens[-1]
        if comment.text.startswith("//"):
            return text[: comment.start].rstrip(), comment.text
    return text, ""


def _top_level_and(text: str) -> list[str] | None:
    depth = 0
    cuts: list[tuple[int, int]] = []
    tokens = tokenize(text)
    for index, token in enumerate(tokens):
        if token.kind != "punctuation":
            continue
        if token.text in OPENERS:
            depth += 1
        elif token.text in CLOSERS:
            depth -= 1
        elif (
            token.text == "&"
            and depth == 0
            and index + 1 < len(tokens)
            and tokens[index + 1].text == "&"
        ):
            cuts.append((token.start, tokens[index + 1].end))
    if not cuts:
        return None
    parts, start = [], 0
    for cut_start, cut_end in cuts:
        parts.append(text[start:cut_start].strip())
        start = cut_end
    parts.append(text[start:].strip())
    return parts


def _parse_assert(line: str) -> tuple[str, str, str] | None:
    stripped = line.lstrip(" ")
    if not (stripped.startswith("assert(") and stripped.endswith(")")):
        return None
    indent = line[: len(line) - len(stripped)]
    inner = stripped[len("assert(") : -1]
    if not _is_single_argument(inner):
        return None
    split = _top_level_equals(inner)
    if split is not None:
        left, right = split
        return indent, left, right
    inner = inner.strip()
    if inner.startswith("!") and not inner.startswith("!="):
        return indent, inner[1:], "false"
    return indent, inner, "true"


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
