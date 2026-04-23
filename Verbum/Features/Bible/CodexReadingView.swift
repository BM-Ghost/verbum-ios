import SwiftUI

struct CodexReadingView: View {
    let verses: [Verse]
    let chapter: Int
    let totalChapters: Int
    let bookName: String
    let fontSize: CGFloat
    let typographyStyle: ReadingTypographyStyle
    let theme: ReadingTheme
    let bookmarkedVerses: Set<String>
    let onVerseTap: (Verse) -> Void
    let onChapterChange: (Int) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragTranslation: CGFloat = 0
    @State private var turnProgress: CGFloat = 0
    @State private var turnDirection: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                if theme.showBookBinding {
                    CodexSpine(accent: theme.accentColor, highlight: theme.decorativeHighlightTint)
                        .frame(width: 18)
                        .accessibilityHidden(true)
                }

                ZStack {
                    if theme.showBookBinding {
                        CodexGildedEdges(color: theme.codexGildedEdgeColor)
                            .accessibilityHidden(true)
                    }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("THE BOOK OF")
                                .font(VerbumTypography.labelMedium)
                                .foregroundStyle(theme.chapterTitleColor.opacity(0.8))
                                .tracking(1.6)

                            Text(bookName.uppercased())
                                .font(ScriptureTypography.bookTitle)
                                .foregroundStyle(theme.chapterTitleColor)

                            Text("Chapter \(chapter) of \(totalChapters)")
                                .font(VerbumTypography.labelSmall)
                                .foregroundStyle(theme.textColor.opacity(0.7))
                                .padding(.bottom, 6)

                            ForEach(verses, id: \.id) { verse in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(verse.verseNumber)")
                                        .font(VerbumTypography.labelSmall)
                                        .foregroundStyle(theme.verseNumberColor)
                                        .frame(width: 24, alignment: .trailing)

                                    Text(verse.text)
                                        .font(verseFont)
                                        .lineSpacing(verseLineSpacing)
                                        .foregroundStyle(theme.textColor)
                                }
                                .padding(.horizontal, VerbumSpacing.md)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(bookmarkedVerses.contains(verse.id) ? theme.accentColor.opacity(0.14) : .clear)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture { onVerseTap(verse) }
                            }
                        }
                        .padding(.leading, theme.showBookBinding ? 20 : 14)
                        .padding(.trailing, 14)
                        .padding(.vertical, 18)
                    }
                    .scrollIndicators(.hidden)

                    if turnProgress > 0.01 {
                        PageTurnOverlay(
                            direction: turnDirection,
                            progress: turnProgress,
                            shadowTint: theme.codexShadowTint,
                            highlight: theme.decorativeHighlightTint,
                            accent: theme.accentColor
                        )
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    }
                }
                .background(theme.pageBackground)
                .contentShape(Rectangle())
                .gesture(pageTurnGesture(containerWidth: proxy.size.width))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .background(theme.pageBackground)
        }
    }

    private var verseFont: Font {
        typographyStyle.readingFont(size: fontSize)
    }

    private var verseLineSpacing: CGFloat {
        typographyStyle.lineSpacing(base: fontSize >= 22 ? 8 : 6)
    }

    private func pageTurnGesture(containerWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                dragTranslation = value.translation.width
                turnDirection = dragTranslation == 0 ? 0 : (dragTranslation < 0 ? -1 : 1)

                let normalized = min(abs(dragTranslation) / max(containerWidth, 1), 1)
                if reduceMotion {
                    turnProgress = normalized * 0.18
                } else {
                    turnProgress = normalized * 0.78
                }
            }
            .onEnded { value in
                let threshold = containerWidth * 0.15
                let isNext = value.translation.width < -threshold && chapter < totalChapters
                let isPrevious = value.translation.width > threshold && chapter > 1

                if isNext {
                    animateTurnCompletion {
                        onChapterChange(chapter + 1)
                    }
                    return
                }

                if isPrevious {
                    animateTurnCompletion {
                        onChapterChange(chapter - 1)
                    }
                    return
                }

                withAnimation(.easeOut(duration: reduceMotion ? 0.12 : 0.2)) {
                    turnProgress = 0
                }
                dragTranslation = 0
                turnDirection = 0
            }
    }

    private func animateTurnCompletion(_ completion: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: reduceMotion ? 0.14 : 0.28)) {
            turnProgress = reduceMotion ? 0.2 : 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.14 : 0.28)) {
            completion()
            withAnimation(.easeOut(duration: reduceMotion ? 0.1 : 0.18)) {
                turnProgress = 0
            }
            dragTranslation = 0
            turnDirection = 0
        }
    }
}

private struct CodexSpine: View {
    let accent: Color
    let highlight: Color

    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .linearGradient(
                    Gradient(colors: [
                        accent.opacity(0.22),
                        accent.opacity(0.55),
                        accent.opacity(0.75),
                        accent.opacity(0.4)
                    ]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: size.width, y: 0)
                )
            )

            var y: CGFloat = 2
            while y < size.height {
                let ridge = Path(CGRect(x: 1, y: y, width: size.width - 2, height: 0.7))
                context.fill(ridge, with: .color(accent.opacity(0.22)))
                let shine = Path(CGRect(x: 1, y: y + 1, width: size.width - 2, height: 0.3))
                context.fill(shine, with: .color(highlight.opacity(0.08)))
                y += 16
            }

            let centerLine = Path(CGRect(x: size.width / 2, y: 0, width: 1.2, height: size.height))
            context.fill(centerLine, with: .color(accent.opacity(0.68)))
        }
    }
}

private struct CodexGildedEdges: View {
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    color.opacity(0.16),
                    color.opacity(0.42),
                    color.opacity(0.26)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 3)

            Spacer(minLength: 0)

            LinearGradient(
                colors: [
                    color.opacity(0.14),
                    color.opacity(0.36),
                    color.opacity(0.18)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 3)
        }
    }
}

private struct PageTurnOverlay: View {
    let direction: CGFloat
    let progress: CGFloat
    let shadowTint: Color
    let highlight: Color
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let peelWidth = max(24, width * (0.09 + progress * 0.32))
            let isRightToLeft = direction < 0
            let edgeX = isRightToLeft ? width - peelWidth : 0

            Canvas { context, size in
                let foldShadowRect = CGRect(
                    x: isRightToLeft ? edgeX - peelWidth * 0.45 : edgeX + peelWidth * 0.45,
                    y: 0,
                    width: peelWidth * 0.5,
                    height: size.height
                )
                context.fill(
                    Path(foldShadowRect),
                    with: .linearGradient(
                        Gradient(colors: [
                            shadowTint.opacity(0.2 * progress),
                            shadowTint.opacity(0.05 * progress),
                            .clear
                        ]),
                        startPoint: CGPoint(x: foldShadowRect.minX, y: 0),
                        endPoint: CGPoint(x: foldShadowRect.maxX, y: 0)
                    )
                )

                var fold = Path()
                if isRightToLeft {
                    fold.move(to: CGPoint(x: width, y: 0))
                    fold.addLine(to: CGPoint(x: edgeX, y: 0))
                    fold.addLine(to: CGPoint(x: width, y: size.height * (0.15 + progress * 0.18)))
                } else {
                    fold.move(to: CGPoint(x: 0, y: 0))
                    fold.addLine(to: CGPoint(x: peelWidth, y: 0))
                    fold.addLine(to: CGPoint(x: 0, y: size.height * (0.15 + progress * 0.18)))
                }
                fold.closeSubpath()

                context.fill(
                    fold,
                    with: .linearGradient(
                        Gradient(colors: [
                            accent.opacity(0.12 + progress * 0.14),
                            shadowTint.opacity(0.2 + progress * 0.24)
                        ]),
                        startPoint: CGPoint(x: edgeX, y: 0),
                        endPoint: CGPoint(x: isRightToLeft ? width : 0, y: size.height * 0.25)
                    )
                )

                let specular = Path(CGRect(x: edgeX + (isRightToLeft ? 1 : peelWidth - 1), y: 0, width: 1, height: size.height))
                context.fill(specular, with: .color(highlight.opacity(0.18 * progress)))
            }
        }
    }
}
