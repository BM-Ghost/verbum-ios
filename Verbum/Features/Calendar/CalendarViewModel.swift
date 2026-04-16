import SwiftUI

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedDay: LiturgicalDay
    @Published var monthDays: [Date] = []
    @Published var monthTitle: String = ""

    private let engine = LiturgicalCalendarEngine()

    init() {
        self.selectedDay = LiturgicalCalendarEngine().getLiturgicalDay(date: Date())
        loadMonth()
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        selectedDay = engine.getLiturgicalDay(date: date)
    }

    func getLiturgicalDay(for date: Date) -> LiturgicalDay {
        engine.getLiturgicalDay(date: date)
    }

    func loadMonth() {
        let cal = Calendar.current
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: selectedDate))!
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        monthTitle = monthFormatter.string(from: monthStart)

        let firstWeekday = cal.component(.weekday, from: monthStart)
        let offset = firstWeekday - cal.firstWeekday
        let normalizedOffset = offset < 0 ? offset + 7 : offset
        let gridStart = cal.date(byAdding: .day, value: -normalizedOffset, to: monthStart)!

        monthDays = (0..<42).map { idx in
            cal.date(byAdding: .day, value: idx, to: gridStart)!
        }
    }

    func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
        selectDate(selectedDate)
        loadMonth()
    }

    func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
        selectDate(selectedDate)
        loadMonth()
    }
}
