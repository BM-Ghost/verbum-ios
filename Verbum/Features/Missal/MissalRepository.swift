import Foundation

@MainActor
final class MissalRepository: ObservableObject {
    private let apiClient: VerbumAPIClient?

    init(apiClient: VerbumAPIClient? = nil) {
        self.apiClient = apiClient
    }

    func getDailyReadings(for date: Date) -> DailyReadings {
        let dateText = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        return DailyReadings(
            date: dateText,
            season: .easter,
            feastOrMemorial: "Wednesday of the 3rd Week of Easter",
            readings: [
                MissalReading(id: "1", type: .firstReading, title: "First Reading",
                              reference: "Acts 8:1b-8",
                              text: "There broke out a severe persecution of the Church in Jerusalem; all were scattered throughout the countryside of Judea and Samaria, except the apostles. Devout men buried Stephen and made a loud lament over him. Saul, meanwhile, was trying to destroy the Church; entering house after house and dragging out men and women, he handed them over for imprisonment."),
                MissalReading(id: "2", type: .psalm, title: "Responsorial Psalm",
                              reference: "Ps 66:1-3a, 4-5, 6-7a",
                              text: "R. Let all the earth cry out to God with joy.\nShout joyfully to God, all the earth, sing praise to the glory of his name; proclaim his glorious praise."),
                MissalReading(id: "3", type: .secondReading, title: "Second Reading",
                              reference: "1 Peter 2:4-9",
                              text: "Beloved: Come to him, a living stone, rejected by human beings but chosen and precious in the sight of God, and, like living stones, let yourselves be built into a spiritual house to be a holy priesthood."),
                MissalReading(id: "4", type: .gospel, title: "Gospel",
                              reference: "John 6:35-40",
                              text: "Jesus said to the crowds, \"I am the bread of life; whoever comes to me will never hunger, and whoever believes in me will never thirst. But I told you that although you have seen me, you do not believe. Everything that the Father gives me will come to me, and I will not reject anyone who comes to me, because I came down from heaven not to do my own will but the will of the one who sent me.\""),
            ]
        )
    }

    func getVerseOfTheDay() -> Verse {
        Verse(bookId: 50, bookName: "John", chapter: 1, verseNumber: 14,
              text: "And the Word became flesh and dwelt among us, and we have seen his glory, glory as of the only Son from the Father, full of grace and truth.")
    }
}
