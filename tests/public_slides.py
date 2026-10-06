"""Read-only structural checks for committed bilingual PDFs (pypdf required)."""
from pathlib import Path
import re
from urllib.parse import unquote
from pypdf import PdfReader

root = Path(__file__).resolve().parents[1]
for language in ("en", "ja"):
    source = root / "tools/docgen" / ("slides.html" if language == "en" else "slides.ja.html")
    html = source.read_text()
    expected_links = set(re.findall(r'href="([^"]+)"', html))
    assert html.count('<section class="slide') == 13
    pdf = PdfReader(root / "docs" / language / "slides.pdf")
    assert len(pdf.pages) == 13
    found_links = set()
    for page in pdf.pages:
        assert len(page.extract_text().strip()) > 80, "blank/incomplete slide"
        assert abs(float(page.mediabox.width) - 960) < 1
        assert abs(float(page.mediabox.height) - 540) < 1
        for annotation in page.get("/Annots", []):
            action = annotation.get_object().get("/A", {})
            if action.get("/S") == "/URI":
                found_links.add(str(action["/URI"]))
    assert expected_links <= found_links, (language, expected_links - found_links)
    for url in found_links:
        prefix = "https://github.com/moribit/Akamata/blob/main/"
        if url.startswith(prefix):
            assert (root / unquote(url[len(prefix):])).is_file(), url
        else:
            assert url == "https://github.com/moribit/Akamata", url
    text = "\n".join(page.extract_text() for page in pdf.pages)
    assert "fn hello()" in text and "expectStatus" in text and "0.17.0" in text
    for stale in ("0.16", "v0.0.1", "ready for production", "Cloudflare certified"):
        assert stale not in text
    print(f"{language} PDF: 13 nonblank pages, {len(found_links)} valid links and current code")
