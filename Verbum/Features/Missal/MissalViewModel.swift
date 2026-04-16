import SwiftUI

@MainActor
final class MissalViewModel: ObservableObject {
    @Published var state: VerbumResult<DailyReadings> = .loading
    @Published var selectedDate: Date = Date()

    private let repository: MissalRepository

    init(repository: MissalRepository? = nil) {
        self.repository = repository ?? MissalRepository()
        loadReadings()
    }

    func loadReadings() {
        state = .loading
        let readings = repository.getDailyReadings(for: selectedDate)
        state = .success(readings)
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        loadReadings()
    }
}
