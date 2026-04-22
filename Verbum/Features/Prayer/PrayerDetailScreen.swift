import SwiftUI

struct PrayerDetailScreen: View {
    let prayer: Prayer
    @Environment(\.verbumColors) private var colors

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VerbumSpacing.lg) {
                // Category badge
                Text("\(prayer.category.emoji) \(prayer.category.displayName)")
                    .font(VerbumTypography.labelMedium)
                    .foregroundStyle(colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: VerbumShapes.small)
                            .fill(colors.primaryContainer.opacity(0.3))
                    )

                // Title
                Text(prayer.title)
                    .font(ScriptureTypography.bookTitle)
                    .foregroundStyle(colors.onSurface)

                // Prayer text
                Text(prayer.text)
                    .font(ScriptureTypography.verseText)
                    .lineSpacing(8)
                    .foregroundStyle(colors.onSurface)

                // Latin text if available
                if let latin = prayer.latinText {
                    Divider()
                    Text("Latin")
                        .font(VerbumTypography.labelLarge)
                        .foregroundStyle(colors.primary)
                        .tracking(2)
                    Text(latin)
                        .font(ScriptureTypography.verseText)
                        .italic()
                        .lineSpacing(8)
                        .foregroundStyle(colors.onSurfaceVariant)
                }
            }
            .padding(VerbumSpacing.screenPadding)
        }
        .navigationTitle(prayer.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
