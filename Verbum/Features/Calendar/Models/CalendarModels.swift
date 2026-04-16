import Foundation

struct LiturgicalDay: Identifiable, Hashable {
    var id: Date { date }
    let date: Date
    let season: LiturgicalSeason
    let celebration: String
    let rank: CelebrationRank
    let liturgicalColor: LiturgicalColor
    let saintOfDay: String?
    let optionalMemorials: [String]

    init(date: Date, season: LiturgicalSeason, celebration: String, rank: CelebrationRank, liturgicalColor: LiturgicalColor, saintOfDay: String? = nil, optionalMemorials: [String] = []) {
        self.date = date
        self.season = season
        self.celebration = celebration
        self.rank = rank
        self.liturgicalColor = liturgicalColor
        self.saintOfDay = saintOfDay
        self.optionalMemorials = optionalMemorials
    }
}

enum CelebrationRank: String, Hashable {
    case solemnity = "Solemnity"
    case feast = "Feast"
    case memorial = "Memorial"
    case optionalMemorial = "Optional Memorial"
    case weekday = "Weekday"
    case sunday = "Sunday"
}

enum LiturgicalColor: String, Hashable {
    case green = "Green"
    case violet = "Violet"
    case white = "White"
    case red = "Red"
    case rose = "Rose"
    case black = "Black"
    case gold = "Gold"

    var displayName: String { rawValue }
}

struct LiturgicalWeek {
    let weekNumber: Int
    let season: LiturgicalSeason
    let days: [LiturgicalDay]
}
