import Foundation

// MARK: - Network DTOs (Codable equivalents)

struct VerseOfTheDayDto: Codable {
    let bookName: String
    let chapter: Int
    let verse: Int
    let text: String
    let reference: String

    enum CodingKeys: String, CodingKey {
        case bookName = "book_name"
        case chapter, verse, text, reference
    }
}

struct MissalReadingsDto: Codable {
    let date: String
    let liturgicalSeason: String
    let feastOrMemorial: String?
    let readings: [ReadingDto]

    enum CodingKeys: String, CodingKey {
        case date
        case liturgicalSeason = "liturgical_season"
        case feastOrMemorial = "feast_or_memorial"
        case readings
    }
}

struct ReadingDto: Codable {
    let id: String
    let readingType: String
    let title: String
    let reference: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case id
        case readingType = "reading_type"
        case title, reference, text
    }
}

struct AiChatRequestDto: Codable {
    let prompt: String
    let verseContext: String?
    let liturgicalSeason: String?
    let conversationId: String?

    enum CodingKeys: String, CodingKey {
        case prompt
        case verseContext = "verse_context"
        case liturgicalSeason = "liturgical_season"
        case conversationId = "conversation_id"
    }
}

struct AiChatResponseDto: Codable {
    let response: String
    let relatedVerses: [String]?
    let suggestedPrayer: String?
    let conversationId: String

    enum CodingKeys: String, CodingKey {
        case response
        case relatedVerses = "related_verses"
        case suggestedPrayer = "suggested_prayer"
        case conversationId = "conversation_id"
    }
}

struct CommunityPostDto: Codable {
    let id: String
    let authorId: String
    let authorName: String
    let authorAvatarUrl: String?
    let content: String
    let verseReference: String?
    let verseText: String?
    let tags: [String]
    let amenCount: Int
    let commentCount: Int
    let createdAt: Int64

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case authorName = "author_name"
        case authorAvatarUrl  = "author_avatar_url"
        case content
        case verseReference = "verse_reference"
        case verseText = "verse_text"
        case tags
        case amenCount = "amen_count"
        case commentCount = "comment_count"
        case createdAt = "created_at"
    }
}

struct UserProfileDto: Codable {
    let id: String
    let displayName: String
    let avatarUrl: String?
    let bio: String?
    let followersCount: Int
    let followingCount: Int
    let isFollowing: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case bio
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case isFollowing = "is_following"
    }
}

struct BibleStudyGroupDto: Codable {
    let id: String
    let name: String
    let description: String
    let memberCount: Int
    let coverImageUrl: String?
    let currentStudyReference: String?
    let createdBy: String

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case memberCount = "member_count"
        case coverImageUrl = "cover_image_url"
        case currentStudyReference = "current_study_reference"
        case createdBy = "created_by"
    }
}
