# Python Expert Skill

## Project Structure

```
my_package/
├── src/
│   └── my_package/
│       ├── __init__.py
│       ├── cli.py          # argparse entry point
│       ├── core.py         # pure logic, no I/O
│       └── utils.py
├── tests/
│   ├── __init__.py
│   ├── test_core.py
│   └── conftest.py
├── pyproject.toml          # modern packaging standard
└── README.md
```

## pyproject.toml (Modern Packaging)
```toml
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.backends.legacy:build"

[project]
name = "my-package"
version = "1.0.0"
description = "One-line description"
requires-python = ">=3.11"
dependencies = [
    "requests>=2.28",
]

[project.scripts]
my-tool = "my_package.cli:main"

[project.optional-dependencies]
dev = ["pytest", "pytest-cov", "ruff", "mypy"]
```

## Type Hints (Always)
```python
from pathlib import Path
from typing import Optional, Union

def process_file(path: Path, encoding: str = "utf-8") -> list[str]:
    return path.read_text(encoding=encoding).splitlines()

def find_item(items: list[dict], key: str) -> Optional[dict]:
    return next((i for i in items if i.get("id") == key), None)

# Python 3.10+: use | instead of Union
def handle(value: str | int | None) -> str:
    match value:
        case None: return "empty"
        case int(n): return f"number: {n}"
        case str(s): return s
```

## Dataclasses Over Dicts
```python
from dataclasses import dataclass, field

@dataclass
class Config:
    host: str
    port: int = 8080
    tags: list[str] = field(default_factory=list)  # NEVER default=[]
    debug: bool = False

    def url(self) -> str:
        return f"http://{self.host}:{self.port}"
```

## pathlib Over os.path (Always)
```python
from pathlib import Path

# Not this
import os
config_path = os.path.join(os.path.dirname(__file__), "config.json")

# This
config_path = Path(__file__).parent / "config.json"
content = config_path.read_text()
data = json.loads(config_path.read_bytes())
config_path.write_text(content)

# Directory operations
Path("output").mkdir(parents=True, exist_ok=True)
files = list(Path("src").glob("**/*.py"))
```

## CLI with argparse
```python
import argparse
import sys

def create_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Tool description",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = p.add_subparsers(dest="command", required=True)
    
    cmd = sub.add_parser("run", help="Run the thing")
    cmd.add_argument("input", type=Path, help="Input file")
    cmd.add_argument("-o", "--output", type=Path, default=Path("out"))
    cmd.add_argument("-v", "--verbose", action="store_true")
    return p

def main() -> None:
    args = create_parser().parse_args()
    # Non-blocking: never use input() when args are provided
    if args.command == "run":
        process(args.input, args.output, verbose=args.verbose)

if __name__ == "__main__":
    main()
```

## HTTP / Requests
```python
import urllib.request
import json

# Standard library only (no requests package needed for simple cases)
def fetch_json(url: str, timeout: int = 10) -> dict:
    with urllib.request.urlopen(url, timeout=timeout) as resp:
        return json.loads(resp.read())

# With requests (when already in project)
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

session = requests.Session()
session.mount("https://", HTTPAdapter(max_retries=Retry(total=3, backoff_factor=0.5)))
resp = session.get(url, timeout=10)
resp.raise_for_status()
```

## Async (asyncio)
```python
import asyncio
import aiohttp

async def fetch_many(urls: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_one(session, url) for url in urls]
        return await asyncio.gather(*tasks)  # parallel, not sequential

async def fetch_one(session: aiohttp.ClientSession, url: str) -> dict:
    async with session.get(url, timeout=aiohttp.ClientTimeout(total=10)) as resp:
        resp.raise_for_status()
        return await resp.json()

# Run
results = asyncio.run(fetch_many(urls))
```

## Testing
```python
import pytest
from pathlib import Path

@pytest.fixture
def tmp_config(tmp_path: Path) -> Path:
    cfg = tmp_path / "config.json"
    cfg.write_text('{"key": "value"}')
    return cfg

def test_load_config(tmp_config: Path) -> None:
    config = load_config(tmp_config)
    assert config["key"] == "value"

@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("", ""),
    ("123", "123"),
])
def test_uppercase(input: str, expected: str) -> None:
    assert transform(input) == expected
```

```bash
# Run tests with coverage
pytest tests/ -v --cov=src --cov-report=term-missing

# Run specific test
pytest tests/test_core.py::test_load_config -v

# Lint and typecheck
ruff check src/ tests/
mypy src/
```

## Common Mistakes to Avoid

```python
# NEVER — mutable default argument
def add_item(item, items=[]):  # shared across all calls!
    items.append(item)
    return items

# CORRECT
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items

# NEVER — catching bare Exception without re-raising
try:
    risky()
except Exception:
    pass  # silences ALL errors including KeyboardInterrupt

# CORRECT
try:
    risky()
except ValueError as e:
    logger.warning("Expected failure: %s", e)

# NEVER — f-string in HTML with CSS
html = f"<style>body {{ color: red }}</style>"  # NameError: 'color'

# CORRECT
html = "<style>body { color: red }</style>"  # plain string

# NEVER — blocking input() in automated scripts
user_input = input("Continue? ")  # hangs in CI/automation

# CORRECT — check args first, only prompt interactively
if args.yes or not sys.stdin.isatty():
    proceed = True
else:
    proceed = input("Continue? [y/N] ").lower() == "y"
```
