import Foundation
import Testing

import FluelLibrary

struct EntryInputTests {
    @Test
    func inputRejectsFutureDayStart() {
        let calendar = TestDateSupport.calendar
        let currentDate = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let futureStart = TestDateSupport.start(year: 2_026, month: 6, day: 26)

        #expect(throws: EntryValidationError.futureStart) {
            try EntryInput(
                title: "Notebook",
                start: futureStart,
                currentDate: currentDate,
                calendar: calendar
            )
        }
    }

    @Test
    func inputRejectsFutureApproximateMonthStart() {
        let calendar = TestDateSupport.calendar
        let currentDate = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let futureStart = TestDateSupport.start(
            year: 2_026,
            month: 7,
            precision: .month
        )

        #expect(throws: EntryValidationError.futureStart) {
            try EntryInput(
                title: "Notebook",
                start: futureStart,
                currentDate: currentDate,
                calendar: calendar
            )
        }
    }

    @Test
    func inputPreservesApproximateStart() throws {
        let calendar = TestDateSupport.calendar
        let currentDate = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let monthInput = try EntryInput(
            title: "Notebook",
            start: TestDateSupport.start(
                year: 2_022,
                month: 3,
                precision: .month
            ),
            currentDate: currentDate,
            calendar: calendar
        )
        let yearInput = try EntryInput(
            title: "Notebook",
            start: TestDateSupport.start(
                year: 2_022,
                precision: .year
            ),
            currentDate: currentDate,
            calendar: calendar
        )

        #expect(monthInput.start == TestDateSupport.start(
            year: 2_022,
            month: 3,
            precision: .month
        ))
        #expect(yearInput.start == TestDateSupport.start(
            year: 2_022,
            precision: .year
        ))
    }

    @Test
    func futureValidationUsesTheReferenceTimeZoneCalendarDate() throws {
        let calendars = [
            TestDateSupport.calendar(timeZoneIdentifier: "Asia/Tokyo"),
            TestDateSupport.calendar(timeZoneIdentifier: "America/Los_Angeles")
        ]
        let today = TestDateSupport.start(year: 2_026, month: 7, day: 12)
        let tomorrow = TestDateSupport.start(year: 2_026, month: 7, day: 13)

        for calendar in calendars {
            let currentDate = TestDateSupport.date(
                year: 2_026,
                month: 7,
                day: 12,
                calendar: calendar
            )
            let input = try EntryInput(
                title: "Notebook",
                start: today,
                currentDate: currentDate,
                calendar: calendar
            )

            #expect(input.start == today)
            #expect(throws: EntryValidationError.futureStart) {
                try EntryInput(
                    title: "Notebook",
                    start: tomorrow,
                    currentDate: currentDate,
                    calendar: calendar
                )
            }
        }
    }
}
