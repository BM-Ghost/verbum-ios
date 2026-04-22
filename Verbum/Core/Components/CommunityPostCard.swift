import SwiftUI

struct CommunityPostCardView: View {
    let authorName: String
    let timeAgo: String
    let verseReference: String?
    let reflectionText: String
    let amenCount: Int
    let commentCount: Int
    let tags: [String]
    let onAmen: () -> Void
    let onComment: () -> Void
    let onProfile: () -> Void
    @Environment(\.verbumColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: VerbumSpacing.sm) {
            // Header
            HStack {
                Button(action: onProfile) {
                    HStack(spacing: VerbumSpacing.sm) {
                        // Avatar initial
                        ZStack {
                            Circle()
                                .fill(colors.primaryContainer)
                                .frame(width: 36, height: 36)
                            Text(String(authorName.prefix(1)).uppercased())
                                .font(VerbumTypography.labelLarge)
                                .foregroundColor(colors.onPrimaryContainer)
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text(authorName)
                                .font(VerbumTypography.titleSmall)
                                .foregroundColor(colors.onSurface)
                            Text(timeAgo)
                                .font(VerbumTypography.labelSmall)
                                .foregroundColor(colors.onSurfaceVariant)
                        }
                    }
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .font(VerbumTypography.labelLarge)
                    .foregroundColor(colors.onSurfaceVariant)
            }

            // Verse reference
            if let ref = verseReference {
                Text(ref)
                    .font(VerbumTypography.labelMedium)
                    .foregroundColor(colors.primary)
            }

            // Content
            Text(reflectionText)
                .font(VerbumTypography.bodyLarge)
                .italic()
                .foregroundColor(colors.onSurface)

            // Tags
            if !tags.isEmpty {
                HStack(spacing: VerbumSpacing.xs) {
                    ForEach(tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(VerbumTypography.labelSmall)
                            .foregroundColor(colors.primary)
                            .padding(.horizontal, VerbumSpacing.sm)
                            .padding(.vertical, VerbumSpacing.xxs)
                            .background(colors.primaryContainer.opacity(0.4))
                            .clipShape(Capsule())
                    }
                }
            }

            // Actions
            HStack(spacing: VerbumSpacing.lg) {
                Button(action: onAmen) {
                    HStack(spacing: VerbumSpacing.xs) {
                        Image(systemName: "hands.clap.fill")
                            .font(VerbumTypography.labelLarge)
                        Text("\(amenCount) Amen")
                            .font(VerbumTypography.labelSmall)
                    }
                    .foregroundColor(colors.primary)
                }
                Button(action: onComment) {
                    HStack(spacing: VerbumSpacing.xs) {
                        Image(systemName: "bubble.left")
                            .font(VerbumTypography.labelLarge)
                        Text("\(commentCount)")
                            .font(VerbumTypography.labelSmall)
                    }
                    .foregroundColor(colors.onSurfaceVariant)
                }
                Spacer()
            }
        }
        .padding(VerbumSpacing.md)
        .background(colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbumShapes.medium))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }
}
