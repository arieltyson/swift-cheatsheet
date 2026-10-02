"""Content rules that keep every example interview-ready."""

import re
import unittest
from pathlib import Path

from tools.build import MANIFEST, ROOT, SNIPPETS
from tools.lexer import significant, tokenize
from tools.manifest import load_site
from tools.source import extract

ALLOWED_IMPORTS = {
    "dsa": {"Foundation"},
    "swiftui": {"SwiftUI", "Observation", "Foundation", "UIKit"},
    "uikit": {"UIKit", "Foundation", "SwiftUI"},
    "concurrency": {"Foundation", "Dispatch", "Combine", "Synchronization"},
}
DECLARATIONS = {"func", "struct", "class", "enum", "protocol", "typealias"}
MAX_LINE_LENGTH = 72
MAX_FUNCTION_LINES = 25


def example_files() -> list[Path]:
    return sorted(SNIPPETS.rglob("*.swift"))


def top_level_names(source: str) -> list[str]:
    names = []
    depth = 0
    code = significant(tokenize(source))
    for index, token in enumerate(code):
        if token.text in "{([":
            depth += 1
        elif token.text in "})]":
            depth -= 1
        elif depth == 0 and token.text in DECLARATIONS:
            names.append(code[index + 1].text)
    return names


class ExampleRulesTests(unittest.TestCase):
    def test_imports_stay_in_each_section(self) -> None:
        for path in example_files():
            domain = path.parent.name
            imports = re.findall(r"^import (\w+)", path.read_text(), re.M)
            for module in imports:
                with self.subTest(file=path.name, module=module):
                    self.assertIn(module, ALLOWED_IMPORTS[domain])

    def test_lines_fit_a_half_width_window(self) -> None:
        for path in example_files():
            for number, line in enumerate(path.read_text().splitlines(), 1):
                with self.subTest(file=path.name, line=number):
                    self.assertLessEqual(len(line), MAX_LINE_LENGTH)

    def test_dsa_functions_fit_one_glance(self) -> None:
        for path in sorted((SNIPPETS / "dsa").glob("*.swift")):
            source = path.read_text()
            for name in top_level_names(source):
                body = re.search(
                    rf"^func {name}\b[\s\S]*?^}}$", source, re.M
                )
                if body:
                    count = body.group().count("\n") + 1
                    with self.subTest(file=path.name, name=name):
                        self.assertLessEqual(count, MAX_FUNCTION_LINES)


class ManifestCoverageTests(unittest.TestCase):
    site = load_site(MANIFEST, SNIPPETS)

    def test_every_code_ref_resolves(self) -> None:
        for entry in self.site.entries():
            for ref in entry.code:
                with self.subTest(entry=entry.id, ref=ref.name):
                    self.assertTrue(extract(SNIPPETS, ref).strip())

    def test_every_declaration_is_on_the_page(self) -> None:
        shown = {
            (ref.path, ref.name)
            for entry in self.site.entries()
            for ref in entry.code
        }
        for path in example_files():
            relative = path.relative_to(SNIPPETS).as_posix()
            for name in top_level_names(path.read_text()):
                self.assertTrue(
                    (relative, name) in shown,
                    f"{relative}:{name} is not in site.toml",
                )

    def test_every_demo_runs_in_swift_test(self) -> None:
        dsa_tests = (ROOT / "tests/swift/DemoTests.swift").read_text()
        for path in sorted((SNIPPETS / "dsa").glob("*.swift")):
            for name in top_level_names(path.read_text()):
                if name.startswith("demo"):
                    self.assertIn(f", {name})", dsa_tests, name)
        concurrency_tests = "".join(
            path.read_text()
            for path in (ROOT / "tests/concurrency").glob("*.swift")
        )
        for path in sorted((SNIPPETS / "concurrency").glob("*.swift")):
            for name in top_level_names(path.read_text()):
                if name.startswith("demo"):
                    self.assertIn(f"{name}()", concurrency_tests, name)


if __name__ == "__main__":
    unittest.main()
