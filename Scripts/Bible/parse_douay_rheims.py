#!/usr/bin/env python3
"""
Parses the Douay-Rheims Bible from Project Gutenberg pg1581 HTML source
and produces the 7 grouped JSON files for the Verbum iOS app.

Source: ~/Projects/Learning/verbum/app/src/main/assets/bible/source/pg1581/pg1581-images.html.utf8

Usage: python3 parse_douay_rheims.py
"""

import re
import json
import html
import os

# ─── Paths ────────────────────────────────────────────────────────────────────

ANDROID_ROOT = os.path.expanduser("~/Projects/Learning/verbum/app/src/main/assets/bible/source")
HTML_SOURCE = os.path.join(ANDROID_ROOT, "pg1581/pg1581-images.html.utf8")
MAPPING_YAML = os.path.join(ANDROID_ROOT, "pg1581/src_pg1581.yaml")
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ─── iOS Book Catalogue (73 Catholic books, Douay-Rheims display names) ───────
# Maps USFM_ID → (ios_id, display_name, abbreviation, testament)
# OT books in canonical Catholic order (1-46), NT (47-73)
USFM_TO_IOS = {
    # ── Pentateuch ──
    "GEN": (1,  "Genesis",          "Gn",     "OT"),
    "EXO": (2,  "Exodus",           "Ex",     "OT"),
    "LEV": (3,  "Leviticus",        "Lv",     "OT"),
    "NUM": (4,  "Numbers",          "Nm",     "OT"),
    "DEU": (5,  "Deuteronomy",      "Dt",     "OT"),
    # ── Historical ──
    "JOS": (6,  "Joshua",           "Jos",    "OT"),
    "JDG": (7,  "Judges",           "Jgs",    "OT"),
    "RUT": (8,  "Ruth",             "Ru",     "OT"),
    "1SA": (9,  "1 Samuel",         "1 Sm",   "OT"),
    "2SA": (10, "2 Samuel",         "2 Sm",   "OT"),
    "1KI": (11, "1 Kings",          "1 Kgs",  "OT"),
    "2KI": (12, "2 Kings",          "2 Kgs",  "OT"),
    "1CH": (13, "1 Chronicles",     "1 Chr",  "OT"),
    "2CH": (14, "2 Chronicles",     "2 Chr",  "OT"),
    "EZR": (15, "Ezra",             "Ezr",    "OT"),
    "NEH": (16, "Nehemiah",         "Neh",    "OT"),
    "TOB": (17, "Tobit",            "Tb",     "OT"),
    "JDT": (18, "Judith",           "Jdt",    "OT"),
    "ESG": (19, "Esther",           "Est",    "OT"),
    "1MA": (20, "1 Maccabees",      "1 Mc",   "OT"),
    "2MA": (21, "2 Maccabees",      "2 Mc",   "OT"),
    # ── Wisdom / Poetry ──
    "JOB": (22, "Job",              "Jb",     "OT"),
    "PSA": (23, "Psalms",           "Ps",     "OT"),
    "PRO": (24, "Proverbs",         "Prv",    "OT"),
    "ECC": (25, "Ecclesiastes",     "Eccl",   "OT"),
    "SNG": (26, "Song of Songs",    "Sg",     "OT"),
    "WIS": (27, "Wisdom",           "Wis",    "OT"),
    "SIR": (28, "Sirach",           "Sir",    "OT"),
    # ── Major Prophets ──
    "ISA": (29, "Isaiah",           "Is",     "OT"),
    "JER": (30, "Jeremiah",         "Jer",    "OT"),
    "LAM": (31, "Lamentations",     "Lam",    "OT"),
    "BAR": (32, "Baruch",           "Bar",    "OT"),
    "EZK": (33, "Ezekiel",          "Ez",     "OT"),
    "DAG": (34, "Daniel",           "Dn",     "OT"),
    # ── Minor Prophets ──
    "HOS": (35, "Hosea",            "Hos",    "OT"),
    "JOL": (36, "Joel",             "Jl",     "OT"),
    "AMO": (37, "Amos",             "Am",     "OT"),
    "OBA": (38, "Obadiah",          "Ob",     "OT"),
    "JON": (39, "Jonah",            "Jon",    "OT"),
    "MIC": (40, "Micah",            "Mi",     "OT"),
    "NAM": (41, "Nahum",            "Na",     "OT"),
    "HAB": (42, "Habakkuk",         "Hb",     "OT"),
    "ZEP": (43, "Zephaniah",        "Zep",    "OT"),
    "HAG": (44, "Haggai",           "Hg",     "OT"),
    "ZEC": (45, "Zechariah",        "Zec",    "OT"),
    "MAL": (46, "Malachi",          "Mal",    "OT"),
    # ── New Testament ──
    "MAT": (47, "Matthew",          "Mt",     "NT"),
    "MRK": (48, "Mark",             "Mk",     "NT"),
    "LUK": (49, "Luke",             "Lk",     "NT"),
    "JHN": (50, "John",             "Jn",     "NT"),
    "ACT": (51, "Acts",             "Acts",   "NT"),
    "ROM": (52, "Romans",           "Rom",    "NT"),
    "1CO": (53, "1 Corinthians",    "1 Cor",  "NT"),
    "2CO": (54, "2 Corinthians",    "2 Cor",  "NT"),
    "GAL": (55, "Galatians",        "Gal",    "NT"),
    "EPH": (56, "Ephesians",        "Eph",    "NT"),
    "PHP": (57, "Philippians",      "Phil",   "NT"),
    "COL": (58, "Colossians",       "Col",    "NT"),
    "1TH": (59, "1 Thessalonians",  "1 Thes", "NT"),
    "2TH": (60, "2 Thessalonians",  "2 Thes", "NT"),
    "1TI": (61, "1 Timothy",        "1 Tm",   "NT"),
    "2TI": (62, "2 Timothy",        "2 Tm",   "NT"),
    "TIT": (63, "Titus",            "Ti",     "NT"),
    "PHM": (64, "Philemon",         "Phlm",   "NT"),
    "HEB": (65, "Hebrews",          "Heb",    "NT"),
    "JAS": (66, "James",            "Jas",    "NT"),
    "1PE": (67, "1 Peter",          "1 Pt",   "NT"),
    "2PE": (68, "2 Peter",          "2 Pt",   "NT"),
    "1JN": (69, "1 John",           "1 Jn",   "NT"),
    "2JN": (70, "2 John",           "2 Jn",   "NT"),
    "3JN": (71, "3 John",           "3 Jn",   "NT"),
    "JUD": (72, "Jude",             "Jude",   "NT"),
    "REV": (73, "Revelation",       "Rv",     "NT"),
}

# ─── iOS output file groupings (by iOS book ID) ───────────────────────────────
FILE_GROUPS = {
    "ot_law":           list(range(1,  6)),   # 1-5
    "ot_history":       list(range(6,  22)),  # 6-21
    "ot_wisdom":        list(range(22, 29)),  # 22-28
    "ot_prophets":      list(range(29, 47)),  # 29-46
    "nt_gospels":       list(range(47, 51)),  # 47-50
    "nt_acts_epistles": list(range(51, 66)),  # 51-65
    "nt_catholic_rev":  list(range(66, 74)),  # 66-73
}

# ─── Regex patterns (mirrored from Android BibleAssetSeeder) ──────────────────
BOOK_HEADER_RE   = re.compile(r'<h3[^>]*id="([A-Z0-9_]+)"[^>]*>', re.IGNORECASE)
VERSE_PARA_RE    = re.compile(r'<p[^>]*>\s*\d+:\d+\.', re.IGNORECASE)
HTML_VERSE_RE    = re.compile(r'<p[^>]*>\s*(\d+):(\d+)\.\s*(.+?)</p>', re.IGNORECASE | re.DOTALL)
SUPERSCRIPT_RE   = re.compile(r'<sup[^>]*>.*?</sup>', re.IGNORECASE | re.DOTALL)
HTML_TAG_RE      = re.compile(r'<[^>]+>')
EXPL_PARA_RE     = re.compile(r'<p\s+class="expl"', re.IGNORECASE)

# ─── Load pg1581 tag → USFM mapping ───────────────────────────────────────────

def load_book_map(yaml_path: str) -> dict[str, str]:
    """Parse src_pg1581.yaml: tag → USFM_ID."""
    mapping: dict[str, str] = {}
    current_tag: str | None = None
    with open(yaml_path, encoding="utf-8") as f:
        for line in f:
            stripped = line.strip()
            if not stripped or stripped == "---":
                continue
            if not line.startswith(" ") and stripped.endswith(":"):
                current_tag = stripped[:-1]
                continue
            if stripped.startswith("USFM_ID:") and current_tag:
                usfm = stripped.split(":", 1)[1].strip().strip("'\"").upper()
                mapping[current_tag.upper()] = usfm
    return mapping

# ─── HTML sanitizer ───────────────────────────────────────────────────────────

def sanitize_verse(raw_html: str) -> str:
    """Strip superscripts, HTML tags, decode entities, normalise whitespace."""
    text = SUPERSCRIPT_RE.sub("", raw_html)
    text = HTML_TAG_RE.sub("", text)
    text = html.unescape(text)
    text = re.sub(r"\s+", " ", text).strip()
    return text

# ─── Main parser ─────────────────────────────────────────────────────────────

def parse_douay_rheims(html_path: str, tag_to_usfm: dict[str, str]) -> dict[int, dict]:
    """
    Returns a dict: ios_book_id → {id, name, abbreviation, testament, chapters}
    where chapters is a list of lists of verse strings (0-indexed by chapter).
    """
    books_data: dict[int, dict] = {}
    current_ios_id: int | None = None

    para_buffer: list[str] = []
    in_verse_para = False

    # We store verses as {(chapter, verse): text}
    current_verses: dict[tuple[int, int], str] = {}

    def finalise_book():
        nonlocal current_verses, current_ios_id
        if current_ios_id is None or not current_verses:
            return
        # Build sorted chapters list
        max_ch = max(cv[0] for cv in current_verses)
        chapters: list[list[str]] = []
        for ch in range(1, max_ch + 1):
            max_v = max((cv[1] for cv in current_verses if cv[0] == ch), default=0)
            chapter_verses: list[str] = []
            for v in range(1, max_v + 1):
                text = current_verses.get((ch, v), "")
                chapter_verses.append(text)
            chapters.append(chapter_verses)

        ios_id = current_ios_id
        meta = USFM_TO_IOS.get(next(
            (u for u, (i, *_) in USFM_TO_IOS.items() if i == ios_id), None
        ))
        if meta:
            _, name, abbr, testament = meta
            books_data[ios_id] = {
                "id": ios_id,
                "name": name,
                "abbreviation": abbr,
                "testament": testament,
                "chapters": chapters,
            }
        current_verses = {}

    with open(html_path, encoding="utf-8") as f:
        for raw_line in f:
            line = raw_line.strip()
            if not line:
                continue

            # ── Book header ──────────────────────────────────────────────────
            book_match = BOOK_HEADER_RE.search(line)
            if book_match:
                # Save previously accumulated book
                finalise_book()
                tag = book_match.group(1).upper()
                usfm = tag_to_usfm.get(tag)
                if usfm and usfm in USFM_TO_IOS:
                    current_ios_id = USFM_TO_IOS[usfm][0]
                    current_verses = {}
                else:
                    current_ios_id = None
                in_verse_para = False
                para_buffer.clear()
                continue

            if current_ios_id is None:
                continue

            # Skip footnote/explanation paragraphs entirely
            if EXPL_PARA_RE.search(line):
                # If mid-buffer, also reset
                in_verse_para = False
                para_buffer.clear()
                continue

            # ── Verse paragraph accumulation ─────────────────────────────────
            if not in_verse_para and VERSE_PARA_RE.search(line):
                in_verse_para = True
                para_buffer.clear()

            if in_verse_para:
                if para_buffer:
                    para_buffer.append(" ")
                para_buffer.append(line)

                if "</p>" in line.lower():
                    full_para = "".join(para_buffer)
                    verse_match = HTML_VERSE_RE.search(full_para)
                    if verse_match:
                        ch  = int(verse_match.group(1))
                        v   = int(verse_match.group(2))
                        raw = verse_match.group(3)
                        text = sanitize_verse(raw)
                        if text and ch > 0 and v > 0:
                            current_verses[(ch, v)] = text
                    in_verse_para = False
                    para_buffer.clear()

    # Finalise last book
    finalise_book()
    return books_data

# ─── Write JSON files ─────────────────────────────────────────────────────────

def write_files(books_data: dict[int, dict]):
    for file_name, ios_ids in FILE_GROUPS.items():
        books_in_file = []
        for ios_id in ios_ids:
            if ios_id in books_data:
                books_in_file.append(books_data[ios_id])
            else:
                # Should not happen if the HTML is complete
                print(f"  WARNING: Book ID {ios_id} not found for {file_name}")

        payload = {"version": 2, "books": books_in_file}
        out_path = os.path.join(OUTPUT_DIR, f"{file_name}.json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, separators=(",", ":"))
        verse_count = sum(len(v) for b in books_in_file for v in b["chapters"])
        print(f"  {file_name}.json → {len(books_in_file)} books, {verse_count} verses")

# ─── Entry point ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Loading tag→USFM mapping...")
    tag_to_usfm = load_book_map(MAPPING_YAML)
    print(f"  Loaded {len(tag_to_usfm)} book tag mappings")

    print(f"Parsing Douay-Rheims HTML: {HTML_SOURCE}")
    books_data = parse_douay_rheims(HTML_SOURCE, tag_to_usfm)

    total_books = len(books_data)
    total_verses = sum(
        len(v) for b in books_data.values() for v in b["chapters"]
    )
    print(f"  Parsed {total_books}/73 books, {total_verses} total verses")

    if total_books < 73:
        missing = [
            f"{usfm}({ios_id})"
            for usfm, (ios_id, *_) in USFM_TO_IOS.items()
            if ios_id not in books_data
        ]
        print(f"  Missing: {', '.join(missing)}")

    print("Writing JSON files...")
    write_files(books_data)
    print("Done.")
