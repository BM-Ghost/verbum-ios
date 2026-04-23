import XCTest
import SwiftData
@testable import Verbum

@MainActor
final class BibleSearchAndReadingTests: XCTestCase {
    private let readingPositionKey = "verbum_last_reading_position"
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let schema = Schema([
            BibleBookEntity.self,
            BibleVerseEntity.self,
            BookmarkEntity.self,
            ReadingHistoryEntity.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)

        seedBibleData()
        UserDefaults.standard.removeObject(forKey: readingPositionKey)
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: readingPositionKey)
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }

    private func makeRepository() -> BibleRepository {
        BibleRepository(modelContext: modelContext)
    }

    private func seedBibleData() {
        for book in BibleRepository.allBooks {
            modelContext.insert(
                BibleBookEntity(
                    id: book.id,
                    name: book.name,
                    abbreviation: book.abbreviation,
                    testament: book.testament == .old ? "OT" : "NT",
                    totalChapters: book.totalChapters,
                    orderIndex: book.id
                )
            )
        }

        for verse in BibleRepository.john1Verses {
            modelContext.insert(
                BibleVerseEntity(
                    bookId: verse.bookId,
                    chapter: verse.chapter,
                    verse: verse.verseNumber,
                    text: verse.text
                )
            )
        }

        try? modelContext.save()
    }

    func testReferenceSearchReturnsReferenceRankAndRange() {
        let repository = makeRepository()
        let useCase = SearchBibleUseCase(repository: repository)

        let results = useCase.search(query: "John 1:3-4")

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.rank == SearchRank.reference })
        XCTAssertEqual(results.map { $0.verse.verseNumber }, [3, 4])
        XCTAssertTrue(results.allSatisfy { $0.verse.bookName == "John" && $0.verse.chapter == 1 })
    }

    func testReferenceParsingSupportsFuzzyBookResolution() {
        let repository = makeRepository()
        let useCase = SearchBibleUseCase(repository: repository)

        let ref = useCase.parseReference("Genoasis 1:2")

        XCTAssertNotNil(ref)
        XCTAssertEqual(ref?.book, "Genesis")
        XCTAssertEqual(ref?.chapter, 1)
        XCTAssertEqual(ref?.verseStart, 2)
        XCTAssertEqual(ref?.verseEnd, 2)
    }

    func testInReaderShorthandParsesVerseAndChapterVerse() {
        let repository = makeRepository()
        let useCase = SearchBibleUseCase(repository: repository)

        let verseOnly = useCase.parseInReaderShorthand(query: "16", currentChapter: 5)
        XCTAssertEqual(verseOnly?.chapter, 5)
        XCTAssertEqual(verseOnly?.verse, 16)

        let chapterVerse = useCase.parseInReaderShorthand(query: "3:16", currentChapter: 5)
        XCTAssertEqual(chapterVerse?.chapter, 3)
        XCTAssertEqual(chapterVerse?.verse, 16)
    }

    func testReadingPositionPersistsAndRestores() {
        let repository = makeRepository()

        repository.recordReadingPosition(bookId: 50, chapter: 2, verse: 7)
        let position = repository.lastReadPosition

        XCTAssertNotNil(position)
        XCTAssertEqual(position?.bookId, 50)
        XCTAssertEqual(position?.chapter, 2)
        XCTAssertEqual(position?.verse, 7)
    }
}
