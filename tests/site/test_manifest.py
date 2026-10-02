import tempfile
import unittest
from pathlib import Path

from tools.manifest import ManifestError, parse_site


def site_with(entry: dict) -> dict:
    return {
        "part": [
            {
                "id": "algorithms",
                "title": "Algorithms",
                "section": [
                    {
                        "id": "search",
                        "title": "Search",
                        "entry": [entry],
                    }
                ],
            }
        ]
    }


class ParseSiteTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        (self.root / "search.py").write_text("def find(): ...\n")

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def test_parses_valid_code_entry(self) -> None:
        site = parse_site(
            site_with(
                {
                    "id": "binary-search",
                    "title": "Binary search",
                    "aliases": ["bisect"],
                    "code": ["search.py:find"],
                    "time": "O(log n)",
                    "space": "O(1)",
                }
            ),
            self.root,
        )
        (entry,) = site.entries()
        self.assertEqual(entry.code[0].name, "find")
        self.assertEqual(entry.aliases, ("bisect",))

    def test_parses_table_entry(self) -> None:
        site = parse_site(
            site_with(
                {
                    "id": "costs",
                    "title": "Costs",
                    "table": {
                        "header": ["Op", "Cost"],
                        "rows": [["a", "b"]],
                    },
                }
            ),
            self.root,
        )
        self.assertEqual(site.entries()[0].table.rows, (("a", "b"),))

    def test_rejects_duplicate_ids(self) -> None:
        data = site_with(
            {
                "id": "search",
                "title": "Dup",
                "code": ["search.py:demo_x"],
            }
        )
        with self.assertRaisesRegex(ManifestError, "duplicate"):
            parse_site(data, self.root)

    def test_rejects_algorithm_without_complexity(self) -> None:
        data = site_with(
            {"id": "find", "title": "Find", "code": ["search.py:find"]}
        )
        with self.assertRaisesRegex(ManifestError, "time/space or"):
            parse_site(data, self.root)

    def test_allows_demo_without_complexity(self) -> None:
        data = site_with(
            {
                "id": "find",
                "title": "Find",
                "code": ["search.py:demo_x"],
            }
        )
        self.assertIsNone(parse_site(data, self.root).entries()[0].time)

    def test_rejects_missing_snippet_file(self) -> None:
        data = site_with(
            {
                "id": "find",
                "title": "Find",
                "code": ["missing.py:demo_x"],
            }
        )
        with self.assertRaisesRegex(ManifestError, "not found"):
            parse_site(data, self.root)

    def test_rejects_unknown_keys(self) -> None:
        data = site_with(
            {
                "id": "find",
                "title": "Find",
                "code": ["search.py:demo_x"],
                "gotchas": "typo",
            }
        )
        with self.assertRaisesRegex(ManifestError, "unknown keys"):
            parse_site(data, self.root)

    def test_rejects_entry_with_code_and_table(self) -> None:
        data = site_with(
            {
                "id": "find",
                "title": "Find",
                "code": ["search.py:demo_x"],
                "table": {"header": ["a"], "rows": [["b"]]},
            }
        )
        with self.assertRaisesRegex(ManifestError, "exactly one"):
            parse_site(data, self.root)

    def test_rejects_ragged_table(self) -> None:
        data = site_with(
            {
                "id": "costs",
                "title": "Costs",
                "table": {"header": ["a", "b"], "rows": [["only one"]]},
            }
        )
        with self.assertRaisesRegex(ManifestError, "match the header"):
            parse_site(data, self.root)


if __name__ == "__main__":
    unittest.main()
