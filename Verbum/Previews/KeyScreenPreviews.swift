import SwiftUI

private struct PreviewThemeWrapper<Content: View>: View {
    @StateObject private var seasonalState = SeasonalState()
    let content: () -> Content

    var body: some View {
        content()
            .environmentObject(seasonalState)
            .environment(\.liturgicalSeason, seasonalState.currentSeason)
            .environment(\.verbumColors, LiturgicalThemeEngine.lightScheme(seasonalState.currentSeason))
    }
}

#Preview("Home") {
    PreviewThemeWrapper {
        HomeScreen(
            onNavigateToBible: {},
            onNavigateToMissal: {},
            onNavigateToAiChat: {},
            onNavigateToPrayer: {},
            onNavigateToProfile: {},
            onNavigateToCommunity: {},
            onNavigateToCalendar: {}
        )
    }
}

#Preview("Bible") {
    NavigationStack {
        PreviewThemeWrapper {
            BibleScreen(onSelectBook: { _ in })
        }
    }
}

#Preview("Missal") {
    NavigationStack {
        PreviewThemeWrapper {
            MissalScreen()
        }
    }
}

#Preview("Community") {
    PreviewThemeWrapper {
        CommunityFeedScreen(viewModel: CommunityViewModel(), onCreatePost: {})
    }
}

#Preview("AI") {
    NavigationStack {
        PreviewThemeWrapper {
            AiChatScreen()
        }
    }
}

#Preview("Profile") {
    NavigationStack {
        PreviewThemeWrapper {
            ProfileScreen(onBack: {}, onSettings: {}, onSignOut: {})
        }
    }
}

#Preview("Calendar") {
    NavigationStack {
        PreviewThemeWrapper {
            LiturgicalCalendarScreen()
        }
    }
}
