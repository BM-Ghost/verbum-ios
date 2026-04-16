import Foundation

struct Prayer: Identifiable, Hashable {
    let id: String
    let title: String
    let category: PrayerCategory
    let text: String
    let latinText: String?

    init(id: String, title: String, category: PrayerCategory, text: String, latinText: String? = nil) {
        self.id = id
        self.title = title
        self.category = category
        self.text = text
        self.latinText = latinText
    }
}

enum PrayerCategory: String, CaseIterable, Hashable {
    case rosary = "Rosary"
    case devotion = "Devotions"
    case morning = "Morning Prayers"
    case evening = "Evening Prayers"
    case saints = "Prayers to Saints"

    var displayName: String { rawValue }

    var emoji: String {
        switch self {
        case .rosary: return "📿"
        case .devotion: return "🕯️"
        case .morning: return "🌅"
        case .evening: return "🌙"
        case .saints: return "⭐"
        }
    }
}
