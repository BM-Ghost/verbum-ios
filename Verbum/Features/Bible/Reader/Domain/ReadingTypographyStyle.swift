import SwiftUI

enum ReadingTypographyStyle: String, CaseIterable, Identifiable {
    case scripture
    case liturgical
    case clean

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .scripture:
            return "Scripture"
        case .liturgical:
            return "Liturgical"
        case .clean:
            return "Clean"
        }
    }

    func readingFont(size: CGFloat) -> Font {
        switch self {
        case .scripture:
            return ScriptureTypography.verseText(size: size)
        case .liturgical:
            return .system(size: size, weight: .regular, design: .serif)
        case .clean:
            return .system(size: size, weight: .regular, design: .rounded)
        }
    }

    func lineSpacing(base: CGFloat) -> CGFloat {
        switch self {
        case .scripture:
            return base + 1
        case .liturgical:
            return base + 2
        case .clean:
            return base
        }
    }
}
