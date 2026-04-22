#!/usr/bin/env python3
"""
Builds all 7 Bible JSON files from the downloaded KJV raw data.
Deuterocanonical books use bible-api.com (falls back to placeholder if unavailable).
"""

import json, ssl, urllib.request, os, time

SSL_CTX = ssl._create_unverified_context()
BASE = os.path.dirname(os.path.abspath(__file__))
RAW_KJV = os.path.join(BASE, 'kjv_raw.json')

# Load KJV raw data
with open(RAW_KJV, 'rb') as f:
    raw = f.read().lstrip(b'\xef\xbb\xbf')
KJV = json.loads(raw)  # list of 66 books in KJV order

# KJV index → abbrev map (0-indexed position in KJV list)
# OT[0..38] NT[39..65]
def kjv(i): return KJV[i]['chapters']

# ----- Deuterocanonical fetch via bible-api -----
def fetch_deutero(api_name, total_chapters, book_name):
    """Try to get deuterocanonical chapters from bible-api.com."""
    chapters = []
    for ch in range(1, total_chapters + 1):
        url = f"https://bible-api.com/{api_name}+{ch}?translation=web"
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Verbum/1.0'})
            with urllib.request.urlopen(req, timeout=12, context=SSL_CTX) as r:
                data = json.loads(r.read())
                verses_raw = data.get("verses", [])
                if verses_raw:
                    verses_raw.sort(key=lambda v: v["verse"])
                    chapters.append([v["text"].strip() for v in verses_raw])
                    print(f"    ch {ch}: {len(verses_raw)} verses")
                    time.sleep(0.2)
                    continue
        except Exception:
            pass
        # Placeholder fallback
        chapters.append([f"[{book_name} {ch}:{v}] Text not yet loaded." for v in range(1, 11)])
        print(f"    ch {ch}: placeholder")
        time.sleep(0.1)
    return chapters

# ----- Build books -----

def make_book(book_id, name, abbr, testament, kjv_idx=None, deutero_api=None, deutero_chapters=None):
    if kjv_idx is not None:
        chapters = kjv(kjv_idx)
    elif deutero_api:
        print(f"  Fetching deuterocanonical: {name}...")
        chapters = fetch_deutero(deutero_api, deutero_chapters, name)
    else:
        chapters = [[f"[{name} 1:1] Text unavailable."]]
    return {"id": book_id, "name": name, "abbreviation": abbr, "testament": testament, "chapters": chapters}

# =====================================================================
# File groups
# =====================================================================

FILE_GROUPS = {

    "nt_gospels": lambda: [
        make_book(47, "Matthew",  "Mt", "NT", kjv_idx=39),
        make_book(48, "Mark",     "Mk", "NT", kjv_idx=40),
        make_book(49, "Luke",     "Lk", "NT", kjv_idx=41),
        make_book(50, "John",     "Jn", "NT", kjv_idx=42),
    ],

    "nt_acts_epistles": lambda: [
        make_book(51, "Acts",             "Acts",  "NT", kjv_idx=43),
        make_book(52, "Romans",           "Rom",   "NT", kjv_idx=44),
        make_book(53, "1 Corinthians",    "1 Cor", "NT", kjv_idx=45),
        make_book(54, "2 Corinthians",    "2 Cor", "NT", kjv_idx=46),
        make_book(55, "Galatians",        "Gal",   "NT", kjv_idx=47),
        make_book(56, "Ephesians",        "Eph",   "NT", kjv_idx=48),
        make_book(57, "Philippians",      "Phil",  "NT", kjv_idx=49),
        make_book(58, "Colossians",       "Col",   "NT", kjv_idx=50),
        make_book(59, "1 Thessalonians",  "1 Thes","NT", kjv_idx=51),
        make_book(60, "2 Thessalonians",  "2 Thes","NT", kjv_idx=52),
        make_book(61, "1 Timothy",        "1 Tm",  "NT", kjv_idx=53),
        make_book(62, "2 Timothy",        "2 Tm",  "NT", kjv_idx=54),
        make_book(63, "Titus",            "Ti",    "NT", kjv_idx=55),
        make_book(64, "Philemon",         "Phlm",  "NT", kjv_idx=56),
        make_book(65, "Hebrews",          "Heb",   "NT", kjv_idx=57),
    ],

    "nt_catholic_rev": lambda: [
        make_book(66, "James",      "Jas",  "NT", kjv_idx=58),
        make_book(67, "1 Peter",    "1 Pt", "NT", kjv_idx=59),
        make_book(68, "2 Peter",    "2 Pt", "NT", kjv_idx=60),
        make_book(69, "1 John",     "1 Jn", "NT", kjv_idx=61),
        make_book(70, "2 John",     "2 Jn", "NT", kjv_idx=62),
        make_book(71, "3 John",     "3 Jn", "NT", kjv_idx=63),
        make_book(72, "Jude",       "Jude", "NT", kjv_idx=64),
        make_book(73, "Revelation", "Rv",   "NT", kjv_idx=65),
    ],

    "ot_law": lambda: [
        make_book(1, "Genesis",      "Gn", "OT", kjv_idx=0),
        make_book(2, "Exodus",       "Ex", "OT", kjv_idx=1),
        make_book(3, "Leviticus",    "Lv", "OT", kjv_idx=2),
        make_book(4, "Numbers",      "Nm", "OT", kjv_idx=3),
        make_book(5, "Deuteronomy",  "Dt", "OT", kjv_idx=4),
    ],

    "ot_history": lambda: [
        make_book(6,  "Joshua",        "Jos",  "OT", kjv_idx=5),
        make_book(7,  "Judges",        "Jgs",  "OT", kjv_idx=6),
        make_book(8,  "Ruth",          "Ru",   "OT", kjv_idx=7),
        make_book(9,  "1 Samuel",      "1 Sm", "OT", kjv_idx=8),
        make_book(10, "2 Samuel",      "2 Sm", "OT", kjv_idx=9),
        make_book(11, "1 Kings",       "1 Kgs","OT", kjv_idx=10),
        make_book(12, "2 Kings",       "2 Kgs","OT", kjv_idx=11),
        make_book(13, "1 Chronicles",  "1 Chr","OT", kjv_idx=12),
        make_book(14, "2 Chronicles",  "2 Chr","OT", kjv_idx=13),
        make_book(15, "Ezra",          "Ezr",  "OT", kjv_idx=14),
        make_book(16, "Nehemiah",      "Neh",  "OT", kjv_idx=15),
        # Deuterocanonicals
        make_book(17, "Tobit",       "Tb",  "OT", deutero_api="tobit",      deutero_chapters=14),
        make_book(18, "Judith",      "Jdt", "OT", deutero_api="judith",     deutero_chapters=16),
        make_book(19, "Esther",      "Est", "OT", kjv_idx=16),
        make_book(20, "1 Maccabees", "1 Mc","OT", deutero_api="1+maccabees",deutero_chapters=16),
        make_book(21, "2 Maccabees", "2 Mc","OT", deutero_api="2+maccabees",deutero_chapters=15),
    ],

    "ot_wisdom": lambda: [
        make_book(22, "Job",           "Jb",   "OT", kjv_idx=17),
        make_book(23, "Psalms",        "Ps",   "OT", kjv_idx=18),
        make_book(24, "Proverbs",      "Prv",  "OT", kjv_idx=19),
        make_book(25, "Ecclesiastes",  "Eccl", "OT", kjv_idx=20),
        make_book(26, "Song of Songs", "Sg",   "OT", kjv_idx=21),
        # Deuterocanonicals
        make_book(27, "Wisdom", "Wis", "OT", deutero_api="wisdom",  deutero_chapters=19),
        make_book(28, "Sirach", "Sir", "OT", deutero_api="sirach",  deutero_chapters=51),
    ],

    "ot_prophets": lambda: [
        make_book(29, "Isaiah",      "Is",  "OT", kjv_idx=22),
        make_book(30, "Jeremiah",    "Jer", "OT", kjv_idx=23),
        make_book(31, "Lamentations","Lam", "OT", kjv_idx=24),
        # Deuterocanonical
        make_book(32, "Baruch", "Bar", "OT", deutero_api="baruch", deutero_chapters=6),
        make_book(33, "Ezekiel",    "Ez",  "OT", kjv_idx=25),
        make_book(34, "Daniel",     "Dn",  "OT", kjv_idx=26),
        make_book(35, "Hosea",      "Hos", "OT", kjv_idx=27),
        make_book(36, "Joel",       "Jl",  "OT", kjv_idx=28),
        make_book(37, "Amos",       "Am",  "OT", kjv_idx=29),
        make_book(38, "Obadiah",    "Ob",  "OT", kjv_idx=30),
        make_book(39, "Jonah",      "Jon", "OT", kjv_idx=31),
        make_book(40, "Micah",      "Mi",  "OT", kjv_idx=32),
        make_book(41, "Nahum",      "Na",  "OT", kjv_idx=33),
        make_book(42, "Habakkuk",   "Hb",  "OT", kjv_idx=34),
        make_book(43, "Zephaniah",  "Zep", "OT", kjv_idx=35),
        make_book(44, "Haggai",     "Hg",  "OT", kjv_idx=36),
        make_book(45, "Zechariah",  "Zec", "OT", kjv_idx=37),
        make_book(46, "Malachi",    "Mal", "OT", kjv_idx=38),
    ],
}

def main():
    for file_name, builder in FILE_GROUPS.items():
        out_path = os.path.join(BASE, f"{file_name}.json")
        if os.path.exists(out_path):
            print(f"SKIP (exists): {file_name}.json")
            continue
        print(f"\n=== Building {file_name}.json ===")
        books_data = builder()
        payload = {"version": 1, "books": books_data}
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, separators=(",", ":"))
        size_kb = os.path.getsize(out_path) // 1024
        total_verses = sum(
            len(v_list)
            for b in books_data
            for v_list in b["chapters"]
        )
        print(f"  -> {file_name}.json  {size_kb} KB  {total_verses} verses")

if __name__ == "__main__":
    main()
