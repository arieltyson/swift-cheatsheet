from __future__ import annotations

import gzip
import html
import json
import re
import shutil
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
DOMAINS = {"dsa": "Pure DSA Swift", "swiftui": "SwiftUI", "uikit": "UIKit"}
ALLOWED_IMPORTS = {
    "dsa": {"Foundation"},
    "swiftui": {"SwiftUI", "Observation", "Foundation", "UIKit"},
    "uikit": {"UIKit", "Foundation", "SwiftUI"},
}
KEYWORDS = set("actor any as associatedtype async await break case catch class continue convenience default defer deinit do else enum extension false fileprivate final for func get guard if import in indirect init inout internal is let mutating nil nonisolated open override private protocol public repeat required rethrows return self set some static struct subscript super switch throws throw true try typealias var weak where while".split())
TOKEN = re.compile(r'"(?:\\.|[^"\\])*"|\b\d+(?:\.\d+)?\b|\b[A-Za-z_][A-Za-z_0-9]*\b')


def escape(value: str) -> str:
    return html.escape(value, quote=True)


def highlight(source: str) -> str:
    parts = []
    cursor = 0
    for match in TOKEN.finditer(source):
        parts.append(escape(source[cursor:match.start()]))
        value = match.group()
        category = ""
        if value.startswith('"'):
            category = "string"
        elif value[0].isdigit():
            category = "number"
        elif value in KEYWORDS:
            category = "keyword"
        elif value[0].isupper():
            category = "type"
        encoded = escape(value)
        parts.append(f'<span class="{category}">{encoded}</span>' if category else encoded)
        cursor = match.end()
    parts.append(escape(source[cursor:]))
    return "".join(parts)


def load_entries() -> list[dict]:
    entries = json.loads((ROOT / "content/entries.json").read_text())
    seen = set(DOMAINS) | {"main", "top", "contents", "privacy", "accessibility", "costs"}
    for entry in entries:
        required = {"id", "domain", "title", "aliases", "summary", "file", "expected", "note", "pitfall", "availability", "sources", "validation", "prerequisites"}
        if not required <= entry.keys() or any(not entry[key] for key in required):
            raise ValueError(f"Incomplete entry: {entry.get('id')}")
        if entry["domain"] not in DOMAINS or not re.fullmatch(r"[a-z][a-z0-9-]*", entry["id"]):
            raise ValueError("Invalid domain or anchor")
        if entry["id"] in seen:
            raise ValueError(f"Duplicate anchor: {entry['id']}")
        seen.add(entry["id"])
        source_path = (ROOT / entry["file"]).resolve()
        domain_root = (ROOT / "examples" / entry["domain"]).resolve()
        if not source_path.is_relative_to(domain_root) or source_path.suffix != ".swift":
            raise ValueError("Snippet path outside its domain")
        source = source_path.read_text()
        imports = set(re.findall(r"^import\s+(\w+)", source, re.MULTILINE))
        if not imports <= ALLOWED_IMPORTS[entry["domain"]]:
            raise ValueError(f"Forbidden import in {entry['id']}")
        if entry["domain"] == "dsa" and not {"time", "space", "output"} <= entry.keys():
            raise ValueError("DSA complexity is required")
        for reference in entry["sources"]:
            parsed = urlparse(reference["url"])
            if parsed.scheme != "https" or parsed.hostname not in {"developer.apple.com", "docs.swift.org", "www.swift.org"}:
                raise ValueError("Use official Swift/Apple source links")
        entry["source"] = source
    if {entry["domain"] for entry in entries} != set(DOMAINS):
        raise ValueError("All three domains are required")
    identifiers = {entry["id"] for entry in entries}
    for entry in entries:
        for dependency in entry.get("dependencies", []):
            if dependency not in identifiers:
                raise ValueError(f"Missing dependency: {dependency}")
    actual = {str(filename.relative_to(ROOT)) for filename in (ROOT / "examples").rglob("*.swift")}
    if actual != {entry["file"] for entry in entries} or len(actual) != len(entries):
        raise ValueError("Every snippet must have exactly one entry")
    return entries


def render_entry(entry: dict) -> str:
    identifier = escape(entry["id"])
    sources = " · ".join(f'<a href="{escape(reference["url"])}">{escape(reference["label"])}</a>' for reference in entry["sources"])
    dependencies = "".join(f'<a href="#{escape(dependency)}">{escape(dependency.replace("-", " "))}</a> ' for dependency in entry.get("dependencies", []))
    complexity = ""
    if entry["domain"] == "dsa":
        complexity = f'<dl class="complexity"><div><dt>Time</dt><dd>{escape(entry["time"])}</dd></div><div><dt>Auxiliary</dt><dd>{escape(entry["space"])}</dd></div><div><dt>Output</dt><dd>{escape(entry["output"])}</dd></div></dl>'
    return f'''<article class="entry" id="{identifier}" aria-labelledby="title-{identifier}">
<div class="entry-heading"><h3 id="title-{identifier}"><a href="#{identifier}">{escape(entry['title'])}</a></h3><span class="entry-number">{escape(entry['domain'].upper())}</span></div>
<p class="aliases">{escape(' / '.join(entry['aliases']))}</p>
<p class="answer">{escape(entry['summary'])}</p>
<p class="requirements">{escape(entry['availability'])} · {escape(entry['prerequisites'])} {dependencies}</p>
<div class="code-heading"><span>SWIFT</span><span class="copy-actions"><span class="copy-status" role="status" aria-live="polite" aria-atomic="true"></span><button class="copy" type="button" data-copy="code-{identifier}" aria-label="Copy {escape(entry['title'])} code" hidden>Copy code</button></span></div>
<pre tabindex="0" aria-label="{escape(entry['title'])} Swift code"><code id="code-{identifier}">{highlight(entry['source'])}</code></pre>
<p class="expected"><strong>Try it</strong> <code>{escape(entry['expected'])}</code></p>
{complexity}<p>{escape(entry['note'])}</p>
<p class="pitfall"><strong>Watch for</strong> {escape(entry['pitfall'])}</p>
<p class="sources">{sources} <span>· {escape(entry['validation'])}</span></p>
</article>'''


def build(output: Path | None = None) -> dict:
    entries = load_entries()
    output = output or ROOT / "dist"
    output.mkdir(parents=True, exist_ok=True)
    for obsolete in output.iterdir():
        if obsolete.is_file():
            obsolete.unlink()
    tokens = json.loads((ROOT / "web/tokens.json").read_text())
    def variables(mode: str) -> str:
        return ";".join(f"--{name}:{value}" for name, value in tokens[mode].items())
    stylesheet = f":root{{{variables('light')}}}\n@media(prefers-color-scheme:dark){{:root{{{variables('dark')}}}}}\n" + (ROOT / "web/styles.css").read_text()
    (output / "styles.css").write_text(stylesheet)
    sections = []
    contents = []
    for number, (domain, title) in enumerate(DOMAINS.items(), 1):
        selected = [entry for entry in entries if entry["domain"] == domain]
        links = "".join(f'<li><a href="#{escape(entry["id"])}">{escape(entry["title"])}</a></li>' for entry in selected)
        contents.append(f'<div class="contents-group"><h3><a href="#{domain}">{escape(title)}</a></h3><ul>{links}</ul></div>')
        sections.append(f'<section id="{domain}" aria-labelledby="heading-{domain}"><div class="section-heading"><span class="section-number">0{number}</span><h2 id="heading-{domain}">{escape(title)}</h2><a href="#contents">Index ↑</a></div>{"".join(render_entry(entry) for entry in selected)}</section>')
    page = (ROOT / "web/template.html").read_text().replace("{{CONTENTS}}", "".join(contents)).replace("{{SECTIONS}}", "".join(sections)).replace("{{COUNT}}", str(len(entries)))
    (output / "index.html").write_text(page)
    for filename in ["app.js", "favicon.svg"]:
        shutil.copyfile(ROOT / "web" / filename, output / filename)
    (output / ".nojekyll").write_text("")
    sizes = {filename.name: {"bytes": filename.stat().st_size, "gzip": len(gzip.compress(filename.read_bytes(), mtime=0))} for filename in sorted(output.iterdir()) if filename.is_file()}
    total = sum(value["gzip"] for value in sizes.values())
    if total > 150_000 or sizes["app.js"]["gzip"] > 10_000:
        raise ValueError("Public artifact exceeds performance budget")
    return {"entries": len(entries), "gzipTotal": total, "files": sizes}


if __name__ == "__main__":
    print(json.dumps(build(), indent=2))
