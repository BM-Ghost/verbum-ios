import Foundation

extension Date {
    var liturgicalKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    var monthValue: Int { Calendar.current.component(.month, from: self) }
    var dayOfMonth: Int { Calendar.current.component(.day, from: self) }
    var year: Int { Calendar.current.component(.year, from: self) }
}
