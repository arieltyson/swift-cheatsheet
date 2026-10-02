"""Load and validate content/site.toml into typed objects."""

import re
import tomllib
from dataclasses import dataclass
from pathlib import Path

ID_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
DEMO_PREFIX = "demo"


class ManifestError(ValueError):
    """Raised when site.toml breaks a content rule."""


@dataclass(frozen=True, slots=True)
class CodeRef:
    path: str
    name: str

    @property
    def is_demo(self) -> bool:
        return self.name.startswith(DEMO_PREFIX)

    @property
    def is_type(self) -> bool:
        return self.name[:1].isupper()


@dataclass(frozen=True, slots=True)
class Table:
    header: tuple[str, ...]
    rows: tuple[tuple[str, ...], ...]


@dataclass(frozen=True, slots=True)
class Entry:
    id: str
    title: str
    aliases: tuple[str, ...]
    code: tuple[CodeRef, ...]
    table: Table | None
    time: str | None
    space: str | None
    use_when: str | None
    gotcha: str | None
    availability: str | None


@dataclass(frozen=True, slots=True)
class Section:
    id: str
    title: str
    group: str | None
    intro: str | None
    entries: tuple[Entry, ...]


@dataclass(frozen=True, slots=True)
class Part:
    id: str
    title: str
    sections: tuple[Section, ...]


@dataclass(frozen=True, slots=True)
class Site:
    parts: tuple[Part, ...]

    def entries(self) -> list[Entry]:
        return [
            entry
            for part in self.parts
            for section in part.sections
            for entry in section.entries
        ]


PART_KEYS = {"id", "title", "section"}
SECTION_KEYS = {"id", "title", "group", "intro", "entry"}
ENTRY_KEYS = {
    "id",
    "title",
    "aliases",
    "code",
    "table",
    "time",
    "space",
    "use_when",
    "gotcha",
    "availability",
}


def load_site(manifest_path: Path, snippets_root: Path) -> Site:
    with manifest_path.open("rb") as manifest_file:
        data = tomllib.load(manifest_file)
    return parse_site(data, snippets_root)


def parse_site(data: dict, snippets_root: Path) -> Site:
    seen_ids: set[str] = set()
    parts = tuple(
        _parse_part(part, snippets_root, seen_ids)
        for part in data.get("part", [])
    )
    if not parts:
        raise ManifestError("site.toml defines no [[part]] tables")
    return Site(parts)


def _claim_id(value: object, where: str, seen_ids: set[str]) -> str:
    if not isinstance(value, str) or not ID_PATTERN.match(value):
        raise ManifestError(f"{where}: id {value!r} is not kebab-case")
    if value in seen_ids:
        raise ManifestError(f"{where}: duplicate id {value!r}")
    seen_ids.add(value)
    return value


def _check_keys(table: dict, allowed: set[str], where: str) -> None:
    if unknown := set(table) - allowed:
        raise ManifestError(f"{where}: unknown keys {sorted(unknown)}")


def _required_text(table: dict, key: str, where: str) -> str:
    value = table.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ManifestError(f"{where}: {key!r} must be non-empty text")
    return value


def _optional_text(table: dict, key: str, where: str) -> str | None:
    if key not in table:
        return None
    return _required_text(table, key, where)


def _parse_part(
    part: dict, snippets_root: Path, seen_ids: set[str]
) -> Part:
    where = f"part {part.get('id')!r}"
    _check_keys(part, PART_KEYS, where)
    part_id = _claim_id(part.get("id"), where, seen_ids)
    sections = tuple(
        _parse_section(section, snippets_root, seen_ids)
        for section in part.get("section", [])
    )
    if not sections:
        raise ManifestError(f"{where}: has no sections")
    return Part(part_id, _required_text(part, "title", where), sections)


def _parse_section(
    section: dict, snippets_root: Path, seen_ids: set[str]
) -> Section:
    where = f"section {section.get('id')!r}"
    _check_keys(section, SECTION_KEYS, where)
    section_id = _claim_id(section.get("id"), where, seen_ids)
    entries = tuple(
        _parse_entry(entry, snippets_root, seen_ids)
        for entry in section.get("entry", [])
    )
    if not entries:
        raise ManifestError(f"{where}: has no entries")
    return Section(
        section_id,
        _required_text(section, "title", where),
        _optional_text(section, "group", where),
        _optional_text(section, "intro", where),
        entries,
    )


def _parse_entry(
    entry: dict, snippets_root: Path, seen_ids: set[str]
) -> Entry:
    where = f"entry {entry.get('id')!r}"
    _check_keys(entry, ENTRY_KEYS, where)
    entry_id = _claim_id(entry.get("id"), where, seen_ids)
    code = tuple(
        _parse_code_ref(ref, snippets_root, where)
        for ref in entry.get("code", [])
    )
    table = (
        _parse_table(entry["table"], where)
        if "table" in entry
        else None
    )
    if bool(code) == bool(table):
        raise ManifestError(
            f"{where}: needs exactly one of code or table"
        )

    time = _optional_text(entry, "time", where)
    space = _optional_text(entry, "space", where)
    if (time is None) != (space is None):
        raise ManifestError(
            f"{where}: give both time and space, or neither"
        )
    is_reference = all(ref.is_demo or ref.is_type for ref in code)
    if code and not is_reference and time is None:
        raise ManifestError(
            f"{where}: algorithm entries need time/space"
        )

    aliases = entry.get("aliases", [])
    if not all(isinstance(alias, str) for alias in aliases):
        raise ManifestError(f"{where}: aliases must be strings")

    return Entry(
        id=entry_id,
        title=_required_text(entry, "title", where),
        aliases=tuple(aliases),
        code=code,
        table=table,
        time=time,
        space=space,
        use_when=_optional_text(entry, "use_when", where),
        gotcha=_optional_text(entry, "gotcha", where),
        availability=_optional_text(entry, "availability", where),
    )


def _parse_code_ref(
    ref: object, snippets_root: Path, where: str
) -> CodeRef:
    if not isinstance(ref, str) or ref.count(":") != 1:
        raise ManifestError(
            f"{where}: code ref {ref!r} is not path:name"
        )
    path, name = ref.split(":")
    if not (snippets_root / path).is_file():
        raise ManifestError(f"{where}: snippet file {path!r} not found")
    return CodeRef(path, name)


def _parse_table(table: dict, where: str) -> Table:
    header = tuple(table.get("header", []))
    rows = tuple(tuple(row) for row in table.get("rows", []))
    if not header or not rows:
        raise ManifestError(f"{where}: table needs a header and rows")
    if any(len(row) != len(header) for row in rows):
        raise ManifestError(f"{where}: every row must match the header")
    return Table(header, rows)
