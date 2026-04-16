import Foundation

/// Bible data repository with bundled mock data.
@MainActor
final class BibleRepository: ObservableObject {

    func getBooks() -> [BibleBook] {
        Self.allBooks
    }

    func getVerses(bookId: Int, chapter: Int) -> [Verse] {
        let bookName = Self.allBooks.first(where: { $0.id == bookId })?.name ?? "Unknown"
        // Realistic sample verses for John 1
        if bookId == 50 && chapter == 1 {
            return Self.john1Verses
        }
        // Generate placeholder verses for other books
        return (1...20).map { v in
            Verse(bookId: bookId, bookName: bookName, chapter: chapter, verseNumber: v,
                  text: "And the word of the Lord came to pass in those days, teaching all nations the truth of salvation.")
        }
    }

    func searchVerses(query: String) -> [Verse] {
        guard query.count >= 3 else { return [] }
        let q = query.lowercased()
        return Self.john1Verses.filter { $0.text.lowercased().contains(q) }
    }

    // MARK: - Sample Data

    static let john1Verses: [Verse] = [
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 1, text: "In the beginning was the Word, and the Word was with God, and the Word was God."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 2, text: "He was in the beginning with God."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 3, text: "All things were made through him, and without him was not any thing made that was made."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 4, text: "In him was life, and the life was the light of men."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 5, text: "The light shines in the darkness, and the darkness has not overcome it."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 6, text: "There was a man sent from God, whose name was John."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 7, text: "He came as a witness, to bear witness about the light, that all might believe through him."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 8, text: "He was not the light, but came to bear witness about the light."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 9, text: "The true light, which gives light to everyone, was coming into the world."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 10, text: "He was in the world, and the world was made through him, yet the world did not know him."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 11, text: "He came to his own, and his own people did not receive him."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 12, text: "But to all who did receive him, who believed in his name, he gave the right to become children of God."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 13, text: "Who were born, not of blood nor of the will of the flesh nor of the will of man, but of God."),
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 14, text: "And the Word became flesh and dwelt among us, and we have seen his glory, glory as of the only Son from the Father, full of grace and truth."),
    ]

    static let allBooks: [BibleBook] = {
        var books: [BibleBook] = []
        // Old Testament (Catholic Canon = 46 books)
        let ot: [(Int, String, String, Int)] = [
            (1, "Genesis", "Gn", 50), (2, "Exodus", "Ex", 40), (3, "Leviticus", "Lv", 27), (4, "Numbers", "Nm", 36),
            (5, "Deuteronomy", "Dt", 34), (6, "Joshua", "Jos", 24), (7, "Judges", "Jgs", 21), (8, "Ruth", "Ru", 4),
            (9, "1 Samuel", "1 Sm", 31), (10, "2 Samuel", "2 Sm", 24), (11, "1 Kings", "1 Kgs", 22), (12, "2 Kings", "2 Kgs", 25),
            (13, "1 Chronicles", "1 Chr", 29), (14, "2 Chronicles", "2 Chr", 36), (15, "Ezra", "Ezr", 10), (16, "Nehemiah", "Neh", 13),
            (17, "Tobit", "Tb", 14), (18, "Judith", "Jdt", 16), (19, "Esther", "Est", 10), (20, "1 Maccabees", "1 Mc", 16),
            (21, "2 Maccabees", "2 Mc", 15), (22, "Job", "Jb", 42), (23, "Psalms", "Ps", 150), (24, "Proverbs", "Prv", 31),
            (25, "Ecclesiastes", "Eccl", 12), (26, "Song of Songs", "Sg", 8), (27, "Wisdom", "Wis", 19), (28, "Sirach", "Sir", 51),
            (29, "Isaiah", "Is", 66), (30, "Jeremiah", "Jer", 52), (31, "Lamentations", "Lam", 5), (32, "Baruch", "Bar", 6),
            (33, "Ezekiel", "Ez", 48), (34, "Daniel", "Dn", 14), (35, "Hosea", "Hos", 14), (36, "Joel", "Jl", 4),
            (37, "Amos", "Am", 9), (38, "Obadiah", "Ob", 1), (39, "Jonah", "Jon", 4), (40, "Micah", "Mi", 7),
            (41, "Nahum", "Na", 3), (42, "Habakkuk", "Hb", 3), (43, "Zephaniah", "Zep", 3), (44, "Haggai", "Hg", 2),
            (45, "Zechariah", "Zec", 14), (46, "Malachi", "Mal", 4),
        ]
        for (id, name, abbr, ch) in ot {
            books.append(BibleBook(id: id, name: name, abbreviation: abbr, testament: .old, totalChapters: ch))
        }
        // New Testament (27 books)
        let nt: [(Int, String, String, Int)] = [
            (47, "Matthew", "Mt", 28), (48, "Mark", "Mk", 16), (49, "Luke", "Lk", 24), (50, "John", "Jn", 21),
            (51, "Acts", "Acts", 28), (52, "Romans", "Rom", 16), (53, "1 Corinthians", "1 Cor", 16), (54, "2 Corinthians", "2 Cor", 13),
            (55, "Galatians", "Gal", 6), (56, "Ephesians", "Eph", 6), (57, "Philippians", "Phil", 4), (58, "Colossians", "Col", 4),
            (59, "1 Thessalonians", "1 Thes", 5), (60, "2 Thessalonians", "2 Thes", 3), (61, "1 Timothy", "1 Tm", 6),
            (62, "2 Timothy", "2 Tm", 4), (63, "Titus", "Ti", 3), (64, "Philemon", "Phlm", 1), (65, "Hebrews", "Heb", 13),
            (66, "James", "Jas", 5), (67, "1 Peter", "1 Pt", 5), (68, "2 Peter", "2 Pt", 3), (69, "1 John", "1 Jn", 5),
            (70, "2 John", "2 Jn", 1), (71, "3 John", "3 Jn", 1), (72, "Jude", "Jude", 1), (73, "Revelation", "Rv", 22),
        ]
        for (id, name, abbr, ch) in nt {
            books.append(BibleBook(id: id, name: name, abbreviation: abbr, testament: .new, totalChapters: ch))
        }
        return books
    }()
}
