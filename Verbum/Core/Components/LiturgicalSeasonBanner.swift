import SwiftUI

struct LiturgicalSeasonBannerView: View {
    let season: LiturgicalSeason
    let dateLabel: String
    let seasonSubtitle: String
    @Environment(\.verbumColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: VerbumSpacing.xs) {
            HStack(spacing: VerbumSpacing.sm) {
                Image(systemName: "calendar")
                    .font(VerbumTypography.labelLarge)
                    .foregroundColor(colors.onPrimaryContainer)
                Text(dateLabel)
                    .font(VerbumTypography.labelMedium)
                    .foregroundColor(colors.onPrimaryContainer)
            }

            Text(season.displayName)
                .font(VerbumTypography.headlineSmall)
                .foregroundColor(colors.onPrimaryContainer)

            Text(seasonSubtitle)
                .font(VerbumTypography.bodyMedium)
                .italic()
                .foregroundColor(colors.onPrimaryContainer.opacity(0.8))
        }
        .padding(VerbumSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colors.primaryContainer)
        .clipShape(RoundedRectangle(cornerRadius: VerbumShapes.large))
    }
}
