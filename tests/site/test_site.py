import gzip
import json
import re
import sys
import tempfile
import unittest
from html.parser import HTMLParser
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))
import build


class Document(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = []
        self.anchors = []
        self.resources = []
        self.code = {}
        self.active_code = None
        self.tags = []

    def handle_starttag(self, tag, attributes):
        attributes = dict(attributes)
        self.tags.append((tag, attributes))
        if "id" in attributes:
            self.ids.append(attributes["id"])
        if tag == "a":
            self.anchors.append(attributes.get("href", ""))
        if tag in {"script", "link", "img", "iframe"}:
            self.resources.append(attributes.get("src", attributes.get("href", "")))
        if tag == "code" and attributes.get("id", "").startswith("code-"):
            self.active_code = attributes["id"]
            self.code[self.active_code] = ""

    def handle_endtag(self, tag):
        if tag == "code":
            self.active_code = None

    def handle_data(self, text):
        if self.active_code:
            self.code[self.active_code] += text


def luminance(color):
    channels = [int(color[index:index + 2], 16) / 255 for index in (1, 3, 5)]
    linear = [channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4 for channel in channels]
    return sum(channel * coefficient for channel, coefficient in zip(linear, [0.2126, 0.7152, 0.0722]))


def contrast(first, second):
    brighter, darker = sorted([luminance(first), luminance(second)], reverse=True)
    return (brighter + 0.05) / (darker + 0.05)


class SiteTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.directory = tempfile.TemporaryDirectory()
        cls.output = Path(cls.directory.name)
        cls.report = build.build(cls.output)
        cls.document = Document()
        cls.document.feed((cls.output / "index.html").read_text())

    @classmethod
    def tearDownClass(cls):
        cls.directory.cleanup()

    def test_all_anchors_resolve_and_ids_are_unique(self):
        self.assertEqual(len(self.document.ids), len(set(self.document.ids)))
        for anchor in self.document.anchors:
            if anchor.startswith("#"):
                self.assertIn(anchor[1:], self.document.ids)

    def test_rendered_code_is_exact_source(self):
        entries = build.load_entries()
        self.assertEqual(len(self.document.code), len(entries))
        for entry in entries:
            self.assertEqual(self.document.code[f"code-{entry['id']}"], entry["source"])

    def test_highlighting_preserves_text_and_escapes_html(self):
        for source in ['let text = "<script>alert(1)</script>"\n', 'let label = "Hello \\(name)"\n', 'let quoted = "a\\"b"\n', "// unicode é 👩🏽‍💻 & < >\n", 'let text = """\nhello\n"""\n']:
            document = Document()
            document.feed('<code id="code-test">' + build.highlight(source) + '</code>')
            self.assertEqual(document.code["code-test"], source)
            self.assertFalse(any(tag == "script" for tag, _ in document.tags))

    def test_content_remains_static_and_visible(self):
        forbidden = {"details", "dialog", "iframe"}
        for tag, attributes in self.document.tags:
            self.assertNotIn(tag, forbidden)
            self.assertNotIn(attributes.get("role"), {"tab", "tabpanel"})
            if "hidden" in attributes:
                self.assertEqual(tag, "button")
            self.assertNotEqual(attributes.get("aria-hidden"), "true" if tag in {"article", "pre", "code", "section"} else "impossible")
        self.assertEqual(sum(tag == "h1" for tag, _ in self.document.tags), 1)
        self.assertEqual(sum(tag == "main" for tag, _ in self.document.tags), 1)

    def test_artifact_contains_only_public_files(self):
        self.assertEqual({filename.name for filename in self.output.iterdir()}, {"index.html", "styles.css", "app.js", "favicon.svg", ".nojekyll"})
        self.assertTrue(all(resource.startswith("./") for resource in self.document.resources))
        self.assertLess(self.report["gzipTotal"], 150_000)
        self.assertLess(len(gzip.compress((self.output / "app.js").read_bytes())), 10_000)
        script = (self.output / "app.js").read_text()
        for forbidden in ["fetch(", "localStorage", "sessionStorage", "innerHTML", "readText", "eval(", "setInterval", "keydown"]:
            self.assertNotIn(forbidden, script)

    def test_deterministic_build(self):
        before = {filename.name: filename.read_bytes() for filename in self.output.iterdir()}
        build.build(self.output)
        self.assertEqual(before, {filename.name: filename.read_bytes() for filename in self.output.iterdir()})

    def test_palette_contrast(self):
        palettes = json.loads((ROOT / "web/tokens.json").read_text())
        for mode, palette in palettes.items():
            for foreground in ["text", "muted", "accent", "keyword", "string", "number", "type"]:
                for background in ["background", "surface", "code"]:
                    with self.subTest(mode=mode, foreground=foreground, background=background):
                        self.assertGreaterEqual(contrast(palette[foreground], palette[background]), 4.5)
            for foreground in ["focus", "line"]:
                for background in ["background", "surface", "code"]:
                    with self.subTest(mode=mode, foreground=foreground, background=background):
                        self.assertGreaterEqual(contrast(palette[foreground], palette[background]), 3)

    def test_manifest_rejects_invalid_entries(self):
        original = json.loads((ROOT / "content/entries.json").read_text())
        changes = [
            lambda entries: entries[0].update(id=entries[1]["id"]),
            lambda entries: entries[0].update(file="../outside.swift"),
            lambda entries: entries[0].update(summary=""),
            lambda entries: entries[0].update(domain="unknown"),
            lambda entries: entries[0].update(dependencies=["missing-topic"]),
            lambda entries: entries[0].update(sources=[{"label": "Bad", "url": "javascript:alert(1)"}]),
        ]
        for change in changes:
            entries = json.loads(json.dumps(original))
            change(entries)
            with patch.object(build.json, "loads", return_value=entries):
                with self.assertRaises(ValueError):
                    build.load_entries()

    def test_no_placeholder_or_private_content(self):
        public = (self.output / "index.html").read_text()
        for forbidden in ["TODO", "[Insert", "docs.google.com/document", "SweatBot", "sk-proj-", "ghp_"]:
            self.assertNotIn(forbidden, public)
        for entry in build.load_entries():
            for alias in entry["aliases"]:
                self.assertIn(build.escape(alias), public)


if __name__ == "__main__":
    unittest.main()
