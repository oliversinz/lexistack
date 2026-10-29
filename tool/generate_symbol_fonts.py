"""Optional asset regeneration: Python + fonttools==4.68.0. No runtime dependency.

Subset the seven symbols used by the existing UI/share formatter. Keep ordinary
text in the accepted DM Sans/Fraunces fonts and retain upstream OFL notices.
"""
import hashlib
import pathlib
import urllib.request

from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCES = [
    ("symbols", "LexiStack Symbols", [0x2605, 0x2606, 0x2713],
     "https://raw.githubusercontent.com/google/fonts/7b6724ac7ececc713e9ba93af309f7520c9a80a3/ofl/notosanssymbols2/NotoSansSymbols2-Regular.ttf",
     "7d5fb73b7ca67a6798101741f5d280a3d016a56a197afcd4199dbb57b4b82a21"),
    ("emoji", "LexiStack Emoji", [0x1F7E6, 0x1F7E8, 0x1F7E9, 0x1F7EA],
     "https://raw.githubusercontent.com/googlefonts/noto-emoji/v2.051/fonts/NotoColorEmoji.ttf",
     "72a635cb3d2f3524c51620cdde406b217204e8a6a06c6a096ff8ed4b5fd6e27b"),
]

for name, family, codepoints, url, sha in SOURCES:
    source = ROOT / ".dart_tool" / f"f6-{name}-source.ttf"
    source.parent.mkdir(exist_ok=True)
    data = urllib.request.urlopen(url).read()
    assert hashlib.sha256(data).hexdigest() == sha, url
    source.write_bytes(data)
    font = TTFont(source, recalcTimestamp=False)
    assert all(point in font.getBestCmap() for point in codepoints)
    options = subset.Options()
    options.name_IDs = [0, 1, 2, 3, 4, 5, 6, 13, 14]
    cutter = subset.Subsetter(options=options)
    cutter.populate(unicodes=codepoints)
    cutter.subset(font)
    for record in font['name'].names:
        if record.nameID in (1, 3, 4, 6):
            record.string = (family.replace(' ', '') if record.nameID == 6
                             else family).encode(record.getEncoding())
    target = ROOT / "assets" / "fonts" / f"{name}.ttf"
    font.save(target)
    print(f"{target.name}: {target.stat().st_size} bytes; {sha} source SHA-256")
