import Foundation
import UIKit

@MainActor
final class SeasonalAppIconManager {
    static let shared = SeasonalAppIconManager()

    private init() {}

    func applyIcon(for season: LiturgicalSeason) {
        guard UIApplication.shared.supportsAlternateIcons else { return }

        let desiredName: String?
        switch season {
        case .advent:
            desiredName = "AdventIcon"
        case .christmas:
            desiredName = "ChristmasIcon"
        case .lent:
            desiredName = "LentIcon"
        case .easter:
            desiredName = "EasterIcon"
        case .pentecost:
            desiredName = "PentecostIcon"
        case .ordinaryTime:
            desiredName = nil // Primary AppIcon
        }

        if UIApplication.shared.alternateIconName == desiredName { return }

        UIApplication.shared.setAlternateIconName(desiredName) { error in
            if let error {
                VerbumLogger.w("Failed to set app icon: \(error.localizedDescription)")
            }
        }
    }
}
