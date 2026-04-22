import SwiftUI

enum VerbumTab: String, CaseIterable {
    case home, bible, missal, prayer, community

    var title: String {
        switch self {
        case .home: return "Home"
        case .bible: return "Bible"
        case .missal: return "Missal"
        case .prayer: return "Prayer"
        case .community: return "Community"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .bible: return "book.fill"
        case .missal: return "building.columns.fill"
        case .prayer: return "hands.clap.fill"
        case .community: return "person.3.fill"
        }
    }
}

struct VerbumNavigation: View {
    @State private var selectedTab: VerbumTab = .home
    @State private var showAiChat = false
    @State private var showCreatePost = false
    @State private var homePath = NavigationPath()
    @State private var biblePath = NavigationPath()
    @State private var prayerPath = NavigationPath()
    @StateObject private var communityViewModel = CommunityViewModel()
    @State private var aiInitialPrompt: String?

    @EnvironmentObject private var seasonalState: SeasonalState
    @Environment(\.verbumColors) private var colors

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack(path: $homePath) {
                    HomeScreen(
                        onNavigateToBible: { selectedTab = .bible },
                        onNavigateToMissal: { selectedTab = .missal },
                        onNavigateToAiChat: { showAiChat = true },
                        onNavigateToPrayer: { selectedTab = .prayer },
                        onNavigateToProfile: { homePath.append(VerbumRoute.profile) },
                        onNavigateToCommunity: { selectedTab = .community },
                        onNavigateToCalendar: { homePath.append(VerbumRoute.calendar) }
                    )
                    .navigationDestination(for: VerbumRoute.self) { route in
                        routeDestination(route, path: $homePath)
                    }
                }
                .tabItem {
                    Label(VerbumTab.home.title, systemImage: VerbumTab.home.icon)
                }
                .tag(VerbumTab.home)

                NavigationStack(path: $biblePath) {
                    BibleScreen(onSelectBook: { book in
                        biblePath.append(VerbumRoute.bibleReader(book))
                    })
                    .navigationDestination(for: VerbumRoute.self) { route in
                        routeDestination(route, path: $biblePath)
                    }
                }
                .tabItem {
                    Label(VerbumTab.bible.title, systemImage: VerbumTab.bible.icon)
                }
                .tag(VerbumTab.bible)

                NavigationStack {
                    MissalScreen()
                }
                .tabItem {
                    Label(VerbumTab.missal.title, systemImage: VerbumTab.missal.icon)
                }
                .tag(VerbumTab.missal)

                NavigationStack(path: $prayerPath) {
                    PrayerScreen(onSelectPrayer: { prayer in
                        prayerPath.append(VerbumRoute.prayerDetail(prayer))
                    })
                    .navigationDestination(for: VerbumRoute.self) { route in
                        routeDestination(route, path: $prayerPath)
                    }
                }
                .tabItem {
                    Label(VerbumTab.prayer.title, systemImage: VerbumTab.prayer.icon)
                }
                .tag(VerbumTab.prayer)

                NavigationStack {
                    CommunityFeedScreen(
                        viewModel: communityViewModel,
                        onCreatePost: { showCreatePost = true }
                    )
                }
                .tabItem {
                    Label(VerbumTab.community.title, systemImage: VerbumTab.community.icon)
                }
                .tag(VerbumTab.community)
            }
            .tint(colors.primary)

            // AI FAB
            Button { showAiChat = true } label: {
                Image(systemName: "sparkles")
                    .font(VerbumTypography.headlineSmall)
                    .foregroundStyle(colors.onPrimary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle().fill(colors.primary)
                            .shadow(color: colors.primary.opacity(0.3), radius: 8, y: 4)
                    )
            }
            .offset(y: -30)
        }
        .sheet(isPresented: $showAiChat) {
            NavigationStack {
                AiChatScreen(initialPrompt: aiInitialPrompt)
            }
        }
        .onChange(of: showAiChat) { _, newValue in
            if !newValue {
                aiInitialPrompt = nil
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostScreen { verseReference, verseText, reflection, tags in
                communityViewModel.createPost(
                    verseReference: verseReference,
                    verseText: verseText,
                    reflection: reflection,
                    tags: tags
                )
            }
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: VerbumRoute, path: Binding<NavigationPath>) -> some View {
        switch route {
        case .bibleReader(let book):
            BibleReaderScreen(book: book) { context in
                aiInitialPrompt = context
                showAiChat = true
            }
        case .prayerDetail(let prayer):
            PrayerDetailScreen(prayer: prayer)
        case .aiChat(let prompt):
            AiChatScreen(initialPrompt: prompt)
        case .profile:
            ProfileScreen(onBack: {
                if !path.wrappedValue.isEmpty { path.wrappedValue.removeLast() }
            }, onSettings: {}, onSignOut: {
                if !path.wrappedValue.isEmpty { path.wrappedValue.removeLast() }
            })
        case .calendar:
            LiturgicalCalendarScreen()
        case .auth:
            AuthScreen(onAuthenticated: {
                if !path.wrappedValue.isEmpty { path.wrappedValue.removeLast() }
            })
        }
    }
}

enum VerbumRoute: Hashable {
    case bibleReader(BibleBook)
    case prayerDetail(Prayer)
    case aiChat(String)
    case profile
    case calendar
    case auth
}
