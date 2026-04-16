import SwiftData
import Foundation

/// SwiftData container setup equivalent to Room database.
enum VerbumDatabase {
    static let modelContainer: ModelContainer = {
        let schema = Schema([
            BibleBookEntity.self,
            BibleVerseEntity.self,
            BookmarkEntity.self,
            MissalReadingEntity.self,
            PrayerEntity.self,
            CommunityPostCacheEntity.self,
            ReadingHistoryEntity.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
