import SwiftUI
import UIKit

// MARK: - Verbum Typography System

/// Mirrors the Android Verbum theme font intent:
/// display/headline use a liturgical title face,
/// body/title/label use EB Garamond,
/// scripture uses an elegant serif.

private enum VerbumFontResolver {
    static func custom(
        candidates: [String],
        size: CGFloat,
        fallback: Font
    ) -> Font {
        for name in candidates where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return fallback
    }
}

enum VerbumTypography {
    // Display — Android uses Cinzel; iOS uses bundled Trajan Pro as liturgical heading equivalent.
    static let displayLarge = VerbumFontResolver.custom(
        candidates: ["TrajanPro-Bold", "Trajan Pro Bold"],
        size: 57,
        fallback: .system(size: 57, weight: .bold, design: .serif)
    )
    static let displayMedium = VerbumFontResolver.custom(
        candidates: ["TrajanPro-Bold", "Trajan Pro Bold"],
        size: 45,
        fallback: .system(size: 45, weight: .bold, design: .serif)
    )
    static let displaySmall = VerbumFontResolver.custom(
        candidates: ["TrajanPro-Regular", "Trajan Pro"],
        size: 36,
        fallback: .system(size: 36, weight: .medium, design: .serif)
    )

    // Headline — Trajan Pro.
    static let headlineLarge = VerbumFontResolver.custom(
        candidates: ["TrajanPro-Bold", "Trajan Pro Bold"],
        size: 32,
        fallback: .system(size: 32, weight: .bold, design: .serif)
    )
    static let headlineMedium = VerbumFontResolver.custom(
        candidates: ["TrajanPro-Regular", "Trajan Pro"],
        size: 28,
        fallback: .system(size: 28, weight: .medium, design: .serif)
    )
    static let headlineSmall = VerbumFontResolver.custom(
        candidates: ["TrajanPro-Regular", "Trajan Pro"],
        size: 24,
        fallback: .system(size: 24, weight: .medium, design: .serif)
    )

    // Title — EB Garamond.
    static let titleLarge = VerbumFontResolver.custom(
        candidates: ["EBGaramond-SemiBold", "EB Garamond SemiBold", "EBGaramond-Bold"],
        size: 22,
        fallback: .system(size: 22, weight: .semibold)
    )
    static let titleMedium = VerbumFontResolver.custom(
        candidates: ["EBGaramond-SemiBold", "EB Garamond SemiBold", "EBGaramond-Medium"],
        size: 16,
        fallback: .system(size: 16, weight: .semibold)
    )
    static let titleSmall = VerbumFontResolver.custom(
        candidates: ["EBGaramond-Medium", "EB Garamond Medium", "EBGaramond-Regular"],
        size: 14,
        fallback: .system(size: 14, weight: .medium)
    )

    // Body — EB Garamond.
    static let bodyLarge = VerbumFontResolver.custom(
        candidates: ["EBGaramond-Regular", "EB Garamond Regular"],
        size: 16,
        fallback: .system(size: 16, weight: .regular)
    )
    static let bodyMedium = VerbumFontResolver.custom(
        candidates: ["EBGaramond-Regular", "EB Garamond Regular"],
        size: 14,
        fallback: .system(size: 14, weight: .regular)
    )
    static let bodySmall = VerbumFontResolver.custom(
        candidates: ["EBGaramond-Regular", "EB Garamond Regular"],
        size: 12,
        fallback: .system(size: 12, weight: .regular)
    )

    // Label — EB Garamond.
    static let labelLarge = VerbumFontResolver.custom(
        candidates: ["EBGaramond-Medium", "EB Garamond Medium", "EBGaramond-Regular"],
        size: 14,
        fallback: .system(size: 14, weight: .medium)
    )
    static let labelMedium = VerbumFontResolver.custom(
        candidates: ["EBGaramond-Medium", "EB Garamond Medium", "EBGaramond-Regular"],
        size: 12,
        fallback: .system(size: 12, weight: .medium)
    )
    static let labelSmall = VerbumFontResolver.custom(
        candidates: ["EBGaramond-Medium", "EB Garamond Medium", "EBGaramond-Regular"],
        size: 11,
        fallback: .system(size: 11, weight: .medium)
    )
}

// Scripture-specific text styles.
enum ScriptureTypography {
    static func verseText(size: CGFloat) -> Font {
        VerbumFontResolver.custom(
            candidates: ["CormorantGaramond-Regular", "Cormorant Garamond Regular", "EBGaramond-Regular"],
            size: size,
            fallback: .system(size: size, weight: .regular, design: .serif)
        )
    }

    static let verseText = verseText(size: 18)
    static let verseNumber = VerbumFontResolver.custom(
        candidates: ["EBGaramond-Bold", "EB Garamond Bold"],
        size: 12,
        fallback: .system(size: 12, weight: .bold)
    )
    static let bookTitle = VerbumFontResolver.custom(
        candidates: ["TrajanPro-Bold", "Trajan Pro Bold"],
        size: 20,
        fallback: .system(size: 20, weight: .bold, design: .serif)
    )
    static let chapterTitle = VerbumFontResolver.custom(
        candidates: ["TrajanPro-Regular", "Trajan Pro"],
        size: 16,
        fallback: .system(size: 16, weight: .medium, design: .serif)
    )
}
