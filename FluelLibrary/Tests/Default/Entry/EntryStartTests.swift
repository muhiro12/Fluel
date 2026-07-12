import Foundation
import Testing

import FluelLibrary

struct EntryStartTests {
    private enum FixtureError: Error {
        case invalidDate
        case unavailableTimeZone
    }

    @Test
    func dayStartPreservesGregorianComponents() throws {
        let start = try EntryStart.day(
            year: 2_026,
            month: 7,
            day: 12
        )

        #expect(start.year == 2_026)
        #expect(start.month == 7)
        #expect(start.day == 12)
        #expect(start.precision == .day)
    }

    @Test
    func approximateStartsNormalizeUnknownComponents() throws {
        let monthStart = try EntryStart.month(year: 2_026, month: 7)
        let yearStart = try EntryStart.year(2_026)

        #expect(monthStart.year == 2_026)
        #expect(monthStart.month == 7)
        #expect(monthStart.day == 1)
        #expect(monthStart.precision == .month)
        #expect(yearStart.year == 2_026)
        #expect(yearStart.month == 1)
        #expect(yearStart.day == 1)
        #expect(yearStart.precision == .year)
    }

    @Test
    func startAcceptsGregorianLeapDay() throws {
        let start = try EntryStart.day(
            year: 2_024,
            month: 2,
            day: 29
        )

        #expect(start.year == 2_024)
        #expect(start.month == 2)
        #expect(start.day == 29)
    }

    @Test
    func startRejectsInvalidGregorianDates() {
        #expect(throws: EntryStart.ValidationError.invalidDate(year: 2_025, month: 2, day: 29)) {
            try EntryStart.day(year: 2_025, month: 2, day: 29)
        }
        #expect(throws: EntryStart.ValidationError.invalidDate(year: 2_026, month: 13, day: 1)) {
            try EntryStart.month(year: 2_026, month: 13)
        }
        #expect(throws: EntryStart.ValidationError.invalidDate(year: 0, month: 1, day: 1)) {
            try EntryStart.year(0)
        }
    }

    @Test
    func startRemainsTheSameCalendarDateAcrossTimeZones() throws {
        let tokyo = try timeZone(identifier: "Asia/Tokyo")
        let losAngeles = try timeZone(identifier: "America/Los_Angeles")
        let tokyoDate = try date(
            year: 2_025,
            month: 1,
            day: 1,
            timeZone: tokyo
        )
        let start = try EntryStart(
            date: tokyoDate,
            precision: .day,
            timeZone: tokyo
        )

        let resolvedTokyoDate = try start.date(in: tokyo)
        let resolvedLosAngelesDate = try start.date(in: losAngeles)

        #expect(resolvedTokyoDate != resolvedLosAngelesDate)
        #expect(components(of: resolvedTokyoDate, timeZone: tokyo) == [2_025, 1, 1])
        #expect(components(of: resolvedLosAngelesDate, timeZone: losAngeles) == [2_025, 1, 1])
    }

    @Test
    func dateInitializerNormalizesUsingPrecision() throws {
        let tokyo = try timeZone(identifier: "Asia/Tokyo")
        let sourceDate = try date(
            year: 2_026,
            month: 7,
            day: 12,
            timeZone: tokyo
        )

        let dayStart = try EntryStart(
            date: sourceDate,
            precision: .day,
            timeZone: tokyo
        )
        let monthStart = try EntryStart(
            date: sourceDate,
            precision: .month,
            timeZone: tokyo
        )
        let yearStart = try EntryStart(
            date: sourceDate,
            precision: .year,
            timeZone: tokyo
        )

        #expect(dayStart.year == 2_026)
        #expect(dayStart.month == 7)
        #expect(dayStart.day == 12)
        #expect(monthStart.year == 2_026)
        #expect(monthStart.month == 7)
        #expect(monthStart.day == 1)
        #expect(yearStart.year == 2_026)
        #expect(yearStart.month == 1)
        #expect(yearStart.day == 1)
    }

    @Test
    func dateConversionFollowsDaylightSavingCalendarBoundaries() throws {
        let losAngeles = try timeZone(identifier: "America/Los_Angeles")
        let transitionStart = try EntryStart.day(
            year: 2_026,
            month: 3,
            day: 8
        )
        let followingStart = try EntryStart.day(
            year: 2_026,
            month: 3,
            day: 9
        )

        let transitionDate = try transitionStart.date(in: losAngeles)
        let followingDate = try followingStart.date(in: losAngeles)

        #expect(components(of: transitionDate, timeZone: losAngeles) == [2_026, 3, 8])
        #expect(components(of: followingDate, timeZone: losAngeles) == [2_026, 3, 9])
        #expect(followingDate.timeIntervalSince(transitionDate) == 82_800)
    }

    @Test
    func comparableOrdersByDateThenPrecision() throws {
        let starts = [
            try EntryStart.day(year: 2_026, month: 1, day: 2),
            try EntryStart.day(year: 2_026, month: 1, day: 1),
            try EntryStart.year(2_026),
            try EntryStart.month(year: 2_026, month: 1),
            try EntryStart.year(2_025)
        ]

        #expect(starts.sorted() == [
            try EntryStart.year(2_025),
            try EntryStart.year(2_026),
            try EntryStart.month(year: 2_026, month: 1),
            try EntryStart.day(year: 2_026, month: 1, day: 1),
            try EntryStart.day(year: 2_026, month: 1, day: 2)
        ])
    }

    private func timeZone(identifier: String) throws -> TimeZone {
        guard let timeZone = TimeZone(identifier: identifier) else {
            throw FixtureError.unavailableTimeZone
        }

        return timeZone
    }

    private func date(
        year: Int,
        month: Int,
        day: Int,
        timeZone: TimeZone
    ) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        guard let date = calendar.date(from: DateComponents(
            calendar: calendar,
            timeZone: timeZone,
            year: year,
            month: month,
            day: day
        )) else {
            throw FixtureError.invalidDate
        }

        return date
    }

    private func components(
        of date: Date,
        timeZone: TimeZone
    ) -> [Int] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        return [
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        ]
    }
}
