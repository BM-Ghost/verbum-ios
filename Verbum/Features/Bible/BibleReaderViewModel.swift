import SwiftUI

@MainActor
final class BibleReaderViewModel: ObservableObject {
    @Published var state: VerbumResult<[Verse]> = .loading
    @Published var currentChapter: Int = 1
    @Published var fontSize: CGFloat = 18
    @Published var bookmarkedVerses: Set<String> = []

    let book: BibleBook
    private let repository: BibleRepository

    init(book: BibleBook, repository: BibleRepository? = nil) {
        self.book = book
        self.repository = repository ?? BibleRepository()
        loadChapter()
    }

    func loadChapter() {
        state = .loading
        let verses = repository.getVerses(bookId: book.id, chapter: currentChapter)
        state = .success(verses)
    }

    func nextChapter() {
        guard currentChapter < book.chapterCount else { return }
        currentChapter += 1
        loadChapter()
    }

    func previousChapter() {
        guard currentChapter > 1 else { return }
        currentChapter -= 1
        loadChapter()
    }

    func toggleBookmark(verseId: String) {
        if bookmarkedVerses.contains(verseId) {
            bookmarkedVerses.remove(verseId)
        } else {
            bookmarkedVerses.insert(verseId)
        }
    }

    func increaseFontSize() { fontSize = min(fontSize + 2, 32) }
    func decreaseFontSize() { fontSize = max(fontSize - 2, 12) }
}
