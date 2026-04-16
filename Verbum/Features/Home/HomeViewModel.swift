import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var verseOfDay: (text: String, reference: String) = (
        "\u{201C}In the beginning was the Word, and the Word was with God, and the Word was God.\u{201D}",
        "John 1:1"
    )
    @Published var todaysMass: (title: String, firstReading: String, gospel: String) = (
        "Wednesday of the 3rd Week of Easter",
        "First Reading: Acts 8:1b-8",
        "Gospel: John 6:35-40"
    )
    @Published var continueReading: (book: String, verse: String) = ("John 1", "Continue from verse 14")

    func seasonEmoji(_ season: LiturgicalSeason) -> String {
        switch season {
        case .advent: return "🕯️"
        case .christmas: return "⭐"
        case .lent: return "✝️"
        case .easter: return "🌞"
        case .pentecost: return "🔥"
        case .ordinaryTime: return "🌿"
        }
    }

    func seasonGreeting(_ season: LiturgicalSeason) -> String {
        switch season {
        case .advent: return "Prepare the way of the Lord"
        case .christmas: return "The Word became flesh and dwelt among us"
        case .lent: return "Return to the Lord with all your heart"
        case .easter: return "He is risen! Alleluia!"
        case .pentecost: return "Come, Holy Spirit, fill the hearts of your faithful"
        case .ordinaryTime: return "Grow in the grace and knowledge of our Lord"
        }
    }

    func seasonPrayer(_ season: LiturgicalSeason) -> String {
        switch season {
        case .advent: return "Come, Lord Jesus. Fill our hearts with hope as we await your coming."
        case .christmas: return "O God, who wonderfully created human dignity and still more wonderfully restored it, grant that we may share in the divinity of Christ."
        case .lent: return "Lord, grant us the grace of true repentance. Help us turn our hearts back to You."
        case .easter: return "God of life, through the resurrection of your Son, you have filled us with joy. Help us be witnesses of your love."
        case .pentecost: return "Come, Holy Spirit, enkindle in us the fire of your love. Send forth your Spirit and renew the face of the earth."
        case .ordinaryTime: return "Lord, guide our steps today. May we grow closer to You in all that we do."
        }
    }
}
