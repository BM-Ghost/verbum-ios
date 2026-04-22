import Foundation
import SwiftData

/// Lightweight dependency container equivalent to Hilt wiring.
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Database
    let modelContainer: ModelContainer = VerbumDatabase.modelContainer

    // MARK: - Network
    lazy var apiClient: VerbumAPIClient = VerbumAPIClient()

    // MARK: - Repositories
    lazy var bibleRepository: BibleRepository = BibleRepository(modelContext: modelContainer.mainContext)
    lazy var missalRepository: MissalRepository = MissalRepository(apiClient: apiClient)
    lazy var prayerRepository: PrayerRepository = PrayerRepository(modelContext: modelContainer.mainContext)
    lazy var communityRepository: CommunityRepository = CommunityRepository()
    lazy var aiRepository: AiRepository = AiRepository()
    lazy var profileRepository: ProfileRepository = ProfileRepository()
    lazy var authRepository: AuthRepository = AuthRepository()

    // MARK: - Calendar
    lazy var calendarEngine: LiturgicalCalendarEngine = LiturgicalCalendarEngine()

    // MARK: - Seasonal State
    lazy var seasonalState: SeasonalState = SeasonalState()
}
