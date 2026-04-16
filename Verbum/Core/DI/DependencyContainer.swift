import Foundation

/// Lightweight dependency container equivalent to Hilt wiring.
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Network
    lazy var apiClient: VerbumAPIClient = VerbumAPIClient()

    // MARK: - Repositories
    lazy var bibleRepository: BibleRepository = BibleRepository()
    lazy var missalRepository: MissalRepository = MissalRepository(apiClient: apiClient)
    lazy var prayerRepository: PrayerRepository = PrayerRepository()
    lazy var communityRepository: CommunityRepository = CommunityRepository()
    lazy var aiRepository: AiRepository = AiRepository()
    lazy var profileRepository: ProfileRepository = ProfileRepository()
    lazy var authRepository: AuthRepository = AuthRepository()

    // MARK: - Calendar
    lazy var calendarEngine: LiturgicalCalendarEngine = LiturgicalCalendarEngine()

    // MARK: - Seasonal State
    lazy var seasonalState: SeasonalState = SeasonalState()
}
