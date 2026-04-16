import Foundation

struct DailyReadings: Identifiable {
    var id: String { date }
    let date: String
    let season: LiturgicalSeason
    let feastOrMemorial: String?
    let readings: [MissalReading]
}

struct MissalReading: Identifiable {
    let id: String
    let type: ReadingType
    let title: String
    let reference: String
    let text: String
}

enum ReadingType: String, CaseIterable {
    case firstReading = "First Reading"
    case psalm = "Responsorial Psalm"
    case secondReading = "Second Reading"
    case gospel = "Gospel"

    var displayName: String { rawValue }

    static func from(_ raw: String) -> ReadingType {
        switch raw.lowercased() {
        case "first_reading": return .firstReading
        case "psalm": return .psalm
        case "second_reading": return .secondReading
        case "gospel": return .gospel
        default: return .firstReading
        }
    }
}
