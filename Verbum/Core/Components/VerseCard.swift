import SwiftUI

struct VerseCardView: View {
    let bookName: String
    let chapter: Int
    let verseNumber: Int
    let verseText: String
    let isBookmarked: Bool
    let onBookmark: () -> Void
    let onShare: () -> Void
    let onAskAi: () -> Void
    @Environment(\.verbumColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: VerbumSpacing.sm) {
            Text("\(bookName) \(chapter):\(verseNumber)")
                .font(VerbumTypography.labelMedium)
                .foregroundColor(colors.primary)

            (Text("\(verseNumber) ").font(ScriptureTypography.verseNumber) +
             Text(verseText).font(ScriptureTypography.verseText))
                .foregroundColor(colors.onSurface)

            HStack {
                Spacer()
                Button(action: onBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(VerbumTypography.titleMedium)
                        .foregroundColor(isBookmarked ? colors.primary : colors.onSurfaceVariant)
                }
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(VerbumTypography.titleMedium)
                        .foregroundColor(colors.onSurfaceVariant)
                }
                Button(action: onAskAi) {
                    Image(systemName: "sparkles")
                        .font(VerbumTypography.titleMedium)
                        .foregroundColor(colors.primary)
                }
            }
        }
        .padding(VerbumSpacing.md)
        .background(colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbumShapes.medium))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }
}
