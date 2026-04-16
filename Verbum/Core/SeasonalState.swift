import SwiftUI

@MainActor
final class SeasonalState: ObservableObject {
    @Published var currentSeason: LiturgicalSeason
    @Published var currentDay: LiturgicalDay

    private let calendarEngine = LiturgicalCalendarEngine()

    init() {
        let today = Date()
        let day = calendarEngine.getLiturgicalDay(date: today)
        self.currentSeason = day.season
        self.currentDay = day
        SeasonalAppIconManager.shared.applyIcon(for: day.season)
    }

    func refresh() {
        let today = Date()
        let day = calendarEngine.getLiturgicalDay(date: today)
        currentSeason = day.season
        currentDay = day
        SeasonalAppIconManager.shared.applyIcon(for: day.season)
    }

    func getDay(for date: Date) -> LiturgicalDay {
        calendarEngine.getLiturgicalDay(date: date)
    }
}
