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

    static let currentVersion = 2
    private static let versionKey = "BIBLE_SEED_VERSION"

    // File names bundled in Verbum/Resources/Bible/
    private static let bibleFiles: [String] = [
        "nt_gospels",
        "nt_acts_epistles",
        "nt_catholic_rev",
        "ot_law",
        "ot_history",
        "ot_wisdom",
        "ot_prophets",
    ]

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

    // MARK: - Private

    private func performSeed() async {
        // Clear existing data
        try? modelContext.delete(model: BibleBookEntity.self)
        try? modelContext.delete(model: BibleVerseEntity.self)

        var batchBuffer: [BibleVerseEntity] = []
        batchBuffer.reserveCapacity(500)

        for fileName in Self.bibleFiles {
            guard
                let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let file = try? JSONDecoder().decode(BibleFileJSON.self, from: data)
            else {
                continue
            }

            for book in file.books {
                let testament = book.testament == "OT" ? "OT" : "NT"
                let bookEntity = BibleBookEntity(
                    id: book.id,
                    name: book.name,
                    abbreviation: book.abbreviation,
                    testament: testament,
                    totalChapters: book.chapters.count,
                    orderIndex: book.id
                )
                modelContext.insert(bookEntity)

                for (chapterIndex, verses) in book.chapters.enumerated() {
                    let chapterNumber = chapterIndex + 1
                    for (verseIndex, text) in verses.enumerated() {
                        let verseNumber = verseIndex + 1
                        let verseEntity = BibleVerseEntity(
                            bookId: book.id,
                            chapter: chapterNumber,
                            verse: verseNumber,
                            text: text
                        )
                        batchBuffer.append(verseEntity)
                        if batchBuffer.count >= 500 {
                            flushBatch(&batchBuffer)
                        }
                    }
                }
            }
        }

        flushBatch(&batchBuffer)
        try? modelContext.save()

        UserDefaults.standard.set(Self.currentVersion, forKey: Self.versionKey)
    }

    private func flushBatch(_ buffer: inout [BibleVerseEntity]) {
        for entity in buffer {
            modelContext.insert(entity)
        }
        buffer.removeAll(keepingCapacity: true)
    }
}
