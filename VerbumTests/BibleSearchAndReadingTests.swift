import XCTest
@testable import Verbum

@MainActor
final class BibleSearchAndReadingTests: XCTestCase {
    private let readingPositionKey = "verbum_last_reading_position"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: readingPositionKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: readingPositionKey)
        super.tearDown()
    }

    func testReferenceSearchReturnsReferenceRankAndRange() {
        let repository = BibleRepository()
        let useCase = SearchBibleUseCase(repository: repository)

        let results = useCase.search(query: "John 1:3-4")

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.rank == .reference })
        XCTAssertEqual(results.map { $0.verse.verseNumber }, [3, 4])
        XCTAssertTrue(results.allSatisfy { $0.verse.bookName == "John" && $0.verse.chapter == 1 })
    }

    func testReferenceParsingSupportsFuzzyBookResolution() {
        let repository = BibleRepository()
        let useCase = SearchBibleUseCase(repository: repository)

        let ref = useCase.parseReference("Genoasis 1:2")

        XCTAssertNotNil(ref)
        XCTAssertEqual(ref?.book, "Genesis")
        XCTAssertEqual(ref?.chapter, 1)
        XCTAssertEqual(ref?.verseStart, 2)
        XCTAssertEqual(ref?.verseEnd, 2)
    }

    func testInReaderShorthandParsesVerseAndChapterVerse() {
        let repository = BibleRepository()
        let useCase = SearchBibleUseCase(repository: repository)

        let verseOnly = useCase.parseInReaderShorthand(query: "16", currentChapter: 5)
        XCTAssertEqual(verseOnly?.chapter, 5)
        XCTAssertEqual(verseOnly?.verse, 16)

        let chapterVerse = useCase.parseInReaderShorthand(query: "3:16", currentChapter: 5)
        XCTAssertEqual(chapterVerse?.chapter, 3)
        XCTAssertEqual(chapterVerse?.verse, 16)
    }

    func testReadingPositionPersistsAndRestores() {
        let repository = BibleRepository()

        repository.recordReadingPosition(bookId: 50, chapter: 2, verse: 7)
        let position = repository.lastReadPosition

        XCTAssertNotNil(position)
        XCTAssertEqual(position?.bookId, 50)
        XCTAssertEqual(position?.chapter, 2)
        XCTAssertEqual(position?.verse, 7)
    }
}
