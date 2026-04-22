import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.verbumColors) private var colors
    @Environment(\.liturgicalSeason) private var season

    let onNavigateToBible: () -> Void
    let onNavigateToMissal: () -> Void
    let onNavigateToAiChat: () -> Void
    let onNavigateToPrayer: () -> Void
    let onNavigateToProfile: () -> Void
    let onNavigateToCommunity: () -> Void
    let onNavigateToCalendar: () -> Void

    @State private var showContent = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Verbum Dei")
                            .font(VerbumTypography.headlineSmall)
                        Text("The Word of God")
                            .font(VerbumTypography.bodySmall)
                            .foregroundStyle(colors.onSurfaceVariant)
                    }
                    Spacer()
                    Button(action: onNavigateToCalendar) {
                        Image(systemName: "calendar")
                            .foregroundStyle(colors.primary)
                    }
                    Button(action: onNavigateToProfile) {
                        Image(systemName: "person.circle")
                    }
                }
                .padding(.horizontal, VerbumSpacing.screenPadding)
                .padding(.vertical, VerbumSpacing.md)

                if showContent {
                    VStack(spacing: 0) {
                        // Season Hero Banner
                        seasonHeroBanner
                        Spacer().frame(height: VerbumSpacing.lg)

                        // Verse of the Day
                        verseOfDayCard
                        Spacer().frame(height: VerbumSpacing.lg)

                        // Quick Actions
                        sectionHeader("Explore")
                        Spacer().frame(height: VerbumSpacing.sm)
                        quickActionsRow
                        Spacer().frame(height: VerbumSpacing.xl)

                        // Today's Mass
                        sectionHeader("Today's Mass")
                        Spacer().frame(height: VerbumSpacing.sm)
                        todaysMassCard
                        Spacer().frame(height: VerbumSpacing.xl)

                        // Daily Prayer
                        sectionHeader("Daily Prayer")
                        Spacer().frame(height: VerbumSpacing.sm)
                        dailyPrayerCard
                        Spacer().frame(height: VerbumSpacing.xl)

                        // Continue Reading
                        sectionHeader("Continue Reading")
                        Spacer().frame(height: VerbumSpacing.sm)
                        continueReadingCard
                        Spacer().frame(height: VerbumSpacing.xxl + VerbumSpacing.lg)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showContent = true
            }
        }
    }

    // MARK: - Season Hero Banner
    private var seasonHeroBanner: some View {
        VStack(spacing: VerbumSpacing.sm) {
            Text(viewModel.seasonEmoji(season))
                .font(VerbumTypography.displaySmall)
            Text(season.displayName.uppercased())
                .font(VerbumTypography.labelLarge)
                .tracking(4)
                .foregroundStyle(colors.onPrimaryContainer)
            Text(viewModel.seasonGreeting(season))
                .font(ScriptureTypography.verseText)
                .italic()
                .foregroundStyle(colors.onPrimaryContainer.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(VerbumSpacing.lg + VerbumSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [colors.primary.opacity(0.15), colors.primaryContainer, colors.primaryContainer.opacity(0.6)],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 400
                    )
                )
        )
        .padding(.horizontal, VerbumSpacing.screenPadding)
    }

    // MARK: - Verse of the Day
    private var verseOfDayCard: some View {
        VStack(alignment: .leading, spacing: VerbumSpacing.md) {
            HStack(spacing: VerbumSpacing.sm) {
                Circle()
                    .fill(colors.primary)
                    .frame(width: 6, height: 6)
                Text("VERSE OF THE DAY")
                    .font(VerbumTypography.labelLarge)
                    .tracking(2)
                    .foregroundStyle(colors.primary)
            }
            Text(viewModel.verseOfDay.text)
                .font(ScriptureTypography.verseText)
                .italic()
                .lineSpacing(6)
                .foregroundStyle(colors.onSurface)
            Text("— \(viewModel.verseOfDay.reference)")
                .font(VerbumTypography.labelMedium)
                .foregroundStyle(colors.primary)
        }
        .padding(VerbumSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colors.surface)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        )
        .padding(.horizontal, VerbumSpacing.screenPadding)
    }

    // MARK: - Quick Actions
    private var quickActionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                quickActionChip(icon: "book.fill", label: "Bible", action: onNavigateToBible)
                quickActionChip(icon: "building.columns.fill", label: "Missal", action: onNavigateToMissal)
                quickActionChip(icon: "hands.clap.fill", label: "Prayer", action: onNavigateToPrayer)
                quickActionChip(icon: "person.3.fill", label: "Community", action: onNavigateToCommunity)
                quickActionChip(icon: "sparkles", label: "Verbum AI", action: onNavigateToAiChat)
            }
            .padding(.horizontal, VerbumSpacing.screenPadding)
        }
    }

    private func quickActionChip(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(VerbumTypography.labelLarge)
                    .foregroundStyle(colors.primary)
                Text(label)
                    .font(VerbumTypography.bodyMedium)
                    .foregroundStyle(colors.onSurface)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.surfaceVariant.opacity(0.7))
            )
        }
    }

    // MARK: - Today's Mass
    private var todaysMassCard: some View {
        Button(action: onNavigateToMissal) {
            HStack {
                VStack(alignment: .leading, spacing: VerbumSpacing.xs) {
                    Text(viewModel.todaysMass.title)
                        .font(VerbumTypography.titleSmall)
                        .foregroundStyle(colors.onPrimaryContainer)
                    Text(viewModel.todaysMass.firstReading)
                        .font(VerbumTypography.bodySmall)
                        .foregroundStyle(colors.onPrimaryContainer.opacity(0.7))
                    Text(viewModel.todaysMass.gospel)
                        .font(VerbumTypography.bodySmall)
                        .foregroundStyle(colors.onPrimaryContainer.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(colors.onPrimaryContainer.opacity(0.5))
            }
            .padding(VerbumSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.primaryContainer.opacity(0.5))
            )
        }
        .padding(.horizontal, VerbumSpacing.screenPadding)
    }

    // MARK: - Daily Prayer
    private var dailyPrayerCard: some View {
        Button(action: onNavigateToPrayer) {
            VStack(alignment: .leading, spacing: VerbumSpacing.sm) {
                HStack(spacing: VerbumSpacing.sm) {
                    Image(systemName: "hands.clap.fill")
                        .font(VerbumTypography.labelLarge)
                        .foregroundStyle(colors.primary)
                    Text("Suggested Prayer")
                        .font(VerbumTypography.labelLarge)
                        .foregroundStyle(colors.primary)
                }
                Text(viewModel.seasonPrayer(season))
                    .font(ScriptureTypography.verseText)
                    .lineSpacing(4)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(VerbumSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.surface)
                    .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
            )
        }
        .padding(.horizontal, VerbumSpacing.screenPadding)
    }

    // MARK: - Continue Reading
    private var continueReadingCard: some View {
        Button(action: onNavigateToBible) {
            HStack(spacing: VerbumSpacing.md) {
                Image(systemName: "book.fill")
                    .font(VerbumTypography.titleLarge)
                    .foregroundStyle(colors.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.continueReading.book)
                        .font(VerbumTypography.titleSmall)
                        .foregroundStyle(colors.onSurface)
                    Text(viewModel.continueReading.verse)
                        .font(VerbumTypography.bodySmall)
                        .foregroundStyle(colors.onSurfaceVariant)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(colors.onSurfaceVariant.opacity(0.5))
            }
            .padding(VerbumSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.surfaceVariant.opacity(0.5))
            )
        }
        .padding(.horizontal, VerbumSpacing.screenPadding)
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(VerbumTypography.headlineSmall)
            .foregroundStyle(colors.onSurface)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, VerbumSpacing.screenPadding)
    }
}
