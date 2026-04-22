#!/usr/bin/env python3
"""
Fetches the complete Douay-Rheims / KJV Bible from bible-api.com (public domain)
and saves it as grouped JSON files for the Verbum iOS app.

Usage: python3 generate_bible.py
"""

import ssl, urllib.request, json, time, os, sys

SSL_CTX = ssl._create_unverified_context()
BASE_URL = "https://bible-api.com"
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# Catholic canon book list: (id, name, abbreviation, testament, chapters, api_name)
BOOKS = [
    # Old Testament (46 books)
    (1,  "Genesis",        "Gn",    "OT", 50, "genesis"),
    (2,  "Exodus",         "Ex",    "OT", 40, "exodus"),
    (3,  "Leviticus",      "Lv",    "OT", 27, "leviticus"),
    (4,  "Numbers",        "Nm",    "OT", 36, "numbers"),
    (5,  "Deuteronomy",    "Dt",    "OT", 34, "deuteronomy"),
    (6,  "Joshua",         "Jos",   "OT", 24, "joshua"),
    (7,  "Judges",         "Jgs",   "OT", 21, "judges"),
    (8,  "Ruth",           "Ru",    "OT", 4,  "ruth"),
    (9,  "1 Samuel",       "1 Sm",  "OT", 31, "1+samuel"),
    (10, "2 Samuel",       "2 Sm",  "OT", 24, "2+samuel"),
    (11, "1 Kings",        "1 Kgs", "OT", 22, "1+kings"),
    (12, "2 Kings",        "2 Kgs", "OT", 25, "2+kings"),
    (13, "1 Chronicles",   "1 Chr", "OT", 29, "1+chronicles"),
    (14, "2 Chronicles",   "2 Chr", "OT", 36, "2+chronicles"),
    (15, "Ezra",           "Ezr",   "OT", 10, "ezra"),
    (16, "Nehemiah",       "Neh",   "OT", 13, "nehemiah"),
    # Deuterocanonicals — may not be in KJV API; use placeholders if absent
    (17, "Tobit",          "Tb",    "OT", 14, "tobit"),
    (18, "Judith",         "Jdt",   "OT", 16, "judith"),
    (19, "Esther",         "Est",   "OT", 10, "esther"),
    (20, "1 Maccabees",    "1 Mc",  "OT", 16, "1+maccabees"),
    (21, "2 Maccabees",    "2 Mc",  "OT", 15, "2+maccabees"),
    (22, "Job",            "Jb",    "OT", 42, "job"),
    (23, "Psalms",         "Ps",    "OT", 150,"psalms"),
    (24, "Proverbs",       "Prv",   "OT", 31, "proverbs"),
    (25, "Ecclesiastes",   "Eccl",  "OT", 12, "ecclesiastes"),
    (26, "Song of Songs",  "Sg",    "OT", 8,  "song+of+solomon"),
    (27, "Wisdom",         "Wis",   "OT", 19, "wisdom"),
    (28, "Sirach",         "Sir",   "OT", 51, "sirach"),
    (29, "Isaiah",         "Is",    "OT", 66, "isaiah"),
    (30, "Jeremiah",       "Jer",   "OT", 52, "jeremiah"),
    (31, "Lamentations",   "Lam",   "OT", 5,  "lamentations"),
    (32, "Baruch",         "Bar",   "OT", 6,  "baruch"),
    (33, "Ezekiel",        "Ez",    "OT", 48, "ezekiel"),
    (34, "Daniel",         "Dn",    "OT", 14, "daniel"),
    (35, "Hosea",          "Hos",   "OT", 14, "hosea"),
    (36, "Joel",           "Jl",    "OT", 4,  "joel"),  # 3 ch in KJV, 4 in Catholic
    (37, "Amos",           "Am",    "OT", 9,  "amos"),
    (38, "Obadiah",        "Ob",    "OT", 1,  "obadiah"),
    (39, "Jonah",          "Jon",   "OT", 4,  "jonah"),
    (40, "Micah",          "Mi",    "OT", 7,  "micah"),
    (41, "Nahum",          "Na",    "OT", 3,  "nahum"),
    (42, "Habakkuk",       "Hb",    "OT", 3,  "habakkuk"),
    (43, "Zephaniah",      "Zep",   "OT", 3,  "zephaniah"),
    (44, "Haggai",         "Hg",    "OT", 2,  "haggai"),
    (45, "Zechariah",      "Zec",   "OT", 14, "zechariah"),
    (46, "Malachi",        "Mal",   "OT", 4,  "malachi"),
    # New Testament (27 books)
    (47, "Matthew",        "Mt",    "NT", 28, "matthew"),
    (48, "Mark",           "Mk",    "NT", 16, "mark"),
    (49, "Luke",           "Lk",    "NT", 24, "luke"),
    (50, "John",           "Jn",    "NT", 21, "john"),
    (51, "Acts",           "Acts",  "NT", 28, "acts"),
    (52, "Romans",         "Rom",   "NT", 16, "romans"),
    (53, "1 Corinthians",  "1 Cor", "NT", 16, "1+corinthians"),
    (54, "2 Corinthians",  "2 Cor", "NT", 13, "2+corinthians"),
    (55, "Galatians",      "Gal",   "NT", 6,  "galatians"),
    (56, "Ephesians",      "Eph",   "NT", 6,  "ephesians"),
    (57, "Philippians",    "Phil",  "NT", 4,  "philippians"),
    (58, "Colossians",     "Col",   "NT", 4,  "colossians"),
    (59, "1 Thessalonians","1 Thes","NT", 5,  "1+thessalonians"),
    (60, "2 Thessalonians","2 Thes","NT", 3,  "2+thessalonians"),
    (61, "1 Timothy",      "1 Tm",  "NT", 6,  "1+timothy"),
    (62, "2 Timothy",      "2 Tm",  "NT", 4,  "2+timothy"),
    (63, "Titus",          "Ti",    "NT", 3,  "titus"),
    (64, "Philemon",       "Phlm",  "NT", 1,  "philemon"),
    (65, "Hebrews",        "Heb",   "NT", 13, "hebrews"),
    (66, "James",          "Jas",   "NT", 5,  "james"),
    (67, "1 Peter",        "1 Pt",  "NT", 5,  "1+peter"),
    (68, "2 Peter",        "2 Pt",  "NT", 3,  "2+peter"),
    (69, "1 John",         "1 Jn",  "NT", 5,  "1+john"),
    (70, "2 John",         "2 Jn",  "NT", 1,  "2+john"),
    (71, "3 John",         "3 Jn",  "NT", 1,  "3+john"),
    (72, "Jude",           "Jude",  "NT", 1,  "jude"),
    (73, "Revelation",     "Rv",    "NT", 22, "revelation"),
]

# File groupings
FILE_GROUPS = {
    "nt_gospels":       [47, 48, 49, 50],
    "nt_acts_epistles": [51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65],
    "nt_catholic_rev":  [66, 67, 68, 69, 70, 71, 72, 73],
    "ot_law":           [1, 2, 3, 4, 5],
    "ot_history":       [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21],
    "ot_wisdom":        [22, 23, 24, 25, 26, 27, 28],
    "ot_prophets":      [29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46],
}

def fetch_chapter(api_name, chapter):
    """Fetch one chapter; returns list of verse texts or None on error."""
    url = f"{BASE_URL}/{api_name}+{chapter}?translation=kjv"
    try:
        with urllib.request.urlopen(url, timeout=15, context=SSL_CTX) as r:
            data = json.loads(r.read())
            verses = data.get("verses", [])
            # Sort by verse number
            verses.sort(key=lambda v: v["verse"])
            return [v["text"].strip() for v in verses]
    except Exception as e:
        return None

def placeholder_chapter(book_name, chapter, count=10):
    """Return placeholder verses when API doesn't have the book."""
    return [f"[{book_name} {chapter}:{v}] — Text not available in this edition." for v in range(1, count+1)]

def main():
    book_map = {b[0]: b for b in BOOKS}

    for file_name, book_ids in FILE_GROUPS.items():
        out_path = os.path.join(OUTPUT_DIR, f"{file_name}.json")
        if os.path.exists(out_path):
            print(f"SKIP (exists): {file_name}.json")
            continue

        print(f"\n=== Building {file_name}.json ===")
        books_data = []

        for book_id in book_ids:
            b = book_map[book_id]
            bid, bname, babbr, btestament, bchapters, bapi = b
            print(f"  {bname} ({bchapters} ch)...")
            chapters_data = []

            for ch in range(1, bchapters + 1):
                verses = fetch_chapter(bapi, ch)
                if verses:
                    chapters_data.append(verses)
                    print(f"    ch {ch}: {len(verses)} verses")
                else:
                    # Try fallback placeholder
                    chapters_data.append(placeholder_chapter(bname, ch))
                    print(f"    ch {ch}: PLACEHOLDER")
                time.sleep(0.15)  # be polite to the API

            books_data.append({
                "id": bid,
                "name": bname,
                "abbreviation": babbr,
                "testament": btestament,
                "chapters": chapters_data,
            })

        payload = {"version": 1, "books": books_data}
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, separators=(",", ":"))
        print(f"  -> Saved {file_name}.json ({os.path.getsize(out_path)//1024} KB)")

if __name__ == "__main__":
    main()
