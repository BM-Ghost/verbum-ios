import Foundation

struct CommunityPost: Identifiable {
    let id: String
    let author: PostAuthor
    let content: String
    let verseReference: String?
    let verseText: String?
    let tags: [String]
    var amenCount: Int
    let commentCount: Int
    let createdAt: Int64
    var hasUserAmened: Bool = false
}

struct PostAuthor: Identifiable {
    let id: String
    let displayName: String
    let avatarUrl: String?
}

struct BibleStudyGroup: Identifiable {
    let id: String
    let name: String
    let description: String
    let memberCount: Int
    let coverImageUrl: String?
    let currentStudyReference: String?
}
