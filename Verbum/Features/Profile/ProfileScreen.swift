import SwiftUI

struct ProfileScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.verbumColors) private var colors

    let onBack: () -> Void
    let onSettings: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        switch viewModel.state {
        case .loading:
            VerbumLoadingView()
        case .error(let message):
            VerbumErrorView(message: message) { viewModel.loadProfile() }
        case .success(let profile):
            ScrollView {
                VStack(spacing: VerbumSpacing.xl) {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(VerbumTypography.titleMedium)
                        }
                        Spacer()
                        Text("Profile")
                            .font(VerbumTypography.headlineSmall)
                        Spacer()
                        Button(action: onSettings) {
                            Image(systemName: "gearshape")
                                .font(VerbumTypography.titleMedium)
                        }
                    }
                    .padding(.horizontal, VerbumSpacing.screenPadding)

                    // Avatar
                    VStack(spacing: VerbumSpacing.md) {
                        Circle()
                            .fill(colors.primaryContainer)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(profile.displayName.prefix(1)).uppercased())
                                    .font(ScriptureTypography.bookTitle)
                                    .foregroundStyle(colors.onPrimaryContainer)
                            )

                        Text(profile.displayName)
                            .font(VerbumTypography.titleLarge)
                            .foregroundStyle(colors.onSurface)

                        Text(profile.bio)
                            .font(VerbumTypography.bodyMedium)
                            .foregroundStyle(colors.onSurfaceVariant)

                        if let parish = profile.parish {
                            Text(parish)
                                .font(VerbumTypography.labelMedium)
                                .foregroundStyle(colors.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(colors.primaryContainer.opacity(0.4)))
                        }
                    }

                    // Social stats row
                    HStack(spacing: VerbumSpacing.md) {
                        statItem(value: "\(profile.postsCount)", label: "Posts")
                        statItem(value: "\(profile.followersCount)", label: "Followers")
                        statItem(value: "\(profile.followingCount)", label: "Following")
                    }
                    .padding(VerbumSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: VerbumShapes.large)
                            .fill(colors.surfaceVariant.opacity(0.5))
                    )
                    .padding(.horizontal, VerbumSpacing.screenPadding)

                    // Faith journey cards
                    VStack(spacing: VerbumSpacing.sm) {
                        journeyCard(title: "Streak", value: "\(profile.readingStreak) days", icon: "flame.fill")
                        journeyCard(title: "Readings", value: "\(profile.postsCount + 120)", icon: "book.fill")
                        journeyCard(title: "Bookmarks", value: "\(profile.bookmarksCount)", icon: "bookmark.fill")
                    }
                    .padding(.horizontal, VerbumSpacing.screenPadding)

                    if let favorite = profile.favoriteVerse {
                        VStack(alignment: .leading, spacing: VerbumSpacing.xs) {
                            Text("Favorite Verse")
                                .font(VerbumTypography.labelLarge)
                                .foregroundStyle(colors.primary)
                            Text(favorite)
                                .font(ScriptureTypography.verseText)
                                .italic()
                                .foregroundStyle(colors.onSurface)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(VerbumSpacing.md)
                        .background(RoundedRectangle(cornerRadius: VerbumShapes.medium).fill(colors.surfaceVariant.opacity(0.45)))
                        .padding(.horizontal, VerbumSpacing.screenPadding)
                    }

                    VerbumOutlinedButtonView(text: "Edit Profile", action: {})
                        .padding(.horizontal, VerbumSpacing.screenPadding)

                    // Joined date
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(colors.onSurfaceVariant)
                        Text("Joined \(Date(timeIntervalSince1970: TimeInterval(profile.joinedDate)).formatted(.dateTime.month(.wide).year()))")
                            .font(VerbumTypography.bodyMedium)
                            .foregroundStyle(colors.onSurfaceVariant)
                    }

                    // Sign out
                    Button(action: onSignOut) {
                        Text("Sign Out")
                            .font(VerbumTypography.bodyLarge)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, VerbumSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: VerbumShapes.medium)
                                    .stroke(.red.opacity(0.3))
                            )
                    }
                    .padding(.horizontal, VerbumSpacing.screenPadding)
                }
                .padding(.vertical, VerbumSpacing.xl)
            }
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(VerbumTypography.titleMedium)
                .foregroundStyle(colors.primary)
            Text(label)
                .font(VerbumTypography.labelSmall)
                .foregroundStyle(colors.onSurfaceVariant)
        }
    }

    private func journeyCard(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(colors.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(VerbumTypography.bodySmall)
                    .foregroundStyle(colors.onSurfaceVariant)
                Text(value)
                    .font(VerbumTypography.bodyMedium)
                    .foregroundStyle(colors.onSurface)
            }
            Spacer()
        }
        .padding(VerbumSpacing.md)
        .background(RoundedRectangle(cornerRadius: VerbumShapes.medium).fill(colors.surfaceVariant.opacity(0.45)))
    }
}
