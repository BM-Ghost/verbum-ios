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

private let previewBibleBook = BibleBook(
    id: 43,
    name: "John",
    abbreviation: "Jn",
    testament: .new,
    totalChapters: 21
)

private let previewPrayer = Prayer(
    id: "our-father",
    title: "Our Father",
    category: .devotion,
    text: "Our Father, who art in heaven, hallowed be Thy name...",
    latinText: "Pater noster, qui es in caelis, sanctificetur nomen tuum..."
)

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

#Preview("Bible Reader") {
    NavigationStack {
        PreviewThemeWrapper {
            BibleReaderScreen(book: previewBibleBook, onAskAi: { _ in })
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

#Preview("Create Post") {
    NavigationStack {
        PreviewThemeWrapper {
            CreatePostScreen(onSubmit: { _, _, _, _ in })
        }
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

#Preview("Prayer") {
    NavigationStack {
        PreviewThemeWrapper {
            PrayerScreen(onSelectPrayer: { _ in })
        }
    }
}

#Preview("Prayer Detail") {
    NavigationStack {
        PreviewThemeWrapper {
            PrayerDetailScreen(prayer: previewPrayer)
        }
    }
}

#Preview("Auth") {
    NavigationStack {
        PreviewThemeWrapper {
            AuthScreen(onAuthenticated: {})
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
