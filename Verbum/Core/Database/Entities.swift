import SwiftData
import Foundation

// MARK: - SwiftData Entities (equivalent to Room entities)

@Model
final class BibleBookEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var abbreviation: String
    var testament: String  // "OT" or "NT"
    var totalChapters: Int
    var orderIndex: Int

    init(id: Int, name: String, abbreviation: String, testament: String, totalChapters: Int, orderIndex: Int) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.testament = testament
        self.totalChapters = totalChapters
        self.orderIndex = orderIndex
    }
}

@Model
final class BibleVerseEntity {
    var bookId: Int
    var chapter: Int
    var verse: Int
    var text: String

    init(bookId: Int, chapter: Int, verse: Int, text: String) {
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.text = text
    }
}

@Model
final class BookmarkEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int
    var chapter: Int
    var verse: Int
    var note: String?
    var highlightColorHex: String?
    var createdAt: Date

    init(bookId: Int, chapter: Int, verse: Int, note: String? = nil, highlightColorHex: String? = nil) {
        self.id = UUID()
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.note = note
        self.highlightColorHex = highlightColorHex
        self.createdAt = Date()
    }
}

@Model
final class MissalReadingEntity {
    @Attribute(.unique) var id: String
    var date: String
    var readingType: String
    var title: String
    var reference: String
    var text: String
    var liturgicalSeason: String
    var feastOrMemorial: String?

    init(id: String, date: String, readingType: String, title: String, reference: String, text: String, liturgicalSeason: String, feastOrMemorial: String? = nil) {
        self.id = id
        self.date = date
        self.readingType = readingType
        self.title = title
        self.reference = reference
        self.text = text
        self.liturgicalSeason = liturgicalSeason
        self.feastOrMemorial = feastOrMemorial
    }
}

@Model
final class PrayerEntity {
    @Attribute(.unique) var id: String
    var title: String
    var category: String
    var text: String
    var latinText: String?
    var seasonRecommendation: String?
    var orderIndex: Int

    init(id: String, title: String, category: String, text: String, latinText: String? = nil, seasonRecommendation: String? = nil, orderIndex: Int = 0) {
        self.id = id
        self.title = title
        self.category = category
        self.text = text
        self.latinText = latinText
        self.seasonRecommendation = seasonRecommendation
        self.orderIndex = orderIndex
    }
}

@Model
final class CommunityPostCacheEntity {
    @Attribute(.unique) var id: String
    var authorId: String
    var authorName: String
    var authorAvatarUrl: String?
    var content: String
    var verseReference: String?
    var verseText: String?
    var tags: String  // comma-separated
    var amenCount: Int
    var commentCount: Int
    var createdAt: Int64
    var updatedAt: Int64

    init(id: String, authorId: String, authorName: String, authorAvatarUrl: String? = nil, content: String, verseReference: String? = nil, verseText: String? = nil, tags: String = "", amenCount: Int = 0, commentCount: Int = 0, createdAt: Int64, updatedAt: Int64) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatarUrl = authorAvatarUrl
        self.content = content
        self.verseReference = verseReference
        self.verseText = verseText
        self.tags = tags
        self.amenCount = amenCount
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class ReadingHistoryEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int
    var chapter: Int
    var lastVerse: Int
    var timestamp: Date

    init(bookId: Int, chapter: Int, lastVerse: Int) {
        self.id = UUID()
        self.bookId = bookId
        self.chapter = chapter
        self.lastVerse = lastVerse
        self.timestamp = Date()
    }
}
