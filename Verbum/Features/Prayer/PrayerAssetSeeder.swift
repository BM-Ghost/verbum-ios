import Foundation
import SwiftData

// MARK: - Codable structures for JSON parsing

private struct PrayerJSON: Codable {
    let id: String
    let title: String
    let category: String
    let text: String
    let latinText: String?
    let seasonRecommendation: String?
    let orderIndex: Int
}

private struct PrayersFileJSON: Codable {
    let version: Int
    let prayers: [PrayerJSON]
}

// MARK: - PrayerAssetSeeder

/// Seeds the SwiftData store with the complete Catholic prayer collection.
/// Re-seeds whenever `PRAYER_SEED_VERSION` bumps.
actor PrayerAssetSeeder {

    static let currentVersion = 2
    private static let versionKey = "PRAYER_SEED_VERSION"

    private let modelContext: ModelContext
    private var hasSeeded = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func seed() async {
        guard !hasSeeded else { return }
        let stored = UserDefaults.standard.integer(forKey: Self.versionKey)
        guard stored < Self.currentVersion else {
            hasSeeded = true
            return
        }
        await performSeed()
        hasSeeded = true
    }

    private func performSeed() async {
        guard
            let url = Bundle.main.url(forResource: "prayers", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(PrayersFileJSON.self, from: data)
        else { return }

        try? modelContext.delete(model: PrayerEntity.self)

        for prayer in file.prayers {
            let entity = PrayerEntity(
                id: prayer.id,
                title: prayer.title,
                category: prayer.category,
                text: prayer.text,
                latinText: prayer.latinText,
                seasonRecommendation: prayer.seasonRecommendation,
                orderIndex: prayer.orderIndex
            )
            modelContext.insert(entity)
        }

        try? modelContext.save()
        UserDefaults.standard.set(Self.currentVersion, forKey: Self.versionKey)
    }
}
