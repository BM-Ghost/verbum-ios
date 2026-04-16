import Foundation

struct BibleBook: Identifiable, Hashable {
    let id: Int
    let name: String
    let abbreviation: String
    let testament: Testament
    let totalChapters: Int

    var chapterCount: Int { totalChapters }
}

enum Testament: String, CaseIterable {
    case old = "Old Testament"
    case new = "New Testament"
    var displayName: String { rawValue }
}

struct Verse: Identifiable, Hashable {
    var id: String { "\(bookId)_\(chapter)_\(verseNumber)" }
    let bookId: Int
    let bookName: String
    let chapter: Int
    let verseNumber: Int
    let text: String
    var isBookmarked: Bool = false
    var highlightColor: String? = nil
    var note: String? = nil
}

enum VerseActionType: CaseIterable {
    case bookmark, highlight, note, share, askAi
}
