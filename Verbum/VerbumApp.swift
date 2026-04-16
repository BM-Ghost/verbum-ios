import SwiftUI
import SwiftData

@main
struct VerbumApp: App {
    @StateObject private var seasonalState = SeasonalState()

    var body: some Scene {
        WindowGroup {
            RootThemedView()
                .environmentObject(seasonalState)
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
