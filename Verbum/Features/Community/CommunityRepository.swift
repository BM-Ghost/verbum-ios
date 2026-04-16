import Foundation

@MainActor
final class CommunityRepository: ObservableObject {
    private var posts: [CommunityPost] = [
        CommunityPost(
            id: "post_1",
            author: PostAuthor(id: "user_1", displayName: "Maria G.", avatarUrl: nil),
            content: "This verse has carried me through so many difficult seasons. When I feel weak, I remember that His strength is made perfect in my weakness.",
            verseReference: "Philippians 4:13",
            verseText: "I can do all things through Christ who strengthens me.",
            tags: ["strength", "faith", "perseverance"],
            amenCount: 24,
            commentCount: 5,
            createdAt: Int64(Date().addingTimeInterval(-3600).timeIntervalSince1970),
            hasUserAmened: false
        ),
        CommunityPost(
            id: "post_2",
            author: PostAuthor(id: "user_2", displayName: "John P.", avatarUrl: nil),
            content: "In the midst of anxiety about the future, this psalm reminds me that God provides. He leads me, restores me, and walks with me even through the darkest valley.",
            verseReference: "Psalm 23:1",
            verseText: "The Lord is my shepherd; I shall not want.",
            tags: ["trust", "peace", "psalms"],
            amenCount: 42,
            commentCount: 12,
            createdAt: Int64(Date().addingTimeInterval(-7200).timeIntervalSince1970),
            hasUserAmened: true
        ),
        CommunityPost(
            id: "post_3",
            author: PostAuthor(id: "user_3", displayName: "Teresa S.", avatarUrl: nil),
            content: "Even when things don't make sense, I trust that God is weaving everything together for good. His plans are so much bigger than mine.",
            verseReference: "Romans 8:28",
            verseText: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
            tags: ["hope", "trust", "Romans"],
            amenCount: 18,
            commentCount: 3,
            createdAt: Int64(Date().addingTimeInterval(-86400).timeIntervalSince1970),
            hasUserAmened: false
        ),
    ]

    func getFeed() -> [CommunityPost] { posts }

    func createPost(verseReference: String, verseText: String, reflection: String, tags: [String]) -> CommunityPost {
        let post = CommunityPost(
            id: UUID().uuidString,
            author: PostAuthor(id: "current_user", displayName: "You", avatarUrl: nil),
            content: reflection,
            verseReference: verseReference,
            verseText: verseText,
            tags: tags,
            amenCount: 0,
            commentCount: 0,
            createdAt: Int64(Date().timeIntervalSince1970),
            hasUserAmened: false
        )
        posts.insert(post, at: 0)
        return post
    }

    func toggleAmen(postId: String) {
        guard let idx = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[idx].hasUserAmened.toggle()
        posts[idx].amenCount += posts[idx].hasUserAmened ? 1 : -1
    }
}
