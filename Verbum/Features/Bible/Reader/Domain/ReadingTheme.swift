import SwiftUI

enum ReadingMode: String, CaseIterable, Identifiable {
    case scroll = "SCROLL"
    case codex = "CODEX"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .scroll:
            return "Scroll"
        case .codex:
            return "Book"
        }
    }

    var description: String {
        switch self {
        case .scroll:
            return "Read continuously like a scroll"
        case .codex:
            return "Turn pages like a book"
        }
    }
}

enum ReadingThemeType: String, CaseIterable, Identifiable {
    case classic = "CLASSIC"
    case manuscript = "MANUSCRIPT"
    case modern = "MODERN"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic:
            return "Classic"
        case .manuscript:
            return "Manuscript"
        case .modern:
            return "Modern"
        }
    }

    var description: String {
        switch self {
        case .classic:
            return "Timeless elegance - aged parchment with refined serif type"
        case .manuscript:
            return "Illuminated manuscript - medieval monastic beauty"
        case .modern:
            return "Clean & minimal - a contemporary reading experience"
        }
    }

    func resolve(isDark: Bool) -> ReadingTheme {
        switch self {
        case .classic:
            return ReadingTheme.classic(isDark: isDark)
        case .manuscript:
            return ReadingTheme.manuscript(isDark: isDark)
        case .modern:
            return ReadingTheme.modern(isDark: isDark)
        }
    }
}

struct ReadingTheme {
    let id: String
    let pageBackground: Color
    let textColor: Color
    let verseNumberColor: Color
    let chapterTitleColor: Color
    let accentColor: Color
    let toolbarBackground: Color
    let toolbarContent: Color
    let codexGildedEdgeColor: Color
    let codexShadowTint: Color
    let scrollShadowTint: Color
    let decorativeHighlightTint: Color
    let showScrollDecor: Bool
    let showBookBinding: Bool
    let allowedModes: Set<ReadingMode>?

    static func classic(isDark: Bool) -> ReadingTheme {
        if isDark {
            return ReadingTheme(
                id: "classic",
                pageBackground: Color(hex: 0x1F1B14),
                textColor: Color(hex: 0xD2B48C),
                verseNumberColor: Color(hex: 0xCB6D5C),
                chapterTitleColor: Color(hex: 0xD4A84B),
                accentColor: Color(hex: 0xD4A84B),
                toolbarBackground: Color(hex: 0x2A2318),
                toolbarContent: Color(hex: 0xD2B48C),
                codexGildedEdgeColor: Color(hex: 0xD4A84B),
                codexShadowTint: Color(hex: 0xE8D7B0),
                scrollShadowTint: Color(hex: 0xE8D7B0),
                decorativeHighlightTint: .white,
                showScrollDecor: true,
                showBookBinding: true,
                allowedModes: nil
            )
        }

        return ReadingTheme(
            id: "classic",
            pageBackground: Color(hex: 0xFAF3E0),
            textColor: Color(hex: 0x4E3524),
            verseNumberColor: Color(hex: 0x7B241C),
            chapterTitleColor: Color(hex: 0x8B6914),
            accentColor: Color(hex: 0x8B6914),
            toolbarBackground: Color(hex: 0xF0E6D0),
            toolbarContent: Color(hex: 0x4E3524),
            codexGildedEdgeColor: Color(hex: 0xD4AF37),
            codexShadowTint: Color(hex: 0x2B1C12),
            scrollShadowTint: Color(hex: 0x2B1C12),
            decorativeHighlightTint: .white,
            showScrollDecor: true,
            showBookBinding: true,
            allowedModes: nil
        )
    }

    static func manuscript(isDark: Bool) -> ReadingTheme {
        if isDark {
            return ReadingTheme(
                id: "manuscript",
                pageBackground: Color(hex: 0x1A150E),
                textColor: Color(hex: 0xE8D8B8),
                verseNumberColor: Color(hex: 0xD4637A),
                chapterTitleColor: Color(hex: 0xDAA520),
                accentColor: Color(hex: 0xDAA520),
                toolbarBackground: Color(hex: 0x241C10),
                toolbarContent: Color(hex: 0xE8D8B8),
                codexGildedEdgeColor: Color(hex: 0xDAA520),
                codexShadowTint: Color(hex: 0xF5E7C8),
                scrollShadowTint: Color(hex: 0xF5E7C8),
                decorativeHighlightTint: .white,
                showScrollDecor: true,
                showBookBinding: true,
                allowedModes: nil
            )
        }

        return ReadingTheme(
            id: "manuscript",
            pageBackground: Color(hex: 0xEDE0C8),
            textColor: Color(hex: 0x1A1200),
            verseNumberColor: Color(hex: 0x6B1D2A),
            chapterTitleColor: Color(hex: 0xB8860B),
            accentColor: Color(hex: 0xB8860B),
            toolbarBackground: Color(hex: 0xDDD0B4),
            toolbarContent: Color(hex: 0x1A1200),
            codexGildedEdgeColor: Color(hex: 0xB8860B),
            codexShadowTint: Color(hex: 0x24190A),
            scrollShadowTint: Color(hex: 0x24190A),
            decorativeHighlightTint: .white,
            showScrollDecor: true,
            showBookBinding: true,
            allowedModes: nil
        )
    }

    static func modern(isDark: Bool) -> ReadingTheme {
        if isDark {
            return ReadingTheme(
                id: "modern",
                pageBackground: Color(hex: 0x121212),
                textColor: Color(hex: 0xE0E0E0),
                verseNumberColor: Color(hex: 0x90CAF9),
                chapterTitleColor: Color(hex: 0xBBDEFB),
                accentColor: Color(hex: 0x64B5F6),
                toolbarBackground: Color(hex: 0x1E1E1E),
                toolbarContent: Color(hex: 0xE0E0E0),
                codexGildedEdgeColor: Color(hex: 0x64B5F6),
                codexShadowTint: Color(hex: 0xE0E0E0),
                scrollShadowTint: Color(hex: 0xE0E0E0),
                decorativeHighlightTint: .white,
                showScrollDecor: false,
                showBookBinding: false,
                allowedModes: [.scroll]
            )
        }

        return ReadingTheme(
            id: "modern",
            pageBackground: .white,
            textColor: Color(hex: 0x212121),
            verseNumberColor: Color(hex: 0x1565C0),
            chapterTitleColor: Color(hex: 0x0D47A1),
            accentColor: Color(hex: 0x1976D2),
            toolbarBackground: Color(hex: 0xFAFAFA),
            toolbarContent: Color(hex: 0x212121),
            codexGildedEdgeColor: Color(hex: 0x1976D2),
            codexShadowTint: Color(hex: 0x1E1E1E),
            scrollShadowTint: Color(hex: 0x1E1E1E),
            decorativeHighlightTint: .white,
            showScrollDecor: false,
            showBookBinding: false,
            allowedModes: [.scroll]
        )
    }
}
