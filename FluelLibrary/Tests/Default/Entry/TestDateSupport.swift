import Foundation

import FluelLibrary

// swiftlint:disable force_try force_unwrapping

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

    static func calendar(timeZoneIdentifier: String) -> Calendar {
        var configuredCalendar = calendar
        configuredCalendar.timeZone = TimeZone(identifier: timeZoneIdentifier)!
        return configuredCalendar
    }

    static func date(
        year: Int,
        month: Int,
        day: Int,
        calendar: Calendar
    ) -> Date {
        DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day
        ).date!
    }

    static func start(
        year: Int,
        month: Int,
        day: Int,
        precision: StartPrecision
    ) -> EntryStart {
        switch precision {
        case .day:
            try! EntryStart.day(year: year, month: month, day: day)
        case .month:
            try! EntryStart.month(year: year, month: month)
        case .year:
            try! EntryStart.year(year)
        }
    }

    static func start(
        year: Int,
        month: Int,
        day: Int
    ) -> EntryStart {
        start(
            year: year,
            month: month,
            day: day,
            precision: .day
        )
    }

    static func start(
        year: Int,
        month: Int,
        precision: StartPrecision
    ) -> EntryStart {
        start(
            year: year,
            month: month,
            day: 1,
            precision: precision
        )
    }

    static func start(
        year: Int,
        precision: StartPrecision
    ) -> EntryStart {
        start(
            year: year,
            month: 1,
            day: 1,
            precision: precision
        )
    }
}

// swiftlint:enable force_try force_unwrapping
