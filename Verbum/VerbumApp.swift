import SwiftUI
import SwiftData

@main
struct VerbumApp: App {
    @StateObject private var seasonalState = SeasonalState()
    private let bibleRepository = BibleRepository(modelContext: VerbumDatabase.modelContainer.mainContext)

    var body: some Scene {
        WindowGroup {
            RootThemedView()
                .environmentObject(seasonalState)
                .task {
                    // Seed Bible data on app startup for offline availability
                    await bibleRepository.ensureSeeded()
                }
        }
    }
}

private struct RootThemedView: View {
    @EnvironmentObject private var seasonalState: SeasonalState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let scheme = LiturgicalThemeEngine.colorScheme(for: seasonalState.currentSeason, isDark: colorScheme == .dark)
        VerbumNavigation()
            .environment(\.liturgicalSeason, seasonalState.currentSeason)
            .environment(\.verbumColors, scheme)
            .tint(scheme.primary)
    }
}
