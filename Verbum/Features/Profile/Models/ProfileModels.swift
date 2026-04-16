import Foundation

struct UserProfile: Identifiable {
    let id: String
    var displayName: String
    var email: String = ""
    var avatarUrl: String? = nil
    var bio: String = ""
    var parish: String? = nil
    var favoriteVerse: String? = nil
    var postsCount: Int = 0
    var followersCount: Int = 0
    var followingCount: Int = 0
    var joinedDate: Int64 = 0
    var readingStreak: Int = 0
    var bookmarksCount: Int = 0
}

struct ProfileStats {
    let totalReadings: Int
    let readingStreak: Int
    let bookmarks: Int
    let reflectionsPosted: Int
}
