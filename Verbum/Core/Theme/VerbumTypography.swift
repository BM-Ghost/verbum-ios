import SwiftUI

// MARK: - Verbum Typography System

/// Cinzel-style serif for display/headlines
/// Inter-style sans-serif for UI/body
/// Crimson Text-style serif for scripture text
///
/// Using system fonts with similar characteristics since custom fonts
/// require bundling. The project uses Georgia (serif) for display,
/// system default for body, and Georgia (serif) for scripture.

enum VerbumTypography {
    // Display — Cinzel-equivalent (serif, bold)
    static let displayLarge = Font.system(size: 57, weight: .bold, design: .serif)
    static let displayMedium = Font.system(size: 45, weight: .bold, design: .serif)
    static let displaySmall = Font.system(size: 36, weight: .medium, design: .serif)

    // Headline — Cinzel-equivalent
    static let headlineLarge = Font.system(size: 32, weight: .bold, design: .serif)
    static let headlineMedium = Font.system(size: 28, weight: .medium, design: .serif)
    static let headlineSmall = Font.system(size: 24, weight: .medium, design: .serif)

    // Title — Inter-equivalent
    static let titleLarge = Font.system(size: 22, weight: .semibold)
    static let titleMedium = Font.system(size: 16, weight: .semibold)
    static let titleSmall = Font.system(size: 14, weight: .medium)

    // Body — Inter-equivalent
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let bodySmall = Font.system(size: 12, weight: .regular)

    // Label — Inter-equivalent
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let labelSmall = Font.system(size: 11, weight: .medium)
}

// Scripture-specific text styles — Crimson Text-equivalent
enum ScriptureTypography {
    static let verseText = Font.system(size: 18, weight: .regular, design: .serif)
    static let verseNumber = Font.system(size: 12, weight: .bold)
    static let bookTitle = Font.system(size: 20, weight: .bold, design: .serif)
    static let chapterTitle = Font.system(size: 16, weight: .medium, design: .serif)
}
