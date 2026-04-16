import Foundation

enum VerbumConstants {
    static let bibleDatabaseName = "verbum_bible"
    static let appDatabaseName = "verbum_app"
    static let preferencesKey = "verbum_preferences"

    static let bibleBooksOT = 46  // Catholic Old Testament
    static let bibleBooksNT = 27
    static let bibleBooksTotal = 73

    static let aiMaxTokens = 2048
    static let aiTemperature: Float = 0.7
    static let aiSystemPromptKey = "verbum_ai_system"

    static let pageSize = 20
    static let communityFeedPageSize = 30

    enum DeepLink {
        static let scheme = "verbum"
        static let host = "app"
        static let versePath = "verse"
        static let missalPath = "missal"
        static let communityPath = "community"
    }
}
