import Foundation

@MainActor
final class ProfileRepository: ObservableObject {
    private var profile = UserProfile(
        id: "current_user",
        displayName: "Faithful User",
        email: "user@verbum.app",
        avatarUrl: nil,
        bio: "Seeking God's word daily.",
        parish: "St. Mary Parish",
        favoriteVerse: "Philippians 4:13 - I can do all things through Christ who strengthens me.",
        postsCount: 8,
        followersCount: 21,
        followingCount: 13,
        joinedDate: Int64((Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()).timeIntervalSince1970),
        readingStreak: 12,
        bookmarksCount: 56
    )

    func getProfile() -> UserProfile { profile }

    func updateProfile(displayName: String?, bio: String?) {
        if let displayName { profile.displayName = displayName }
        if let bio { profile.bio = bio }
    }
}
