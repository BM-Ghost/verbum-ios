import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.verbumColors) private var colors
    @Environment(\.liturgicalSeason) private var season

    let onNavigateToBible: () -> Void
    let onContinueReading: (Int, Int, Int) -> Void
    let onNavigateToMissal: () -> Void
    let onNavigateToAiChat: () -> Void
    let onNavigateToPrayer: () -> Void
    let onNavigateToProfile: () -> Void
    let onNavigateToCommunity: () -> Void
    let onNavigateToCalendar: () -> Void

    @State private var showContent = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, VerbumSpacing.screenPadding)
                        .padding(.top, VerbumSpacing.sm)
                        .padding(.bottom, VerbumSpacing.xs)

                    if showContent {
                        VStack(spacing: VerbumSpacing.md) {
                            // Hero: liturgical season + verse of the day, the emotional anchor
                            heroCard
                                .padding(.horizontal, VerbumSpacing.screenPadding)

                            // Today's Mass — promoted, redesigned as the clear focal point.
                            // (Bible / Missal / Prayer / Community / AI already live in the
                            // bottom tab bar, so no duplicate in-page shortcuts are needed here.)
                            todaysMassCard
                                .padding(.horizontal, VerbumSpacing.screenPadding)

                            // Daily Prayer and Continue Reading share a row so the full
                            // picture is visible at a glance, with no scrolling required
                            HStack(alignment: .top, spacing: VerbumSpacing.sm) {
                                dailyPrayerCard
                                if viewModel.continueReading != nil, viewModel.continueReadingPosition != nil {
                                    continueReadingCard
                                }
                            }
                            .padding(.horizontal, VerbumSpacing.screenPadding)

                            // Absorbs any leftover vertical space so the layout stays
                            // balanced across screen sizes instead of leaving a dead
                            // gap on taller devices — content still scrolls normally
                            // on smaller devices where it doesn't fully fit
                            Spacer(minLength: VerbumSpacing.lg)
                        }
                        .padding(.top, VerbumSpacing.xs)
                        .padding(.bottom, VerbumSpacing.lg)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadContinueReading()
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showContent = true
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text("Verbum Dei")
                    .font(VerbumTypography.headlineSmall)
                    .foregroundStyle(colors.onSurface)
                Text("The Word of God")
                    .font(VerbumTypography.bodySmall)
                    .foregroundStyle(colors.onSurfaceVariant)
            }
            Spacer()
            HStack(spacing: 8) {
                topBarIconButton(icon: "calendar", action: onNavigateToCalendar)
                topBarIconButton(icon: "person.circle.fill", action: onNavigateToProfile)
            }
        }
    }

    private func topBarIconButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(colors.primary)
                .frame(width: 38, height: 38)
                .background(
                    Circle().fill(colors.surfaceVariant.opacity(0.55))
                )
                .overlay(
                    Circle().stroke(colors.primary.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: - Hero Card (Season + Verse of the Day combined)
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Season badge row
            HStack(spacing: VerbumSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(colors.primary.opacity(0.14))
                        .frame(width: 40, height: 40)
                    Text(viewModel.seasonEmoji(season))
                        .font(.system(size: 19))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(season.displayName.uppercased())
                        .font(VerbumTypography.labelLarge)
                        .tracking(2.5)
                        .foregroundStyle(colors.onPrimaryContainer)
                    Text(viewModel.seasonGreeting(season))
                        .font(VerbumTypography.bodySmall)
                        .foregroundStyle(colors.onPrimaryContainer.opacity(0.7))
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.bottom, VerbumSpacing.sm + 2)

            Divider()
                .overlay(colors.onPrimaryContainer.opacity(0.12))
                .padding(.bottom, VerbumSpacing.sm + 2)

            // Verse of the day, with an editorial pull-quote treatment
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(colors.primary)
                        .frame(width: 14, height: 2)
                        .clipShape(Capsule())
                    Text("VERSE OF THE DAY")
                        .font(VerbumTypography.labelMedium)
                        .tracking(1.5)
                        .foregroundStyle(colors.primary)
                }

                Text("\u{201C}\(viewModel.verseOfDay.text)\u{201D}")
                    .font(ScriptureTypography.verseText)
                    .italic()
                    .lineSpacing(4)
                    .foregroundStyle(colors.onSurface)
                    .fixedSize(horizontal: false, vertical: true)

                Text(viewModel.verseOfDay.reference)
                    .font(VerbumTypography.labelMedium)
                    .foregroundStyle(colors.primary)
            }
        }
        .padding(VerbumSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    RadialGradient(
                        colors: [colors.primary.opacity(0.16), colors.primaryContainer, colors.surface],
                        center: UnitPoint(x: 0.12, y: 0.05),
                        startRadius: 0,
                        endRadius: 440
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(colors.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.07), radius: 10, y: 5)
    }

    // MARK: - Today's Mass (promoted, redesigned as the primary feature card)
    private var todaysMassCard: some View {
        Button(action: onNavigateToMissal) {
            VStack(alignment: .leading, spacing: VerbumSpacing.sm) {
                HStack(spacing: VerbumSpacing.xs) {
                    ZStack {
                        Circle()
                            .fill(colors.surface.opacity(0.5))
                            .frame(width: 26, height: 26)
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(colors.onPrimaryContainer)
                    }
                    Text("TODAY'S MASS")
                        .font(VerbumTypography.labelMedium)
                        .tracking(1.5)
                        .foregroundStyle(colors.onPrimaryContainer.opacity(0.85))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(colors.onPrimaryContainer.opacity(0.55))
                }

                Text(viewModel.todaysMass.title)
                    .font(VerbumTypography.titleSmall)
                    .foregroundStyle(colors.onPrimaryContainer)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 4) {
                    massReadingRow(icon: "book.closed.fill", text: viewModel.todaysMass.firstReading)
                    massReadingRow(icon: "text.book.closed.fill", text: viewModel.todaysMass.gospel)
                }
            }
            .padding(VerbumSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [colors.primaryContainer, colors.primaryContainer.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(colors.primary.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: colors.primary.opacity(0.14), radius: 10, y: 5)
        }
        .buttonStyle(PressableStyle())
    }

    private func massReadingRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(colors.onPrimaryContainer.opacity(0.55))
                .padding(.top, 1)
            Text(text)
                .font(VerbumTypography.bodySmall)
                .foregroundStyle(colors.onPrimaryContainer.opacity(0.75))
                .lineLimit(1)
        }
    }

    // MARK: - Daily Prayer (compact, shares row with Continue Reading)
    private var dailyPrayerCard: some View {
        Button(action: onNavigateToPrayer) {
            VStack(alignment: .leading, spacing: VerbumSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(colors.primary.opacity(0.12))
                        .frame(width: 30, height: 30)
                    Image(systemName: "hands.clap.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(colors.primary)
                }
                Text("PRAYER")
                    .font(VerbumTypography.labelMedium)
                    .tracking(1.2)
                    .foregroundStyle(colors.primary)
                Text(viewModel.seasonPrayer(season))
                    .font(ScriptureTypography.verseText)
                    .lineSpacing(2)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .padding(VerbumSpacing.sm + 2)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(colors.surface)
                    .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(colors.onSurfaceVariant.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: - Continue Reading (compact, shares row with Daily Prayer)
    private var continueReadingCard: some View {
        Button {
            guard let position = viewModel.continueReadingPosition else { return }
            onContinueReading(position.bookId, position.chapter, position.verse)
        } label: {
            VStack(alignment: .leading, spacing: VerbumSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(colors.primary.opacity(0.12))
                        .frame(width: 30, height: 30)
                    Image(systemName: "book.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(colors.primary)
                }
                Text("CONTINUE READING")
                    .font(VerbumTypography.labelMedium)
                    .tracking(1.2)
                    .foregroundStyle(colors.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(viewModel.continueReading?.verse ?? "")
                    .font(ScriptureTypography.verseText)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(3)
                Spacer(minLength: 0)
                HStack {
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(colors.primary.opacity(0.75))
                }
            }
            .padding(VerbumSpacing.sm + 2)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(colors.surfaceVariant.opacity(0.45))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(colors.onSurfaceVariant.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(PressableStyle())
    }

}

// MARK: - Tactile press feedback for engaging, native-feeling taps
private struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
