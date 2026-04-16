import SwiftUI

struct PrayerDetailScreen: View {
    let prayer: Prayer
    @Environment(\.verbumColors) private var colors

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VerbumSpacing.lg) {
                // Category badge
                Text("\(prayer.category.emoji) \(prayer.category.displayName)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: VerbumShapes.small)
                            .fill(colors.primaryContainer.opacity(0.3))
                    )

                // Title
                Text(prayer.title)
                    .font(.system(.title2, design: .serif))
                    .fontWeight(.bold)
                    .foregroundStyle(colors.onSurface)

                // Prayer text
                Text(prayer.text)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(8)
                    .foregroundStyle(colors.onSurface)

                // Latin text if available
                if let latin = prayer.latinText {
                    Divider()
                    Text("Latin")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(colors.primary)
                        .tracking(2)
                    Text(latin)
                        .font(.system(.body, design: .serif))
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
