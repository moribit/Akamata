"""Check the maintained developer journey without extracting Markdown code."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
documents = [root / name for name in ("README.md", "README.ja.md")]
for language in ("en", "ja"):
    base = root / "docs" / language
    documents += [base / name for name in ("README.md", "quickstart.md", "tutorial.md", "handbook.md", "handler-api.md", "public-performance.md")]
    documents += list((base / "guides").glob("*.md"))
documents += list((root / "examples").glob("*/README.md"))
missing = []
for document in documents:
    for destination in re.findall(r"\]\(([^)]+)\)", document.read_text()):
        if "://" in destination or destination.startswith("#"):
            continue
        path = destination.split("#", 1)[0]
        if not (document.parent / path).exists():
            missing.append(f"{document.relative_to(root)}: {destination}")
assert not missing, "Broken developer documentation links:\n" + "\n".join(missing)
print(f"developer documentation links: {len(documents)} documents passed")
