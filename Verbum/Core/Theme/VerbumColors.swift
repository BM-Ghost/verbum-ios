import SwiftUI

// MARK: - Verbum Design System — Color Palette

// ── Advent: Purple + soft glow (waiting/hope) ──
enum AdventColors {
    static let primary = Color(hex: 0xFF6A1B9A)
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: 0xFFE1BEE7)
    static let onPrimaryContainer = Color(hex: 0xFF38006B)
    static let secondary = Color(hex: 0xFF9C27B0)
    static let onSecondary = Color.white
    static let secondaryContainer = Color(hex: 0xFFF3E5F5)
    static let onSecondaryContainer = Color(hex: 0xFF4A0072)
    static let tertiary = Color(hex: 0xFFCE93D8)
    static let onTertiary = Color(hex: 0xFF1A0033)
    static let background = Color(hex: 0xFFFDF4FF)
    static let onBackground = Color(hex: 0xFF1C1B1F)
    static let surface = Color(hex: 0xFFFDF4FF)
    static let onSurface = Color(hex: 0xFF1C1B1F)
    static let surfaceVariant = Color(hex: 0xFFF3E5F5)
    static let onSurfaceVariant = Color(hex: 0xFF49454F)
    static let error = Color(hex: 0xFFBA1A1A)
    static let onError = Color.white

    static let primaryDark = Color(hex: 0xFFCE93D8)
    static let onPrimaryDark = Color(hex: 0xFF38006B)
    static let backgroundDark = Color(hex: 0xFF1A0E2E)
    static let onBackgroundDark = Color(hex: 0xFFE6E1E5)
    static let surfaceDark = Color(hex: 0xFF1A0E2E)
    static let onSurfaceDark = Color(hex: 0xFFE6E1E5)
}

// ── Christmas: Gold + white (celebration/divinity) ──
enum ChristmasColors {
    static let primary = Color(hex: 0xFFBF8C00)
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: 0xFFFFF3C4)
    static let onPrimaryContainer = Color(hex: 0xFF3E2800)
    static let secondary = Color(hex: 0xFFD4A017)
    static let onSecondary = Color.white
    static let secondaryContainer = Color(hex: 0xFFFFF8E1)
    static let onSecondaryContainer = Color(hex: 0xFF4E3600)
    static let tertiary = Color(hex: 0xFFFFD54F)
    static let onTertiary = Color(hex: 0xFF3E2800)
    static let background = Color(hex: 0xFFFFFDF5)
    static let onBackground = Color(hex: 0xFF1C1B1F)
    static let surface = Color(hex: 0xFFFFFDF5)
    static let onSurface = Color(hex: 0xFF1C1B1F)
    static let surfaceVariant = Color(hex: 0xFFFFF8E1)
    static let onSurfaceVariant = Color(hex: 0xFF49454F)
    static let error = Color(hex: 0xFFBA1A1A)
    static let onError = Color.white

    static let primaryDark = Color(hex: 0xFFFFD54F)
    static let onPrimaryDark = Color(hex: 0xFF3E2800)
    static let backgroundDark = Color(hex: 0xFF1F1A0E)
    static let onBackgroundDark = Color(hex: 0xFFF5F0E0)
    static let surfaceDark = Color(hex: 0xFF1F1A0E)
    static let onSurfaceDark = Color(hex: 0xFFF5F0E0)
}

// ── Lent: Deep violet + muted tones (reflection/penance) ──
enum LentColors {
    static let primary = Color(hex: 0xFF4A148C)
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: 0xFFD1C4E9)
    static let onPrimaryContainer = Color(hex: 0xFF21005D)
    static let secondary = Color(hex: 0xFF5C4B8A)
    static let onSecondary = Color.white
    static let secondaryContainer = Color(hex: 0xFFE8DEF8)
    static let onSecondaryContainer = Color(hex: 0xFF1D192B)
    static let tertiary = Color(hex: 0xFF7E57C2)
    static let onTertiary = Color.white
    static let background = Color(hex: 0xFFF8F5FC)
    static let onBackground = Color(hex: 0xFF1C1B1F)
    static let surface = Color(hex: 0xFFF8F5FC)
    static let onSurface = Color(hex: 0xFF1C1B1F)
    static let surfaceVariant = Color(hex: 0xFFE8DEF8)
    static let onSurfaceVariant = Color(hex: 0xFF49454F)
    static let error = Color(hex: 0xFFBA1A1A)
    static let onError = Color.white

    static let primaryDark = Color(hex: 0xFFB39DDB)
    static let onPrimaryDark = Color(hex: 0xFF21005D)
    static let backgroundDark = Color(hex: 0xFF150D25)
    static let onBackgroundDark = Color(hex: 0xFFE6E1E5)
    static let surfaceDark = Color(hex: 0xFF150D25)
    static let onSurfaceDark = Color(hex: 0xFFE6E1E5)
}

// ── Easter: White + gold + bright tones (joy/resurrection) ──
enum EasterColors {
    static let primary = Color(hex: 0xFFE6B800)
    static let onPrimary = Color(hex: 0xFF3E2800)
    static let primaryContainer = Color(hex: 0xFFFFF9C4)
    static let onPrimaryContainer = Color(hex: 0xFF3E2800)
    static let secondary = Color.white
    static let onSecondary = Color(hex: 0xFF1C1B1F)
    static let secondaryContainer = Color(hex: 0xFFFFF8E1)
    static let onSecondaryContainer = Color(hex: 0xFF1C1B1F)
    static let tertiary = Color(hex: 0xFFFFEB3B)
    static let onTertiary = Color(hex: 0xFF3E2800)
    static let background = Color(hex: 0xFFFFFFF7)
    static let onBackground = Color(hex: 0xFF1C1B1F)
    static let surface = Color(hex: 0xFFFFFFF7)
    static let onSurface = Color(hex: 0xFF1C1B1F)
    static let surfaceVariant = Color(hex: 0xFFFFF8E1)
    static let onSurfaceVariant = Color(hex: 0xFF49454F)
    static let error = Color(hex: 0xFFBA1A1A)
    static let onError = Color.white

    static let primaryDark = Color(hex: 0xFFFFD54F)
    static let onPrimaryDark = Color(hex: 0xFF3E2800)
    static let backgroundDark = Color(hex: 0xFF1A1A0F)
    static let onBackgroundDark = Color(hex: 0xFFF5F5E0)
    static let surfaceDark = Color(hex: 0xFF1A1A0F)
    static let onSurfaceDark = Color(hex: 0xFFF5F5E0)
}

// ── Ordinary Time: Green (growth/life) ──
enum OrdinaryTimeColors {
    static let primary = Color(hex: 0xFF2E7D32)
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: 0xFFC8E6C9)
    static let onPrimaryContainer = Color(hex: 0xFF003300)
    static let secondary = Color(hex: 0xFF43A047)
    static let onSecondary = Color.white
    static let secondaryContainer = Color(hex: 0xFFE8F5E9)
    static let onSecondaryContainer = Color(hex: 0xFF1B5E20)
    static let tertiary = Color(hex: 0xFF81C784)
    static let onTertiary = Color(hex: 0xFF003300)
    static let background = Color(hex: 0xFFF5FFF5)
    static let onBackground = Color(hex: 0xFF1C1B1F)
    static let surface = Color(hex: 0xFFF5FFF5)
    static let onSurface = Color(hex: 0xFF1C1B1F)
    static let surfaceVariant = Color(hex: 0xFFE8F5E9)
    static let onSurfaceVariant = Color(hex: 0xFF49454F)
    static let error = Color(hex: 0xFFBA1A1A)
    static let onError = Color.white

    static let primaryDark = Color(hex: 0xFF81C784)
    static let onPrimaryDark = Color(hex: 0xFF003300)
    static let backgroundDark = Color(hex: 0xFF0F1A0F)
    static let onBackgroundDark = Color(hex: 0xFFE0F0E0)
    static let surfaceDark = Color(hex: 0xFF0F1A0F)
    static let onSurfaceDark = Color(hex: 0xFFE0F0E0)
}

// ── Pentecost: Fire + Holy Spirit (martyrdom/Spirit) ──
enum PentecostColors {
    static let primary = Color(hex: 0xFFC62828)
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: 0xFFFFCDD2)
    static let onPrimaryContainer = Color(hex: 0xFF5D0000)
    static let secondary = Color(hex: 0xFFE65100)
    static let onSecondary = Color.white
    static let secondaryContainer = Color(hex: 0xFFFFE0B2)
    static let onSecondaryContainer = Color(hex: 0xFF3E2723)
    static let tertiary = Color(hex: 0xFFFF8F00)
    static let onTertiary = Color(hex: 0xFF3E2723)
    static let background = Color(hex: 0xFFFFF8F6)
    static let onBackground = Color(hex: 0xFF1C1B1F)
    static let surface = Color(hex: 0xFFFFF8F6)
    static let onSurface = Color(hex: 0xFF1C1B1F)
    static let surfaceVariant = Color(hex: 0xFFFFEBEE)
    static let onSurfaceVariant = Color(hex: 0xFF49454F)
    static let error = Color(hex: 0xFFBA1A1A)
    static let onError = Color.white

    static let primaryDark = Color(hex: 0xFFEF9A9A)
    static let onPrimaryDark = Color(hex: 0xFF5D0000)
    static let backgroundDark = Color(hex: 0xFF1F0E0E)
    static let onBackgroundDark = Color(hex: 0xFFF5E0E0)
    static let surfaceDark = Color(hex: 0xFF1F0E0E)
    static let onSurfaceDark = Color(hex: 0xFFF5E0E0)
}

// ── Sacred accent colors (shared) ──
enum VerbumAccents {
    static let gold = Color(hex: 0xFFD4A017)
    static let sacredWhite = Color(hex: 0xFFFFFDF5)
    static let candleGlow = Color(hex: 0xFFFFF3C4)
    static let incenseSmoke = Color(hex: 0xFFE8E0D4)
    static let holyWater = Color(hex: 0xFFE3F2FD)
    static let bloodOfChrist = Color(hex: 0xFF8B0000)
    static let divineLight = Color(hex: 0xFFFFF9C4)
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
