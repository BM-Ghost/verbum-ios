import SwiftUI

struct MissalReadingCardView: View {
    let readingType: String
    let reference: String
    let text: String
    @Environment(\.verbumColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: VerbumSpacing.sm) {
            // Reading type with accent line
            HStack(spacing: VerbumSpacing.sm) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(colors.primary)
                    .frame(width: 3, height: 16)
                Text(readingType.uppercased())
                    .font(VerbumTypography.labelMedium)
                    .tracking(1.5)
                    .fontWeight(.semibold)
                    .foregroundColor(colors.primary)
            }

            // Reference
            Text(reference)
                .font(VerbumTypography.titleSmall)
                .fontWeight(.medium)
                .foregroundColor(colors.onSurface)

            // Scripture text
            Text(text)
                .font(ScriptureTypography.verseText)
                .lineSpacing(10)
                .foregroundColor(colors.onSurface)
        }
        .padding(VerbumSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbumShapes.large))
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
}
