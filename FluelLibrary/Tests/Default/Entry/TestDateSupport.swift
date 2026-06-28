import Foundation

// swiftlint:disable force_unwrapping

enum TestDateSupport {
    static var calendar: Calendar {
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.locale = Locale(identifier: "en_US_POSIX")
        gregorianCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return gregorianCalendar
    }

    static func date(year: Int, month: Int, day: Int) -> Date {
        DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day
        ).date!
    }
}

// swiftlint:enable force_unwrapping
