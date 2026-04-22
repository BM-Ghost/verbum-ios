import SwiftUI

struct ScrollReadingView: View {
    let verses: [Verse]
    let chapter: Int
    let bookName: String
    let fontSize: CGFloat
    let theme: ReadingTheme
    let bookmarkedVerses: Set<String>
    let targetVerse: Int?
    let onTargetVerseConsumed: () -> Void
    let onVerseTap: (Verse) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scrollOffset: CGFloat = 0
    @State private var highlightedVerse: Int? = nil

    init(
        verses: [Verse],
        chapter: Int,
        bookName: String,
        fontSize: CGFloat,
        theme: ReadingTheme,
        bookmarkedVerses: Set<String>,
        targetVerse: Int? = nil,
        onTargetVerseConsumed: @escaping () -> Void = {},
        onVerseTap: @escaping (Verse) -> Void
    ) {
        self.verses = verses
        self.chapter = chapter
        self.bookName = bookName
        self.fontSize = fontSize
        self.theme = theme
        self.bookmarkedVerses = bookmarkedVerses
        self.targetVerse = targetVerse
        self.onTargetVerseConsumed = onTargetVerseConsumed
        self.onVerseTap = onVerseTap
    }

    var body: some View {
        GeometryReader { outer in
            VStack(spacing: 0) {
                if theme.showScrollDecor {
                    ScrollRoller(
                        accent: theme.accentColor,
                        shadowTint: theme.scrollShadowTint,
                        highlightTint: theme.decorativeHighlightTint,
                        directionBias: rollerBias
                    )
                    .frame(height: 34)
                    .accessibilityHidden(true)
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        GeometryReader { scrollProxy in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: scrollProxy.frame(in: .named("reader-scroll")).minY
                                )
                        }
                        .frame(height: 0)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("\(bookName.uppercased()) \u{2022} CHAPTER \(chapter)")
                                .font(VerbumTypography.titleSmall)
                                .foregroundStyle(theme.chapterTitleColor)
                                .tracking(1.4)
                                .padding(.bottom, 2)

                            ForEach(verses, id: \.id) { verse in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(verse.verseNumber)")
                                        .font(VerbumTypography.labelSmall)
                                        .foregroundStyle(theme.verseNumberColor)
                                        .frame(width: 24, alignment: .trailing)

                                    Text(verse.text)
                                        .font(scriptureFont)
                                        .lineSpacing(fontSize >= 22 ? 8 : 6)
                                        .foregroundStyle(theme.textColor)
                                }
                                .padding(.horizontal, VerbumSpacing.md)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(verseBackground(verse))
                                )
                                .animation(
                                    .easeInOut(duration: reduceMotion ? 0 : 0.3),
                                    value: highlightedVerse
                                )
                                .contentShape(Rectangle())
                                .onTapGesture { onVerseTap(verse) }
                                .id(verse.verseNumber)
                            }
                        }
                        .padding(.horizontal, VerbumSpacing.screenPadding)
                        .padding(.vertical, VerbumSpacing.lg)
                        .background(
                            theme.showScrollDecor ?
                                ScrollParchmentFold(
                                    accent: theme.accentColor,
                                    shadowTint: theme.scrollShadowTint,
                                    highlightTint: theme.decorativeHighlightTint,
                                    directionBias: rollerBias
                                )
                                .allowsHitTesting(false)
                            : nil
                        )
                    }
                    .coordinateSpace(name: "reader-scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                        scrollOffset = offset
                    }
                    .onChange(of: targetVerse) { _, newVerse in
                        guard let v = newVerse else { return }
                        withAnimation(.easeInOut(duration: reduceMotion ? 0 : 0.4)) {
                            proxy.scrollTo(v, anchor: .center)
                        }
                        highlightedVerse = v
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                            withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.4)) {
                                highlightedVerse = nil
                            }
                            onTargetVerseConsumed()
                        }
                    }
                }

                if theme.showScrollDecor {
                    ScrollRoller(
                        accent: theme.accentColor,
                        shadowTint: theme.scrollShadowTint,
                        highlightTint: theme.decorativeHighlightTint,
                        directionBias: -rollerBias
                    )
                    .frame(height: 30)
                    .rotationEffect(.degrees(180))
                    .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.pageBackground)
            .overlay {
                if !reduceMotion {
                    ScrollAmbientDust(accent: theme.accentColor)
                        .opacity(theme.showScrollDecor ? 0.18 : 0.06)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 2)
            .frame(width: outer.size.width, height: outer.size.height)
        }
    }

    // MARK: - Helpers

    private var rollerBias: CGFloat {
        if reduceMotion { return 0 }
        return max(-1, min(1, -scrollOffset / 180))
    }

    private func verseBackground(_ verse: Verse) -> Color {
        if verse.verseNumber == highlightedVerse {
            return theme.accentColor.opacity(0.32)
        }
        if bookmarkedVerses.contains(verse.id) {
            return theme.accentColor.opacity(0.16)
        }
        return .clear
    }

    private var scriptureFont: Font {
        if theme.id == "modern" {
            return .system(size: fontSize, weight: .regular, design: .default)
        }
        return ScriptureTypography.verseText(size: fontSize)
    }
}

// MARK: - Scroll roller (3D cylinder effect)

private struct ScrollRoller: View {
    let accent: Color
    let shadowTint: Color
    let highlightTint: Color
    let directionBias: CGFloat

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let bulge = max(-6, min(6, directionBias * 6))

            var roller = Path()
            roller.move(to: CGPoint(x: 0, y: height * 0.22))
            roller.addCurve(
                to: CGPoint(x: width, y: height * 0.22),
                control1: CGPoint(x: width * 0.25, y: -bulge),
                control2: CGPoint(x: width * 0.75, y: -bulge)
            )
            roller.addCurve(
                to: CGPoint(x: 0, y: height * 0.58),
                control1: CGPoint(x: width * 0.75, y: height * 0.86 + bulge),
                control2: CGPoint(x: width * 0.25, y: height * 0.86 + bulge)
            )
            roller.closeSubpath()

            context.fill(
                roller,
                with: .linearGradient(
                    Gradient(colors: [
                        accent.opacity(0.12),
                        accent.opacity(0.32),
                        accent.opacity(0.48),
                        accent.opacity(0.26),
                        accent.opacity(0.08)
                    ]),
                    startPoint: CGPoint(x: width * 0.5, y: 0),
                    endPoint: CGPoint(x: width * 0.5, y: height)
                )
            )

            var curl = Path()
            curl.move(to: CGPoint(x: 0, y: height * 0.58))
            curl.addCurve(
                to: CGPoint(x: width, y: height * 0.58),
                control1: CGPoint(x: width * 0.3, y: height * (0.84 + directionBias * 0.08)),
                control2: CGPoint(x: width * 0.7, y: height * (0.84 + directionBias * 0.08))
            )
            curl.addLine(to: CGPoint(x: width, y: height))
            curl.addLine(to: CGPoint(x: 0, y: height))
            curl.closeSubpath()

            context.fill(
                curl,
                with: .linearGradient(
                    Gradient(colors: [
                        accent.opacity(0.18),
                        accent.opacity(0.08),
                        accent.opacity(0.0)
                    ]),
                    startPoint: CGPoint(x: width * 0.5, y: height * 0.55),
                    endPoint: CGPoint(x: width * 0.5, y: height)
                )
            )

            let line = Path(CGRect(x: 0, y: height * 0.37, width: width, height: 1))
            context.fill(line, with: .color(highlightTint.opacity(0.14)))

            let shadowRect = CGRect(x: 0, y: height * 0.55, width: width, height: height * 0.45)
            context.fill(
                Path(shadowRect),
                with: .linearGradient(
                    Gradient(colors: [
                        shadowTint.opacity(0.14),
                        shadowTint.opacity(0.03),
                        shadowTint.opacity(0)
                    ]),
                    startPoint: CGPoint(x: width * 0.5, y: height * 0.55),
                    endPoint: CGPoint(x: width * 0.5, y: height)
                )
            )
        }
    }
}

// MARK: - Parchment fold overlay

private struct ScrollParchmentFold: View {
    let accent: Color
    let shadowTint: Color
    let highlightTint: Color
    let directionBias: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let depth = 18 + abs(directionBias) * 8

                var fold = Path()
                fold.move(to: CGPoint(x: 0, y: 0))
                fold.addCurve(
                    to: CGPoint(x: width, y: 0),
                    control1: CGPoint(x: width * 0.28, y: depth),
                    control2: CGPoint(x: width * 0.72, y: depth)
                )
                fold.addLine(to: CGPoint(x: width, y: height))
                fold.addLine(to: CGPoint(x: 0, y: height))
                fold.closeSubpath()

                context.fill(
                    fold,
                    with: .linearGradient(
                        Gradient(colors: [
                            shadowTint.opacity(0.16),
                            accent.opacity(0.1),
                            .clear
                        ]),
                        startPoint: CGPoint(x: width * 0.5, y: 0),
                        endPoint: CGPoint(x: width * 0.5, y: height)
                    )
                )

                context.fill(
                    Path(CGRect(x: 0, y: 0, width: width, height: 1)),
                    with: .color(highlightTint.opacity(0.13))
                )
            }
            .frame(height: 24)

            Spacer(minLength: 0)

            Canvas { context, size in
                let width = size.width
                let height = size.height
                let depth = 18 + abs(directionBias) * 8

                var fold = Path()
                fold.move(to: CGPoint(x: 0, y: height))
                fold.addCurve(
                    to: CGPoint(x: width, y: height),
                    control1: CGPoint(x: width * 0.28, y: height - depth),
                    control2: CGPoint(x: width * 0.72, y: height - depth)
                )
                fold.addLine(to: CGPoint(x: width, y: 0))
                fold.addLine(to: CGPoint(x: 0, y: 0))
                fold.closeSubpath()

                context.fill(
                    fold,
                    with: .linearGradient(
                        Gradient(colors: [
                            .clear,
                            accent.opacity(0.08),
                            shadowTint.opacity(0.16)
                        ]),
                        startPoint: CGPoint(x: width * 0.5, y: 0),
                        endPoint: CGPoint(x: width * 0.5, y: height)
                    )
                )

                context.fill(
                    Path(CGRect(x: 0, y: height - 1, width: width, height: 1)),
                    with: .color(highlightTint.opacity(0.1))
                )
            }
            .frame(height: 24)
        }
    }
}

// MARK: - Ambient dust particles

private struct ScrollAmbientDust: View {
    let accent: Color

    var body: some View {
        Canvas { context, size in
            for i in 0..<18 {
                let x = CGFloat((i * 37) % Int(size.width.rounded(.down).clamped(to: 1...800)))
                let y = CGFloat((i * 53) % Int(size.height.rounded(.down).clamped(to: 1...1600)))
                let radius = CGFloat((i % 4) + 1)
                let circle = Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius))
                context.fill(circle, with: .color(accent.opacity(0.06)))
            }
        }
    }
}

// MARK: - Scroll offset preference key

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
