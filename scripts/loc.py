"""Count the lines of code in Volta's sources.

    python3 scripts/loc.py          # tables per component and per language
    python3 scripts/loc.py --json   # the same counts as JSON

Counts the Rust, Python, JavaScript, CSS and HTML files under `crates/`,
`scripts/` and `ai_compiler_kernels/`. Test data (`.ptx`, `.out`, `.spec`,
launch JSON) and build output are not code and are skipped. Every line is
code, a comment or blank; code under a `tests/` directory, in a `tests.rs`
file or in a `test_*.py` file is reported in its own column.
"""

import argparse
import ast
import enum
import io
import json
import os
import sys
import tokenize
from collections.abc import Iterator
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SOURCE_ROOTS = ("crates", "scripts", "ai_compiler_kernels")
SKIPPED_DIRS = frozenset({"target", ".venv", "__pycache__", ".pytest_cache", ".git"})


class Language(enum.Enum):
    RUST = "Rust"
    PYTHON = "Python"
    JAVASCRIPT = "JavaScript"
    CSS = "CSS"
    HTML = "HTML"


LANGUAGE_OF_SUFFIX = {
    ".rs": Language.RUST,
    ".py": Language.PYTHON,
    ".js": Language.JAVASCRIPT,
    ".css": Language.CSS,
    ".html": Language.HTML,
}


@dataclass(frozen=True)
class CommentSyntax:
    line: tuple[str, ...]
    block: tuple[tuple[str, str], ...]


COMMENT_SYNTAX = {
    Language.RUST: CommentSyntax(line=("//",), block=(("/*", "*/"),)),
    Language.JAVASCRIPT: CommentSyntax(line=("//",), block=(("/*", "*/"),)),
    Language.CSS: CommentSyntax(line=(), block=(("/*", "*/"),)),
    Language.HTML: CommentSyntax(line=(), block=(("<!--", "-->"),)),
}


class LineKind(enum.Enum):
    CODE = "code"
    COMMENT = "comment"
    BLANK = "blank"


class Role(enum.Enum):
    SOURCE = "source"
    TEST = "test"


@dataclass(frozen=True)
class Counts:
    files: int = 0
    code: int = 0
    tests: int = 0
    comments: int = 0
    blank: int = 0

    @property
    def total(self) -> int:
        return self.code + self.tests + self.comments + self.blank

    def __add__(self, other: "Counts") -> "Counts":
        return Counts(
            self.files + other.files,
            self.code + other.code,
            self.tests + other.tests,
            self.comments + other.comments,
            self.blank + other.blank,
        )

    def as_dict(self) -> dict[str, int]:
        return {
            "files": self.files,
            "code": self.code,
            "tests": self.tests,
            "comments": self.comments,
            "blank": self.blank,
            "total": self.total,
        }


@dataclass(frozen=True)
class SourceFile:
    path: Path
    language: Language
    component: str
    role: Role


@dataclass(frozen=True)
class LocReport:
    by_component: dict[str, Counts]
    by_language: dict[str, Counts]

    @property
    def total(self) -> Counts:
        return sum(self.by_component.values(), Counts())


def walk(root: Path) -> Iterator[Path]:
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(name for name in dirnames if name not in SKIPPED_DIRS)
        for name in sorted(filenames):
            yield Path(dirpath) / name


def component_of(relative: Path) -> str:
    parts = relative.parts
    return parts[1] if parts[0] == "crates" and len(parts) > 2 else parts[0]


def role_of(path: Path) -> Role:
    in_tests = (
        "tests" in path.parts
        or path.name == "tests.rs"
        or path.name.startswith("test_")
    )
    return Role.TEST if in_tests else Role.SOURCE


def source_files(root: Path) -> list[SourceFile]:
    files = []
    for source_root in SOURCE_ROOTS:
        for path in walk(root / source_root):
            language = LANGUAGE_OF_SUFFIX.get(path.suffix)
            if language is not None:
                component = component_of(path.relative_to(root))
                files.append(SourceFile(path, language, component, role_of(path)))
    return files


def classify_by_delimiters(lines: list[str], syntax: CommentSyntax) -> list[LineKind]:
    # The leading delimiter decides: a `//` opening a line inside a string literal counts as a comment.
    kinds = []
    closer: str | None = None
    for line in lines:
        stripped = line.strip()
        if closer is not None:
            kinds.append(LineKind.COMMENT)
            if closer in stripped:
                closer = None
        elif not stripped:
            kinds.append(LineKind.BLANK)
        elif stripped.startswith(syntax.line):
            kinds.append(LineKind.COMMENT)
        else:
            opened = next(
                (pair for pair in syntax.block if stripped.startswith(pair[0])), None
            )
            kinds.append(LineKind.CODE if opened is None else LineKind.COMMENT)
            if opened is not None and opened[1] not in stripped[len(opened[0]) :]:
                closer = opened[1]
    return kinds


def docstring_rows(node: ast.AST) -> range:
    if not isinstance(
        node, (ast.Module, ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef)
    ):
        return range(0)
    first = node.body[0] if node.body else None
    if (
        isinstance(first, ast.Expr)
        and isinstance(first.value, ast.Constant)
        and isinstance(first.value.value, str)
    ):
        return range(first.lineno, first.end_lineno + 1)
    return range(0)


def classify_python(text: str) -> list[LineKind]:
    kinds = [LineKind.BLANK] * len(text.splitlines())
    structural = {
        tokenize.NL,
        tokenize.NEWLINE,
        tokenize.INDENT,
        tokenize.DEDENT,
        tokenize.ENDMARKER,
    }
    for token in tokenize.generate_tokens(io.StringIO(text).readline):
        if token.type in structural:
            continue
        kind = LineKind.COMMENT if token.type == tokenize.COMMENT else LineKind.CODE
        for row in range(token.start[0], token.end[0] + 1):
            if kind is LineKind.CODE or kinds[row - 1] is LineKind.BLANK:
                kinds[row - 1] = kind
    for node in ast.walk(ast.parse(text)):
        for row in docstring_rows(node):
            kinds[row - 1] = LineKind.COMMENT
    return kinds


def classify_lines(text: str, language: Language) -> list[LineKind]:
    if language is Language.PYTHON:
        return classify_python(text)
    return classify_by_delimiters(text.splitlines(), COMMENT_SYNTAX[language])


def count_file(file: SourceFile) -> Counts:
    kinds = classify_lines(file.path.read_text(encoding="utf-8"), file.language)
    code = kinds.count(LineKind.CODE)
    return Counts(
        files=1,
        code=code if file.role is Role.SOURCE else 0,
        tests=code if file.role is Role.TEST else 0,
        comments=kinds.count(LineKind.COMMENT),
        blank=kinds.count(LineKind.BLANK),
    )


def count_lines_of_code(root: Path = REPO_ROOT) -> LocReport:
    by_component: dict[str, Counts] = {}
    by_language: dict[str, Counts] = {}
    for file in source_files(root):
        counts = count_file(file)
        by_component[file.component] = (
            by_component.get(file.component, Counts()) + counts
        )
        by_language[file.language.value] = (
            by_language.get(file.language.value, Counts()) + counts
        )
    return LocReport(by_component, by_language)


COLUMNS = ("Files", "Code", "Tests", "Comments", "Blank", "Total")


def format_table(title: str, rows: dict[str, Counts], total: Counts) -> str:
    width = max(len(title), len("Total"), *(len(name) for name in rows))

    def row(name: str, counts: Counts) -> str:
        cells = (
            counts.files,
            counts.code,
            counts.tests,
            counts.comments,
            counts.blank,
            counts.total,
        )
        return f"{name:<{width}}" + "".join(f"{cell:>10}" for cell in cells)

    header = f"{title:<{width}}" + "".join(f"{column:>10}" for column in COLUMNS)
    rule = "-" * len(header)
    by_size = sorted(rows.items(), key=lambda item: (-item[1].total, item[0]))
    body = [row(name, counts) for name, counts in by_size]
    return "\n".join([header, rule, *body, rule, row("Total", total)])


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("--json", action="store_true", help="print the counts as JSON")
    args = parser.parse_args()
    report = count_lines_of_code()
    if args.json:
        document = {
            "by_component": {
                name: counts.as_dict() for name, counts in report.by_component.items()
            },
            "by_language": {
                name: counts.as_dict() for name, counts in report.by_language.items()
            },
            "total": report.total.as_dict(),
        }
        json.dump(document, sys.stdout, indent=2)
        print()
    else:
        print(format_table("Component", report.by_component, report.total))
        print()
        print(format_table("Language", report.by_language, report.total))
    return 0


if __name__ == "__main__":
    sys.exit(main())
