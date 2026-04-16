import SwiftUI

// MARK: - Liturgical Theme Engine

/// Dynamically generates color schemes based on the current liturgical season.
struct VerbumColorScheme {
    let primary: Color
    let onPrimary: Color
    let primaryContainer: Color
    let onPrimaryContainer: Color
    let secondary: Color
    let onSecondary: Color
    let secondaryContainer: Color
    let onSecondaryContainer: Color
    let tertiary: Color
    let onTertiary: Color
    let background: Color
    let onBackground: Color
    let surface: Color
    let onSurface: Color
    let surfaceVariant: Color
    let onSurfaceVariant: Color
    let error: Color
    let onError: Color
    let tertiaryContainer: Color
    let onTertiaryContainer: Color
}

enum LiturgicalThemeEngine {
    static func colorScheme(for season: LiturgicalSeason, isDark: Bool) -> VerbumColorScheme {
        isDark ? darkScheme(season) : lightScheme(season)
    }

    static func lightScheme(_ season: LiturgicalSeason) -> VerbumColorScheme {
        switch season {
        case .advent:
            return VerbumColorScheme(
                primary: AdventColors.primary, onPrimary: AdventColors.onPrimary,
                primaryContainer: AdventColors.primaryContainer, onPrimaryContainer: AdventColors.onPrimaryContainer,
                secondary: AdventColors.secondary, onSecondary: AdventColors.onSecondary,
                secondaryContainer: AdventColors.secondaryContainer, onSecondaryContainer: AdventColors.onSecondaryContainer,
                tertiary: AdventColors.tertiary, onTertiary: AdventColors.onTertiary,
                background: AdventColors.background, onBackground: AdventColors.onBackground,
                surface: AdventColors.surface, onSurface: AdventColors.onSurface,
                surfaceVariant: AdventColors.surfaceVariant, onSurfaceVariant: AdventColors.onSurfaceVariant,
                error: AdventColors.error, onError: AdventColors.onError,
                tertiaryContainer: AdventColors.primaryContainer.opacity(0.5),
                onTertiaryContainer: AdventColors.onPrimaryContainer
            )
        case .christmas:
            return VerbumColorScheme(
                primary: ChristmasColors.primary, onPrimary: ChristmasColors.onPrimary,
                primaryContainer: ChristmasColors.primaryContainer, onPrimaryContainer: ChristmasColors.onPrimaryContainer,
                secondary: ChristmasColors.secondary, onSecondary: ChristmasColors.onSecondary,
                secondaryContainer: ChristmasColors.secondaryContainer, onSecondaryContainer: ChristmasColors.onSecondaryContainer,
                tertiary: ChristmasColors.tertiary, onTertiary: ChristmasColors.onTertiary,
                background: ChristmasColors.background, onBackground: ChristmasColors.onBackground,
                surface: ChristmasColors.surface, onSurface: ChristmasColors.onSurface,
                surfaceVariant: ChristmasColors.surfaceVariant, onSurfaceVariant: ChristmasColors.onSurfaceVariant,
                error: ChristmasColors.error, onError: ChristmasColors.onError,
                tertiaryContainer: ChristmasColors.primaryContainer.opacity(0.5),
                onTertiaryContainer: ChristmasColors.onPrimaryContainer
            )
        case .lent:
            return VerbumColorScheme(
                primary: LentColors.primary, onPrimary: LentColors.onPrimary,
                primaryContainer: LentColors.primaryContainer, onPrimaryContainer: LentColors.onPrimaryContainer,
                secondary: LentColors.secondary, onSecondary: LentColors.onSecondary,
                secondaryContainer: LentColors.secondaryContainer, onSecondaryContainer: LentColors.onSecondaryContainer,
                tertiary: LentColors.tertiary, onTertiary: LentColors.onTertiary,
                background: LentColors.background, onBackground: LentColors.onBackground,
                surface: LentColors.surface, onSurface: LentColors.onSurface,
                surfaceVariant: LentColors.surfaceVariant, onSurfaceVariant: LentColors.onSurfaceVariant,
                error: LentColors.error, onError: LentColors.onError,
                tertiaryContainer: LentColors.primaryContainer.opacity(0.5),
                onTertiaryContainer: LentColors.onPrimaryContainer
            )
        case .easter:
            return VerbumColorScheme(
                primary: EasterColors.primary, onPrimary: EasterColors.onPrimary,
                primaryContainer: EasterColors.primaryContainer, onPrimaryContainer: EasterColors.onPrimaryContainer,
                secondary: EasterColors.secondary, onSecondary: EasterColors.onSecondary,
                secondaryContainer: EasterColors.secondaryContainer, onSecondaryContainer: EasterColors.onSecondaryContainer,
                tertiary: EasterColors.tertiary, onTertiary: EasterColors.onTertiary,
                background: EasterColors.background, onBackground: EasterColors.onBackground,
                surface: EasterColors.surface, onSurface: EasterColors.onSurface,
                surfaceVariant: EasterColors.surfaceVariant, onSurfaceVariant: EasterColors.onSurfaceVariant,
                error: EasterColors.error, onError: EasterColors.onError,
                tertiaryContainer: EasterColors.primaryContainer.opacity(0.5),
                onTertiaryContainer: EasterColors.onPrimaryContainer
            )
        case .pentecost:
            return VerbumColorScheme(
                primary: PentecostColors.primary, onPrimary: PentecostColors.onPrimary,
                primaryContainer: PentecostColors.primaryContainer, onPrimaryContainer: PentecostColors.onPrimaryContainer,
                secondary: PentecostColors.secondary, onSecondary: PentecostColors.onSecondary,
                secondaryContainer: PentecostColors.secondaryContainer, onSecondaryContainer: PentecostColors.onSecondaryContainer,
                tertiary: PentecostColors.tertiary, onTertiary: PentecostColors.onTertiary,
                background: PentecostColors.background, onBackground: PentecostColors.onBackground,
                surface: PentecostColors.surface, onSurface: PentecostColors.onSurface,
                surfaceVariant: PentecostColors.surfaceVariant, onSurfaceVariant: PentecostColors.onSurfaceVariant,
                error: PentecostColors.error, onError: PentecostColors.onError,
                tertiaryContainer: PentecostColors.primaryContainer.opacity(0.5),
                onTertiaryContainer: PentecostColors.onPrimaryContainer
            )
        case .ordinaryTime:
            return VerbumColorScheme(
                primary: OrdinaryTimeColors.primary, onPrimary: OrdinaryTimeColors.onPrimary,
                primaryContainer: OrdinaryTimeColors.primaryContainer, onPrimaryContainer: OrdinaryTimeColors.onPrimaryContainer,
                secondary: OrdinaryTimeColors.secondary, onSecondary: OrdinaryTimeColors.onSecondary,
                secondaryContainer: OrdinaryTimeColors.secondaryContainer, onSecondaryContainer: OrdinaryTimeColors.onSecondaryContainer,
                tertiary: OrdinaryTimeColors.tertiary, onTertiary: OrdinaryTimeColors.onTertiary,
                background: OrdinaryTimeColors.background, onBackground: OrdinaryTimeColors.onBackground,
                surface: OrdinaryTimeColors.surface, onSurface: OrdinaryTimeColors.onSurface,
                surfaceVariant: OrdinaryTimeColors.surfaceVariant, onSurfaceVariant: OrdinaryTimeColors.onSurfaceVariant,
                error: OrdinaryTimeColors.error, onError: OrdinaryTimeColors.onError,
                tertiaryContainer: OrdinaryTimeColors.primaryContainer.opacity(0.5),
                onTertiaryContainer: OrdinaryTimeColors.onPrimaryContainer
            )
        }
    }

    static func darkScheme(_ season: LiturgicalSeason) -> VerbumColorScheme {
        switch season {
        case .advent:
            return VerbumColorScheme(
                primary: AdventColors.primaryDark, onPrimary: AdventColors.onPrimaryDark,
                primaryContainer: AdventColors.primary, onPrimaryContainer: AdventColors.primaryContainer,
                secondary: AdventColors.secondary, onSecondary: AdventColors.onSecondary,
                secondaryContainer: AdventColors.secondaryContainer, onSecondaryContainer: AdventColors.onSecondaryContainer,
                tertiary: AdventColors.tertiary, onTertiary: AdventColors.onTertiary,
                background: AdventColors.backgroundDark, onBackground: AdventColors.onBackgroundDark,
                surface: AdventColors.surfaceDark, onSurface: AdventColors.onSurfaceDark,
                surfaceVariant: AdventColors.surfaceDark, onSurfaceVariant: AdventColors.onSurfaceDark.opacity(0.7),
                error: AdventColors.error, onError: AdventColors.onError,
                tertiaryContainer: AdventColors.primary.opacity(0.3),
                onTertiaryContainer: AdventColors.primaryDark
            )
        case .christmas:
            return VerbumColorScheme(
                primary: ChristmasColors.primaryDark, onPrimary: ChristmasColors.onPrimaryDark,
                primaryContainer: ChristmasColors.primary, onPrimaryContainer: ChristmasColors.primaryContainer,
                secondary: ChristmasColors.secondary, onSecondary: ChristmasColors.onSecondary,
                secondaryContainer: ChristmasColors.secondaryContainer, onSecondaryContainer: ChristmasColors.onSecondaryContainer,
                tertiary: ChristmasColors.tertiary, onTertiary: ChristmasColors.onTertiary,
                background: ChristmasColors.backgroundDark, onBackground: ChristmasColors.onBackgroundDark,
                surface: ChristmasColors.surfaceDark, onSurface: ChristmasColors.onSurfaceDark,
                surfaceVariant: ChristmasColors.surfaceDark, onSurfaceVariant: ChristmasColors.onSurfaceDark.opacity(0.7),
                error: ChristmasColors.error, onError: ChristmasColors.onError,
                tertiaryContainer: ChristmasColors.primary.opacity(0.3),
                onTertiaryContainer: ChristmasColors.primaryDark
            )
        case .lent:
            return VerbumColorScheme(
                primary: LentColors.primaryDark, onPrimary: LentColors.onPrimaryDark,
                primaryContainer: LentColors.primary, onPrimaryContainer: LentColors.primaryContainer,
                secondary: LentColors.secondary, onSecondary: LentColors.onSecondary,
                secondaryContainer: LentColors.secondaryContainer, onSecondaryContainer: LentColors.onSecondaryContainer,
                tertiary: LentColors.tertiary, onTertiary: LentColors.onTertiary,
                background: LentColors.backgroundDark, onBackground: LentColors.onBackgroundDark,
                surface: LentColors.surfaceDark, onSurface: LentColors.onSurfaceDark,
                surfaceVariant: LentColors.surfaceDark, onSurfaceVariant: LentColors.onSurfaceDark.opacity(0.7),
                error: LentColors.error, onError: LentColors.onError,
                tertiaryContainer: LentColors.primary.opacity(0.3),
                onTertiaryContainer: LentColors.primaryDark
            )
        case .easter:
            return VerbumColorScheme(
                primary: EasterColors.primaryDark, onPrimary: EasterColors.onPrimaryDark,
                primaryContainer: EasterColors.primary, onPrimaryContainer: EasterColors.primaryContainer,
                secondary: EasterColors.secondary, onSecondary: EasterColors.onSecondary,
                secondaryContainer: EasterColors.secondaryContainer, onSecondaryContainer: EasterColors.onSecondaryContainer,
                tertiary: EasterColors.tertiary, onTertiary: EasterColors.onTertiary,
                background: EasterColors.backgroundDark, onBackground: EasterColors.onBackgroundDark,
                surface: EasterColors.surfaceDark, onSurface: EasterColors.onSurfaceDark,
                surfaceVariant: EasterColors.surfaceDark, onSurfaceVariant: EasterColors.onSurfaceDark.opacity(0.7),
                error: EasterColors.error, onError: EasterColors.onError,
                tertiaryContainer: EasterColors.primary.opacity(0.3),
                onTertiaryContainer: EasterColors.primaryDark
            )
        case .pentecost:
            return VerbumColorScheme(
                primary: PentecostColors.primaryDark, onPrimary: PentecostColors.onPrimaryDark,
                primaryContainer: PentecostColors.primary, onPrimaryContainer: PentecostColors.primaryContainer,
                secondary: PentecostColors.secondary, onSecondary: PentecostColors.onSecondary,
                secondaryContainer: PentecostColors.secondaryContainer, onSecondaryContainer: PentecostColors.onSecondaryContainer,
                tertiary: PentecostColors.tertiary, onTertiary: PentecostColors.onTertiary,
                background: PentecostColors.backgroundDark, onBackground: PentecostColors.onBackgroundDark,
                surface: PentecostColors.surfaceDark, onSurface: PentecostColors.onSurfaceDark,
                surfaceVariant: PentecostColors.surfaceDark, onSurfaceVariant: PentecostColors.onSurfaceDark.opacity(0.7),
                error: PentecostColors.error, onError: PentecostColors.onError,
                tertiaryContainer: PentecostColors.primary.opacity(0.3),
                onTertiaryContainer: PentecostColors.primaryDark
            )
        case .ordinaryTime:
            return VerbumColorScheme(
                primary: OrdinaryTimeColors.primaryDark, onPrimary: OrdinaryTimeColors.onPrimaryDark,
                primaryContainer: OrdinaryTimeColors.primary, onPrimaryContainer: OrdinaryTimeColors.primaryContainer,
                secondary: OrdinaryTimeColors.secondary, onSecondary: OrdinaryTimeColors.onSecondary,
                secondaryContainer: OrdinaryTimeColors.secondaryContainer, onSecondaryContainer: OrdinaryTimeColors.onSecondaryContainer,
                tertiary: OrdinaryTimeColors.tertiary, onTertiary: OrdinaryTimeColors.onTertiary,
                background: OrdinaryTimeColors.backgroundDark, onBackground: OrdinaryTimeColors.onBackgroundDark,
                surface: OrdinaryTimeColors.surfaceDark, onSurface: OrdinaryTimeColors.onSurfaceDark,
                surfaceVariant: OrdinaryTimeColors.surfaceDark, onSurfaceVariant: OrdinaryTimeColors.onSurfaceDark.opacity(0.7),
                error: OrdinaryTimeColors.error, onError: OrdinaryTimeColors.onError,
                tertiaryContainer: OrdinaryTimeColors.primary.opacity(0.3),
                onTertiaryContainer: OrdinaryTimeColors.primaryDark
            )
        }
    }
}

// MARK: - Environment Key

struct VerbumColorSchemeKey: EnvironmentKey {
    static let defaultValue = LiturgicalThemeEngine.lightScheme(.ordinaryTime)
}

struct LiturgicalSeasonKey: EnvironmentKey {
    static let defaultValue = LiturgicalSeason.ordinaryTime
}

extension EnvironmentValues {
    var verbumColors: VerbumColorScheme {
        get { self[VerbumColorSchemeKey.self] }
        set { self[VerbumColorSchemeKey.self] = newValue }
    }

    var liturgicalSeason: LiturgicalSeason {
        get { self[LiturgicalSeasonKey.self] }
        set { self[LiturgicalSeasonKey.self] = newValue }
    }
}
