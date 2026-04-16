import SwiftUI

@MainActor
final class PrayerViewModel: ObservableObject {
    @Published var state: VerbumResult<[PrayerCategory: [Prayer]]> = .loading
    @Published var selectedCategory: PrayerCategory?

    private let repository: PrayerRepository

    init(repository: PrayerRepository? = nil) {
        self.repository = repository ?? PrayerRepository()
        loadPrayers()
    }

    func loadPrayers() {
        state = .success(repository.getPrayersByCategory())
    }

    var categories: [PrayerCategory] {
        PrayerCategory.allCases
    }

    func prayers(for category: PrayerCategory) -> [Prayer] {
        guard case .success(let map) = state else { return [] }
        return map[category] ?? []
    }

    func getPrayer(id: String) -> Prayer? {
        repository.getPrayer(id: id)
    }
}
