import SwiftUI

/// Represents the liturgical seasons of the Catholic Church.
/// Drives theme changes, prayer suggestions, and AI tone adaptation.
enum LiturgicalSeason: String, CaseIterable, Codable {
    case advent = "Advent"
    case christmas = "Christmas"
    case lent = "Lent"
    case easter = "Easter"
    case pentecost = "Pentecost"
    case ordinaryTime = "Ordinary Time"

    var displayName: String { rawValue }

    static func from(_ value: String) -> LiturgicalSeason {
        allCases.first { $0.rawValue.caseInsensitiveCompare(value) == .orderedSame }
            ?? .ordinaryTime
    }
}
