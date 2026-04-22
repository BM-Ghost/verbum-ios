import Foundation

// MARK: - Supporting types

struct SearchResult: Identifiable {
    var id: String { verse.id }
    let verse: Verse
    let rank: SearchRank
}

enum SearchRank: Comparable {
    /// Matched a scripture reference like "John 3:16" or "Gen 1:2-5".
    case reference
    /// The full query phrase appears verbatim in the verse text.
    case exactPhrase
    /// Every word in the query appears in the verse text.
    case allWords
    /// At least one word in the query appears in the verse text.
    case anyWord
}

struct ScriptureRef {
    let book: String
    let chapter: Int
    let verseStart: Int?
    let verseEnd: Int?
}

struct InReaderNav {
    let chapter: Int
    let verse: Int?
}

// MARK: - SearchBibleUseCase

/// Smart Bible search that mirrors the Android implementation and extends it:
///
/// **Reference search** — "John 3:16", "Gen 1", "1 Cor 13:4-7", "Ps 23"
///   Handles concatenated input ("Genesis1 2" → Genesis 1:2, "1cor13:4" → 1 Cor 13:4)
///
/// **Fuzzy book resolution** — "Genoasis 2:1" → Genesis 2:1, "Phillipians 4" → Philippians 4
///   Strategy: exact alias → prefix → Levenshtein distance
///
/// **Ranked full-text search** — exact phrase > all words > any word
///   Results are scored and sorted; the currently open book is boosted.
///
/// **In-reader shorthand** — "16" → verse 16 of current chapter; "3:16" → ch 3 v 16
@MainActor
final class SearchBibleUseCase {

    private let repository: BibleRepository

    init(repository: BibleRepository) {
        self.repository = repository
    }

    // MARK: - Public API

    /// Returns ranked search results for `query`.
    ///
    /// - Parameters:
    ///   - query: The raw search string (≥ 2 characters; shorter returns empty).
    ///   - preferredBookId: Boost verses from this book (e.g. the currently open book).
    ///   - limit: Maximum results to return (default 50).
    func search(query: String, preferredBookId: Int? = nil, limit: Int = 50) -> [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else { return [] }

        // 1. Try scripture reference — highest priority, resolves directly to verses.
        if let ref = parseReference(trimmed) {
            let verses = repository.searchByReference(
                bookQuery: ref.book,
                chapter: ref.chapter,
                verseStart: ref.verseStart,
                verseEnd: ref.verseEnd
            )
            if !verses.isEmpty {
                return verses.map { SearchResult(verse: $0, rank: .reference) }
            }
        }

        // 2. Ranked full-text search.
        return rankedSearch(query: trimmed, preferredBookId: preferredBookId, limit: limit)
    }

    /// Parse an in-reader jump shorthand (used while a book is open).
    ///
    /// - `"16"`    → verse 16 of `currentChapter`
    /// - `"3:16"`  → chapter 3, verse 16
    /// - `"3 16"`  → chapter 3, verse 16
    func parseInReaderShorthand(query: String, currentChapter: Int) -> InReaderNav? {
        let s = query.trimmingCharacters(in: .whitespaces)
        // Plain verse number.
        if let v = Int(s), v >= 1 {
            return InReaderNav(chapter: currentChapter, verse: v)
        }
        // chapter:verse, chapter.verse, or "chapter verse".
        guard let _ = s.range(of: #"^(\d+)\s*[:\s.]\s*(\d+)$"#, options: .regularExpression) else {
            return nil
        }
        let parts = s.components(separatedBy: CharacterSet(charactersIn: ":. ")).filter { !$0.isEmpty }
        guard parts.count >= 2, let ch = Int(parts[0]), let v = Int(parts[1]) else { return nil }
        return InReaderNav(chapter: ch, verse: v)
    }

    // MARK: - Reference parsing

    func parseReference(_ input: String) -> ScriptureRef? {
        let s = input
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        // Group 1 = book  : optional leading digit + letters (+ optional second word, e.g. "Song of")
        // Group 2 = chapter: digits, may be glued to letters ("Genesis1")
        // Group 3 = verse  : optional, separated by ':', ' ', or '.'
        // Group 4 = end    : optional verse-range end after '-' or '–'
        let pattern =
            #"^(\d?\s*[A-Za-z]+(?:\s+[A-Za-z]+)?)\s*(\d+)(?:[\s:.]\s*(\d+)(?:\s*[-–]\s*(\d+))?)?$"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsRange = NSRange(s.startIndex..., in: s)
        guard let m = regex.firstMatch(in: s, range: nsRange) else { return nil }

        func capture(_ i: Int) -> String? {
            guard let r = Range(m.range(at: i), in: s) else { return nil }
            let v = String(s[r]).trimmingCharacters(in: .whitespaces)
            return v.isEmpty ? nil : v
        }

        guard let bookRaw = capture(1),
              let chapterStr = capture(2),
              let chapter = Int(chapterStr) else { return nil }

        let verseStart = capture(3).flatMap(Int.init)
        let verseEnd   = capture(4).flatMap(Int.init)
        let resolvedBook = fuzzyResolveBook(bookRaw) ?? bookRaw

        return ScriptureRef(
            book: resolvedBook,
            chapter: chapter,
            verseStart: verseStart,
            verseEnd: verseEnd ?? verseStart
        )
    }

    // MARK: - Fuzzy book name resolution

    /// Resolve a potentially misspelled or abbreviated book name.
    /// Strategy: exact alias → prefix (≥ 3 chars) → Levenshtein fuzzy.
    func fuzzyResolveBook(_ input: String) -> String? {
        let q = input.trimmingCharacters(in: .whitespaces).lowercased()

        // 1. Exact alias match.
        if let book = Self.bookAliases.first(where: { _, aliases in aliases.contains(q) })?.key {
            return book
        }

        // 2. Prefix match (require at least 3 input chars).
        if q.count >= 3 {
            if let book = Self.bookAliases.first(where: { _, aliases in
                aliases.contains { $0.count >= q.count && $0.hasPrefix(q) }
            })?.key {
                return book
            }
        }

        // 3. Levenshtein — threshold scales with query length.
        let threshold = q.count <= 3 ? 1 : q.count <= 5 ? 2 : 3
        var bestBook: String?
        var bestDist = Int.max

        for (book, aliases) in Self.bookAliases {
            for alias in aliases {
                guard abs(alias.count - q.count) <= threshold + 1 else { continue }
                let dist = levenshtein(q, alias)
                if dist < bestDist && dist <= threshold {
                    bestDist = dist
                    bestBook = book
                }
            }
        }
        return bestBook
    }

    // MARK: - Ranked full-text search

    private func rankedSearch(query: String, preferredBookId: Int?, limit: Int) -> [SearchResult] {
        let phrase = query.lowercased()
        let words  = phrase.split(separator: " ").map(String.init).filter { $0.count >= 2 }
        guard !words.isEmpty else { return [] }

        var results: [(verse: Verse, rank: SearchRank, score: Int)] = []

        for verse in repository.allVerses() {
            let text = verse.text.lowercased()
            let rank: SearchRank
            var score = 0

            if text.contains(phrase) {
                rank = .exactPhrase
                // Higher score for earlier match (shorter offset).
                if let r = text.range(of: phrase) {
                    score = max(0, 200 - text.distance(from: text.startIndex, to: r.lowerBound))
                }
            } else if words.allSatisfy({ text.contains($0) }) {
                rank = .allWords
                // More matched words → higher score.
                score = words.count * 20
            } else {
                let matchCount = words.filter { text.contains($0) }.count
                guard matchCount > 0 else { continue }
                rank = .anyWord
                score = matchCount * 10
            }

            // Boost results from the currently open book.
            if verse.bookId == preferredBookId { score += 500 }

            results.append((verse, rank, score))
        }

        return results
            .sorted { lhs, rhs in
                if lhs.rank != rhs.rank { return lhs.rank < rhs.rank }
                return lhs.score > rhs.score
            }
            .prefix(limit)
            .map { SearchResult(verse: $0.verse, rank: $0.rank) }
    }

    // MARK: - Levenshtein distance

    private func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a), bChars = Array(b)
        let m = aChars.count, n = bChars.count
        var dp = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }
        for i in 1...m {
            for j in 1...n {
                dp[i][j] = aChars[i - 1] == bChars[j - 1]
                    ? dp[i - 1][j - 1]
                    : 1 + min(dp[i - 1][j - 1], min(dp[i - 1][j], dp[i][j - 1]))
            }
        }
        return dp[m][n]
    }

    // MARK: - Book aliases (Catholic canon — 73 books)

    static let bookAliases: [String: [String]] = [
        "Genesis"         : ["genesis", "gen", "ge", "gn"],
        "Exodus"          : ["exodus", "exod", "exo", "ex"],
        "Leviticus"       : ["leviticus", "lev", "le", "lv"],
        "Numbers"         : ["numbers", "num", "nu", "nb", "nm"],
        "Deuteronomy"     : ["deuteronomy", "deut", "deu", "dt"],
        "Joshua"          : ["joshua", "josh", "jos"],
        "Judges"          : ["judges", "judg", "jdg", "jgs"],
        "Ruth"            : ["ruth", "ru"],
        "1 Samuel"        : ["1 samuel", "1samuel", "1sam", "1sa", "1 sm", "1sm"],
        "2 Samuel"        : ["2 samuel", "2samuel", "2sam", "2sa", "2 sm", "2sm"],
        "1 Kings"         : ["1 kings", "1kings", "1ki", "1kgs", "1 kgs"],
        "2 Kings"         : ["2 kings", "2kings", "2ki", "2kgs", "2 kgs"],
        "1 Chronicles"    : ["1 chronicles", "1chronicles", "1chr", "1ch", "1chron", "1 chr"],
        "2 Chronicles"    : ["2 chronicles", "2chronicles", "2chr", "2ch", "2chron", "2 chr"],
        "Ezra"            : ["ezra", "ezr", "ez"],
        "Nehemiah"        : ["nehemiah", "neh", "ne"],
        "Tobit"           : ["tobit", "tob", "tb"],
        "Judith"          : ["judith", "jdt"],
        "Esther"          : ["esther", "est", "esth"],
        "1 Maccabees"     : ["1 maccabees", "1maccabees", "1 macc", "1macc", "1 mc", "1mc"],
        "2 Maccabees"     : ["2 maccabees", "2maccabees", "2 macc", "2macc", "2 mc", "2mc"],
        "Job"             : ["job", "jb"],
        "Psalms"          : ["psalms", "psalm", "ps", "psa"],
        "Proverbs"        : ["proverbs", "prov", "pro", "prv"],
        "Ecclesiastes"    : ["ecclesiastes", "eccl", "ecc", "qoh"],
        "Song of Songs"   : ["song of songs", "song of solomon", "song", "sos", "cant", "sg"],
        "Wisdom"          : ["wisdom", "wis"],
        "Sirach"          : ["sirach", "sir", "ecclesiasticus"],
        "Isaiah"          : ["isaiah", "isa", "is"],
        "Jeremiah"        : ["jeremiah", "jer", "je"],
        "Lamentations"    : ["lamentations", "lam", "la"],
        "Baruch"          : ["baruch", "bar"],
        "Ezekiel"         : ["ezekiel", "ezek", "eze", "ez"],
        "Daniel"          : ["daniel", "dan", "da", "dn"],
        "Hosea"           : ["hosea", "hos", "ho"],
        "Joel"            : ["joel", "jl"],
        "Amos"            : ["amos", "am"],
        "Obadiah"         : ["obadiah", "obad", "ob"],
        "Jonah"           : ["jonah", "jon"],
        "Micah"           : ["micah", "mic", "mi"],
        "Nahum"           : ["nahum", "nah", "na"],
        "Habakkuk"        : ["habakkuk", "hab", "hb"],
        "Zephaniah"       : ["zephaniah", "zeph", "zep"],
        "Haggai"          : ["haggai", "hag", "hg"],
        "Zechariah"       : ["zechariah", "zech", "zec"],
        "Malachi"         : ["malachi", "mal"],
        "Matthew"         : ["matthew", "matt", "mat", "mt"],
        "Mark"            : ["mark", "mk", "mar"],
        "Luke"            : ["luke", "lk", "luk"],
        "John"            : ["john", "jn", "joh"],
        "Acts"            : ["acts", "act", "ac"],
        "Romans"          : ["romans", "rom", "ro"],
        "1 Corinthians"   : ["1 corinthians", "1corinthians", "1cor", "1co"],
        "2 Corinthians"   : ["2 corinthians", "2corinthians", "2cor", "2co"],
        "Galatians"       : ["galatians", "gal", "ga"],
        "Ephesians"       : ["ephesians", "eph"],
        "Philippians"     : ["philippians", "phil"],
        "Colossians"      : ["colossians", "col"],
        "1 Thessalonians" : ["1 thessalonians", "1thessalonians", "1thess", "1th"],
        "2 Thessalonians" : ["2 thessalonians", "2thessalonians", "2thess", "2th"],
        "1 Timothy"       : ["1 timothy", "1timothy", "1tim", "1ti", "1 tm", "1tm"],
        "2 Timothy"       : ["2 timothy", "2timothy", "2tim", "2ti", "2 tm", "2tm"],
        "Titus"           : ["titus", "tit"],
        "Philemon"        : ["philemon", "phlm", "phm"],
        "Hebrews"         : ["hebrews", "heb"],
        "James"           : ["james", "jas", "jm"],
        "1 Peter"         : ["1 peter", "1peter", "1pet", "1pe", "1 pt", "1pt"],
        "2 Peter"         : ["2 peter", "2peter", "2pet", "2pe", "2 pt", "2pt"],
        "1 John"          : ["1 john", "1john", "1jn", "1jo"],
        "2 John"          : ["2 john", "2john", "2jn", "2jo"],
        "3 John"          : ["3 john", "3john", "3jn", "3jo"],
        "Jude"            : ["jude", "jud"],
        "Revelation"      : ["revelation", "rev", "re", "apoc", "apocalypse", "rv"],
    ]
}
