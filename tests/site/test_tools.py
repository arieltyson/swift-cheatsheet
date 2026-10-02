import html
import re
import unittest

from tools.highlight import highlight
from tools.lexer import significant, tokenize
from tools.manifest import CodeRef
from tools.results import asserts_as_results
from tools.source import extract_from_source


def kinds(source: str) -> list[str]:
    return [f"{t.kind}:{t.text}" for t in significant(tokenize(source))]


class LexerTests(unittest.TestCase):
    def test_tokens_cover_the_source(self) -> None:
        source = (
            'let label = "a \\(b ? "c)" : "d") e" // done\n'
            '/* outer /* inner */ still */ let raw = #"\\n "q" "#\n'
            'let text = """\n  multi "line"\n  """\n'
        )
        joined = "".join(t.text for t in tokenize(source))
        self.assertEqual(joined, source)

    def test_interpolation_is_part_of_the_string(self) -> None:
        self.assertEqual(
            kinds('"\\(f(")"))" + x'),
            ['string:"\\(f(")"))"', "punctuation:+", "identifier:x"],
        )

    def test_nested_block_comments(self) -> None:
        self.assertEqual(
            kinds("/* a /* b */ c */ x"), ["identifier:x"]
        )

    def test_raw_and_multiline_strings(self) -> None:
        self.assertEqual(kinds('#"a"b"#'), ['string:#"a"b"#'])
        self.assertEqual(
            kinds('"""\n"quoted"\n"""'), ['string:"""\n"quoted"\n"""']
        )

    def test_numbers_ranges_attributes_and_projections(self) -> None:
        self.assertEqual(
            kinds("@State var x = 0...1_000 + $count + 0x1F"),
            [
                "attribute:@State",
                "identifier:var",
                "identifier:x",
                "punctuation:=",
                "number:0",
                "punctuation:.",
                "punctuation:.",
                "punctuation:.",
                "number:1_000",
                "punctuation:+",
                "identifier:$count",
                "punctuation:+",
                "number:0x1F",
            ],
        )


SAMPLE = """\
import Foundation

/// Returns the sum.
@inlinable
func add(_ left: Int, _ right: Int) -> Int {
  let braces = "}{"
  return left + right
}

func demoNumbers() {
  // Comments stay
  let total = add(1, 2)
  assert(total == 3)
}

@MainActor
final class Box<Value> {
  var value: Value
  init(_ value: Value) { self.value = value }
}

typealias Pair = (first: Int, second: Int)

/// Shared behaviour.
extension Box {
  var isSet: Bool { true }
}
"""


class ExtractTests(unittest.TestCase):
    def extract(self, name: str) -> str:
        return extract_from_source(SAMPLE, CodeRef("s.swift", name))

    def test_function_keeps_doc_comment_and_attributes(self) -> None:
        self.assertEqual(
            self.extract("add").splitlines(),
            [
                "/// Returns the sum.",
                "@inlinable",
                "func add(_ left: Int, _ right: Int) -> Int {",
                '  let braces = "}{"',
                "  return left + right",
                "}",
            ],
        )

    def test_demo_is_body_only(self) -> None:
        self.assertEqual(
            self.extract("demoNumbers").splitlines(),
            ["// Comments stay", "let total = add(1, 2)", "assert(total == 3)"],
        )

    def test_class_with_modifiers(self) -> None:
        box = self.extract("Box")
        self.assertTrue(box.startswith("@MainActor\nfinal class Box<Value> {"))
        self.assertTrue(box.endswith("\n}"))

    def test_type_includes_its_extensions(self) -> None:
        box = self.extract("Box")
        self.assertIn("}\n\n/// Shared behaviour.\nextension Box {", box)
        self.assertTrue(box.endswith("var isSet: Bool { true }\n}"))

    def test_typealias(self) -> None:
        self.assertEqual(
            self.extract("Pair"), "typealias Pair = (first: Int, second: Int)"
        )

    def test_missing(self) -> None:
        with self.assertRaises(LookupError):
            self.extract("missing")


class ResultsTests(unittest.TestCase):
    def test_equality_becomes_a_result(self) -> None:
        self.assertEqual(
            asserts_as_results("assert(values.count == 3)"),
            "values.count  // 3",
        )

    def test_aligns_runs(self) -> None:
        self.assertEqual(
            asserts_as_results(
                'assert(text.count == 5)\nassert(text.uppercased() == "HI")'
            ).splitlines(),
            ["text.count         // 5", 'text.uppercased()  // "HI"'],
        )

    def test_boolean_assert_shows_true(self) -> None:
        self.assertEqual(
            asserts_as_results("assert(seen.contains(3))"),
            "seen.contains(3)  // true",
        )

    def test_equals_inside_closures_is_ignored(self) -> None:
        self.assertEqual(
            asserts_as_results("assert(values.filter { $0 == 2 } == [2])"),
            "values.filter { $0 == 2 }  // [2]",
        )

    def test_leaves_messages_and_other_operators(self) -> None:
        source = 'assert(x == 1, "why")\nassert(a === b)\nassert(a != b)'
        self.assertEqual(
            asserts_as_results(source).splitlines(),
            [
                'assert(x == 1, "why")',
                "a === b  // true",
                "a != b   // true",
            ],
        )


class HighlightTests(unittest.TestCase):
    def plain(self, rendered: str) -> list[str]:
        lines = re.findall(
            r'<span class="line i\d">(.*?)</span>(?=<span class="line|$)',
            rendered,
        )
        return [html.unescape(re.sub(r"<[^>]+>", "", line)) for line in lines]

    def test_round_trips(self) -> None:
        self.assertEqual(self.plain(highlight(SAMPLE)), SAMPLE.split("\n"))

    def test_classifies_tokens(self) -> None:
        rendered = highlight(
            '@State var total: Int = max(1, 2) // ok\nstruct Box {}\n"s"'
        )
        for expected in [
            '<span class="kw">@State</span>',
            '<span class="kw">var</span>',
            '<span class="bi">Int</span>',
            '<span class="bi">max</span>',
            '<span class="num">1</span>',
            '<span class="com">// ok</span>',
            '<span class="fn">Box</span>',
            '<span class="str">"s"</span>',
        ]:
            self.assertIn(expected, rendered)

    def test_escapes_html(self) -> None:
        rendered = highlight('let tag = "<b>"')
        self.assertNotIn("<b>", rendered)


if __name__ == "__main__":
    unittest.main()
