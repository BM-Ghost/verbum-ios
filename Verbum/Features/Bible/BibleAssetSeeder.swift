import Foundation
import SwiftData

// MARK: - Codable structures for JSON parsing

private struct BibleBookJSON: Codable {
    let id: Int
    let name: String
    let abbreviation: String
    let testament: String   // "OT" or "NT"
    let chapters: [[String]] // chapters[0] = ch1 verses, chapters[0][0] = ch1 v1
}

private struct BibleFileJSON: Codable {
    let version: Int
    let books: [BibleBookJSON]
}

// MARK: - BibleAssetSeeder

/// Seeds the SwiftData store with the complete Douay-Rheims (Challoner revision) Bible on first launch.
/// Checks `BIBLE_SEED_VERSION` in UserDefaults; re-seeds when the bundled data version bumps.
actor BibleAssetSeeder {

    static let currentVersion = 2025
    private static let versionKey = "BIBLE_SEED_VERSION"
    private static let onlineDataHashKey = "BIBLE_ONLINE_DATA_HASH"

    // File names bundled in Verbum/Resources/Bible/
    private let modelContext: ModelContext
    private var hasSeeded = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Idempotent — safe to call on every launch; only seeds when version changes.
    func seed() async {
        guard !hasSeeded else { return }
        let stored = UserDefaults.standard.integer(forKey: Self.versionKey)
        guard stored < Self.currentVersion else {
            hasSeeded = true
            return
        }
        await performSeed()
        hasSeeded = true
    }

    func refreshDrcFromOnline() async throws -> Int {
        let url = URL(string: "https://raw.githubusercontent.com/scrollmapper/bible_databases/2025/formats/csv/DRC.csv")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        guard let csv = String(data: data, encoding: .utf8) else { throw URLError(.cannotDecodeContentData) }
        
        // Check if data has changed by comparing hash
        let newDataHash = csv.hash
        let storedHash = UserDefaults.standard.string(forKey: Self.onlineDataHashKey)
        if storedHash == String(newDataHash) {
            // Data hasn't changed, skip refresh
            return 0
        }
        
        let books = BibleRepository.allBooks
        let rows = csvRows(csv)
        guard rows.count > 30_000 else { throw URLError(.cannotParseResponse) }
        
        // Parse all new verses into memory first
        var newVerses: [(bookId: Int, chapter: Int, verse: Int, text: String)] = []
        let sourceNames = Self.sourceBookNames
        for row in csvRows(csv).dropFirst() {
            guard row.count >= 4,
                  let abbreviation = sourceNames[row[0].trimmingCharacters(in: .whitespacesAndNewlines)],
                  let bookId = books.first(where: { $0.abbreviation == abbreviation })?.id,
                  let chapter = Int(row[1]),
                  let verse = Int(row[2]),
                  !row[3].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            let text = row[3].replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
            newVerses.append((bookId, chapter, verse, text))
        }
        
        // Update verses in place to avoid empty database window
        // First, fetch all existing verses
        let existingDescriptor = FetchDescriptor<BibleVerseEntity>()
        let existingVerses = (try? modelContext.fetch(existingDescriptor)) ?? []
        let existingMap = Dictionary(uniqueKeysWithValues: existingVerses.map { (key: "\($0.bookId)_\($0.chapter)_\($0.verse)", value: $0) })
        
        // Update existing or insert new verses
        for verse in newVerses {
            let key = "\(verse.bookId)_\(verse.chapter)_\(verse.verse)"
            if let existing = existingMap[key] {
                existing.text = verse.text
            } else {
                modelContext.insert(BibleVerseEntity(bookId: verse.bookId, chapter: verse.chapter, verse: verse.verse, text: verse.text))
            }
        }
        
        // Delete verses that no longer exist in new data
        let newKeys = Set(newVerses.map { "\($0.bookId)_\($0.chapter)_\($0.verse)" })
        for (key, entity) in existingMap {
            if !newKeys.contains(key) {
                modelContext.delete(entity)
            }
        }
        
        try modelContext.save()
        
        // Store the new hash
        UserDefaults.standard.set(String(newDataHash), forKey: Self.onlineDataHashKey)
        
        return rows.count - 1
    }

    // MARK: - Private

    private func performSeed() async {
        // Clear existing data
        try? modelContext.delete(model: BibleBookEntity.self)
        try? modelContext.delete(model: BibleVerseEntity.self)
        try? modelContext.delete(model: BibleCrossReferenceEntity.self)

        let books = BibleRepository.allBooks
        for book in books {
            modelContext.insert(BibleBookEntity(
                id: book.id,
                name: book.name,
                abbreviation: book.abbreviation,
                testament: book.testament == .old ? "OT" : "NT",
                totalChapters: book.totalChapters,
                orderIndex: book.id
            ))
        }

        if let csvURL = Bundle.main.url(forResource: "DRC", withExtension: "csv", subdirectory: "Bible/scrollmapper"),
           let csv = try? String(contentsOf: csvURL, encoding: .utf8) {
            seedVerses(from: csv, books: books)
        }

        if let referencesURL = Bundle.main.url(forResource: "cross_references", withExtension: "txt", subdirectory: "Bible/scrollmapper"),
           let references = try? String(contentsOf: referencesURL, encoding: .utf8) {
            seedCrossReferences(from: references, books: books)
        }

        try? modelContext.save()

        UserDefaults.standard.set(Self.currentVersion, forKey: Self.versionKey)
    }

    private func seedVerses(from csv: String, books: [BibleBook]) {
        let sourceNames = Self.sourceBookNames
        for row in csvRows(csv).dropFirst() {
            guard row.count >= 4,
                  let abbreviation = sourceNames[row[0].trimmingCharacters(in: .whitespacesAndNewlines)],
                  let bookId = books.first(where: { $0.abbreviation == abbreviation })?.id,
                  let chapter = Int(row[1]),
                  let verse = Int(row[2]),
                  !row[3].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            modelContext.insert(BibleVerseEntity(bookId: bookId, chapter: chapter, verse: verse, text: row[3].replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)))
        }
    }

    private func seedCrossReferences(from source: String, books: [BibleBook]) {
        let aliases = Self.crossReferenceAliases
        let bookIDs = Dictionary(uniqueKeysWithValues: books.map { ($0.abbreviation, $0.id) })
        for line in source.split(whereSeparator: \.isNewline).dropFirst() {
            let columns = line.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
            guard columns.count >= 3,
                  let from = parseReference(columns[0], aliases: aliases, bookIDs: bookIDs),
                  let to = parseReference(columns[1], aliases: aliases, bookIDs: bookIDs),
                  let votes = Int(columns[2]) else { continue }
            modelContext.insert(BibleCrossReferenceEntity(fromBookId: from.bookId, fromChapter: from.chapter, fromVerse: from.verse, toBookId: to.bookId, toChapter: to.chapter, toVerseStart: to.verse, toVerseEnd: to.verseEnd, votes: votes))
        }
    }

    private func parseReference(_ value: String, aliases: [String: String], bookIDs: [String: Int]) -> (bookId: Int, chapter: Int, verse: Int, verseEnd: Int)? {
        let endpoints = value.split(separator: "-", omittingEmptySubsequences: false).map(String.init)
        let start = endpoints[0].split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        guard start.count == 3, let abbreviation = aliases[start[0]], let bookId = bookIDs[abbreviation], let chapter = Int(start[1]), let verse = Int(start[2]) else { return nil }
        let verseEnd: Int
        if endpoints.count == 2 {
            let end = endpoints[1].split(separator: ".", omittingEmptySubsequences: false).map(String.init)
            guard end.count == 3, end[0] == start[0], Int(end[1]) == chapter, let parsedEnd = Int(end[2]) else { return nil }
            verseEnd = parsedEnd
        } else {
            verseEnd = verse
        }
        guard verseEnd >= verse else { return nil }
        return (bookId, chapter, verse, verseEnd)
    }

    private func csvRows(_ content: String) -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var quoted = false
        for character in content {
            if character == "\"" { quoted.toggle() }
            else if character == "," && !quoted { row.append(field); field = "" }
            else if character.isNewline && !quoted { row.append(field); field = ""; if !row.isEmpty { rows.append(row); row = [] } }
            else { field.append(character) }
        }
        if !field.isEmpty || !row.isEmpty { row.append(field); rows.append(row) }
        return rows
    }

    private func flushBatch(_ buffer: inout [BibleVerseEntity]) {
        for entity in buffer {
            modelContext.insert(entity)
        }
        buffer.removeAll(keepingCapacity: true)
    }

    private static let sourceBookNames: [String: String] = [
        "Genesis": "Gn", "Exodus": "Ex", "Leviticus": "Lv", "Numbers": "Nm", "Deuteronomy": "Dt",
        "Joshua": "Jos", "Judges": "Jgs", "Ruth": "Ru", "I Samuel": "1 Sm", "II Samuel": "2 Sm",
        "I Kings": "1 Kgs", "II Kings": "2 Kgs", "I Chronicles": "1 Chr", "II Chronicles": "2 Chr",
        "Ezra": "Ezr", "Nehemiah": "Neh", "Tobit": "Tb", "Judith": "Jdt", "Esther": "Est",
        "Job": "Jb", "Psalms": "Ps", "Proverbs": "Prv", "Ecclesiastes": "Eccl", "Song of Solomon": "Sg",
        "Wisdom": "Wis", "Sirach": "Sir", "Isaiah": "Is", "Jeremiah": "Jer", "Lamentations": "Lam",
        "Baruch": "Bar", "Ezekiel": "Ez", "Daniel": "Dn", "Hosea": "Hos", "Joel": "Jl", "Amos": "Am",
        "Obadiah": "Ob", "Jonah": "Jon", "Micah": "Mi", "Nahum": "Na", "Habakkuk": "Hb", "Zephaniah": "Zep",
        "Haggai": "Hg", "Zechariah": "Zec", "Malachi": "Mal", "I Maccabees": "1 Mc", "II Maccabees": "2 Mc",
        "Matthew": "Mt", "Mark": "Mk", "Luke": "Lk", "John": "Jn", "Acts": "Acts", "Romans": "Rom",
        "I Corinthians": "1 Cor", "II Corinthians": "2 Cor", "Galatians": "Gal", "Ephesians": "Eph",
        "Philippians": "Phil", "Colossians": "Col", "I Thessalonians": "1 Thes", "II Thessalonians": "2 Thes",
        "I Timothy": "1 Tm", "II Timothy": "2 Tm", "Titus": "Ti", "Philemon": "Phlm", "Hebrews": "Heb",
        "James": "Jas", "I Peter": "1 Pt", "II Peter": "2 Pt", "I John": "1 Jn", "II John": "2 Jn",
        "III John": "3 Jn", "Jude": "Jude", "Revelation of John": "Rv",
    ]

    private static let crossReferenceAliases: [String: String] = [
        "Gen": "Gn", "Exod": "Ex", "Lev": "Lv", "Num": "Nm", "Deut": "Dt", "Josh": "Jos", "Judg": "Jgs",
        "Ruth": "Ru", "1Sam": "1 Sm", "2Sam": "2 Sm", "1Kgs": "1 Kgs", "2Kgs": "2 Kgs", "1Chr": "1 Chr", "2Chr": "2 Chr",
        "Ezra": "Ezr", "Neh": "Neh", "Tob": "Tb", "Jdt": "Jdt", "Esth": "Est", "Job": "Jb", "Ps": "Ps", "Prov": "Prv",
        "Eccl": "Eccl", "Song": "Sg", "Wis": "Wis", "Sir": "Sir", "Isa": "Is", "Jer": "Jer", "Lam": "Lam", "Bar": "Bar",
        "Ezek": "Ez", "Dan": "Dn", "Hos": "Hos", "Joel": "Jl", "Amos": "Am", "Obad": "Ob", "Jonah": "Jon", "Mic": "Mi",
        "Nah": "Na", "Hab": "Hb", "Zeph": "Zep", "Hag": "Hg", "Zech": "Zec", "Mal": "Mal", "1Macc": "1 Mc", "2Macc": "2 Mc",
        "Matt": "Mt", "Mark": "Mk", "Luke": "Lk", "John": "Jn", "Acts": "Acts", "Rom": "Rom", "1Cor": "1 Cor", "2Cor": "2 Cor",
        "Gal": "Gal", "Eph": "Eph", "Phil": "Phil", "Col": "Col", "1Thess": "1 Thes", "2Thess": "2 Thes", "1Tim": "1 Tm", "2Tim": "2 Tm",
        "Titus": "Ti", "Phlm": "Phlm", "Heb": "Heb", "Jas": "Jas", "1Pet": "1 Pt", "2Pet": "2 Pt", "1John": "1 Jn", "2John": "2 Jn",
        "3John": "3 Jn", "Jude": "Jude", "Rev": "Rv",
    ]
}
