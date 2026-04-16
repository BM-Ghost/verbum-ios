import Foundation

final class LiturgicalCalendarEngine {

    func getLiturgicalDay(date: Date) -> LiturgicalDay {
        let season = computeSeason(date: date)
        return LiturgicalDay(
            date: date,
            season: season,
            celebration: getCelebration(date: date, season: season),
            rank: getRank(date: date, season: season),
            liturgicalColor: getColor(date: date, season: season),
            saintOfDay: getSaint(date: date)
        )
    }

    func computeSeason(date: Date) -> LiturgicalSeason {
        let cal = Calendar.current
        let year = cal.component(.year, from: date)
        let easter = computeEaster(year: year)

        let adventStart = computeAdventStart(year: year)
        let christmasStart = cal.date(from: DateComponents(year: year, month: 12, day: 25))!
        let epiphanyNext = computeEpiphany(year: year + 1)
        let ashWednesday = cal.date(byAdding: .day, value: -46, to: easter)!
        let pentecost = cal.date(byAdding: .day, value: 49, to: easter)!
        let pentecostEnd = cal.date(byAdding: .day, value: 56, to: easter)!
        let prevEpiphany = computeEpiphany(year: year)

        if date < prevEpiphany { return .christmas }
        if date >= ashWednesday && date < easter { return .lent }
        if date >= easter && date < pentecost { return .easter }
        if date >= pentecost && date <= pentecostEnd { return .pentecost }
        if date >= adventStart && date < christmasStart { return .advent }
        if date >= christmasStart { return .christmas }
        return .ordinaryTime
    }

    func computeEaster(year: Int) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = (h + l - 7 * m + 114) % 31 + 1
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func computeAdventStart(year: Int) -> Date {
        let cal = Calendar.current
        let christmas = cal.date(from: DateComponents(year: year, month: 12, day: 25))!
        let weekday = cal.component(.weekday, from: christmas)
        let daysToSunday = (weekday == 1) ? 0 : (weekday - 1)
        let sundayBefore = cal.date(byAdding: .day, value: -daysToSunday, to: christmas)!
        return cal.date(byAdding: .weekOfYear, value: -3, to: sundayBefore)!
    }

    private func computeEpiphany(year: Int) -> Date {
        let cal = Calendar.current
        let jan2 = cal.date(from: DateComponents(year: year, month: 1, day: 2))!
        let weekday = cal.component(.weekday, from: jan2)
        let daysToSunday = weekday == 1 ? 0 : (8 - weekday)
        return cal.date(byAdding: .day, value: daysToSunday, to: jan2)!
    }

    private func getCelebration(date: Date, season: LiturgicalSeason) -> String {
        let cal = Calendar.current
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        let weekday = cal.component(.weekday, from: date)

        switch (month, day) {
        case (12, 25): return "The Nativity of the Lord (Christmas)"
        case (1, 1): return "Solemnity of Mary, Mother of God"
        case (3, 19): return "Solemnity of St. Joseph"
        case (3, 25): return "Annunciation of the Lord"
        case (6, 24): return "Nativity of St. John the Baptist"
        case (6, 29): return "Solemnity of Sts. Peter and Paul"
        case (8, 15): return "Assumption of the Blessed Virgin Mary"
        case (11, 1): return "All Saints' Day"
        case (11, 2): return "All Souls' Day"
        case (12, 8): return "Immaculate Conception"
        default:
            if weekday == 1 { return "Sunday of \(season.displayName)" }
            return "\(season.displayName) Weekday"
        }
    }

    private func getRank(date: Date, season: LiturgicalSeason) -> CelebrationRank {
        let cal = Calendar.current
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        let weekday = cal.component(.weekday, from: date)

        switch (month, day) {
        case (12, 25), (1, 1), (8, 15), (11, 1), (12, 8): return .solemnity
        default:
            return weekday == 1 ? .sunday : .weekday
        }
    }

    private func getColor(date: Date, season: LiturgicalSeason) -> LiturgicalColor {
        let cal = Calendar.current
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)

        if month == 12 && day == 25 { return .white }
        if month == 11 && day == 2 { return .violet }

        switch season {
        case .advent: return .violet
        case .christmas: return .white
        case .lent: return .violet
        case .easter: return .white
        case .pentecost: return .red
        case .ordinaryTime: return .green
        }
    }

    private func getSaint(date: Date) -> String? {
        let cal = Calendar.current
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)

        switch (month, day) {
        case (1, 28): return "St. Thomas Aquinas"
        case (2, 14): return "Sts. Cyril and Methodius"
        case (3, 17): return "St. Patrick"
        case (4, 29): return "St. Catherine of Siena"
        case (5, 13): return "Our Lady of Fatima"
        case (6, 13): return "St. Anthony of Padua"
        case (7, 11): return "St. Benedict"
        case (8, 28): return "St. Augustine"
        case (9, 23): return "St. Padre Pio"
        case (10, 1): return "St. Thérèse of Lisieux"
        case (10, 4): return "St. Francis of Assisi"
        case (10, 7): return "Our Lady of the Rosary"
        case (11, 3): return "St. Martin de Porres"
        case (12, 6): return "St. Nicholas"
        case (12, 12): return "Our Lady of Guadalupe"
        default: return nil
        }
    }
}
