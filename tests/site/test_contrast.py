"""Every text colour must pass WCAG 2.2 AA (4.5:1) where it is used."""

import unittest

from tools.build import WEB
from tools.tokens import load_tokens

MINIMUM_RATIO = 4.5
THEMES = {"light": 0, "dark": 1}
TEXT_ON = {
    "text": ["bg", "surface", "code-bg", "highlight"],
    "text-muted": ["bg", "surface", "code-bg"],
    "link": ["bg", "surface", "code-bg"],
}
SYNTAX = ["kw", "str", "num", "com", "fn", "bi"]


def channels(color: str) -> tuple[float, float, float, float]:
    digits = color.lstrip("#")
    alpha = int(digits[6:8], 16) / 255 if len(digits) == 8 else 1.0
    red, green, blue = (int(digits[i : i + 2], 16) for i in (0, 2, 4))
    return red, green, blue, alpha


def flatten(color: str, backdrop: str) -> tuple[float, float, float]:
    """Composite a possibly translucent colour over an opaque one."""
    *front, alpha = channels(color)
    *back, _ = channels(backdrop)
    return tuple(
        alpha * f + (1 - alpha) * b
        for f, b in zip(front, back, strict=True)
    )


def luminance(rgb: tuple[float, float, float]) -> float:
    def linear(channel: float) -> float:
        value = channel / 255
        if value <= 0.04045:
            return value / 12.92
        return ((value + 0.055) / 1.055) ** 2.4

    red, green, blue = (linear(channel) for channel in rgb)
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def contrast(first: tuple, second: tuple) -> float:
    lighter, darker = sorted(
        (luminance(first), luminance(second)), reverse=True
    )
    return (lighter + 0.05) / (darker + 0.05)


class ContrastTests(unittest.TestCase):
    tokens = load_tokens(WEB / "tokens.toml")

    def color(
        self, name: str, theme: str
    ) -> tuple[float, float, float]:
        page = self.tokens["bg"][THEMES[theme]]
        return flatten(self.tokens[name][THEMES[theme]], page)

    def assert_readable(self, foreground: str, background: str) -> None:
        for theme in THEMES:
            ratio = contrast(
                self.color(foreground, theme),
                self.color(background, theme),
            )
            with self.subTest(
                fg=foreground, bg=background, theme=theme
            ):
                self.assertGreaterEqual(ratio, MINIMUM_RATIO)

    def test_text_colors(self) -> None:
        for foreground, backgrounds in TEXT_ON.items():
            for background in backgrounds:
                self.assert_readable(foreground, background)

    def test_syntax_colors_on_code(self) -> None:
        for token in SYNTAX:
            self.assert_readable(token, "code-bg")

    def test_contrast_math(self) -> None:
        black, white = (0, 0, 0), (255, 255, 255)
        self.assertAlmostEqual(contrast(black, white), 21.0)
        self.assertAlmostEqual(contrast(white, white), 1.0)
        self.assertEqual(
            flatten("#FFFFFF80", "#000000")[0], 255 * 128 / 255
        )


if __name__ == "__main__":
    unittest.main()
