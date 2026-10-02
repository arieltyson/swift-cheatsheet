"""Read web/tokens.toml and emit the CSS custom properties."""

import re
import tomllib
from pathlib import Path

HEX_COLOR = re.compile(r"^#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?$")


def load_tokens(path: Path) -> dict[str, tuple[str, str]]:
    """Return {name: (light, dark)} for every colour token."""
    with path.open("rb") as tokens_file:
        data = tomllib.load(tokens_file)
    tokens: dict[str, tuple[str, str]] = {}
    for group in ("color", "syntax"):
        for name, pair in data[group].items():
            if len(pair) != 2 or not all(map(HEX_COLOR.match, pair)):
                raise ValueError(f"{name}: expected [light, dark] hex")
            tokens[name] = (pair[0], pair[1])
    return tokens


def css_variables(tokens: dict[str, tuple[str, str]]) -> str:
    lines = [
        f"  --{name}: light-dark({light}, {dark});"
        for name, (light, dark) in tokens.items()
    ]
    return ":root {\n" + "\n".join(lines) + "\n}\n"
