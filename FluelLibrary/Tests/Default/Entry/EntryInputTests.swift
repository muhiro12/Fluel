import Foundation
import Testing

import FluelLibrary

struct EntryInputTests {
    @Test
    func inputRejectsFutureDayStart() {
        let calendar = TestDateSupport.calendar
        let currentDate = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let futureDate = TestDateSupport.date(year: 2_026, month: 6, day: 26)

        #expect(throws: EntryValidationError.futureStart) {
            try EntryInput(
                title: "Notebook",
                startDate: futureDate,
                startPrecision: .day,
                currentDate: currentDate,
                calendar: calendar
            )
        }
    }

    @Test
    func inputRejectsFutureApproximateMonthStart() {
        let calendar = TestDateSupport.calendar
        let currentDate = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let futureDate = TestDateSupport.date(year: 2_026, month: 7, day: 12)

        #expect(throws: EntryValidationError.futureStart) {
            try EntryInput(
                title: "Notebook",
                startDate: futureDate,
                startPrecision: .month,
                currentDate: currentDate,
                calendar: calendar
            )
        }
    }

    @Test
    func inputPreservesApproximateComponentsFromStartDate() throws {
        let calendar = TestDateSupport.calendar
        let currentDate = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let startDate = TestDateSupport.date(year: 2_022, month: 3, day: 18)

        let monthInput = try EntryInput(
            title: "Notebook",
            startDate: startDate,
            startPrecision: .month,
            currentDate: currentDate,
            calendar: calendar
        )
        let yearInput = try EntryInput(
            title: "Notebook",
            startDate: startDate,
            startPrecision: .year,
            currentDate: currentDate,
            calendar: calendar
        )

        #expect(monthInput.startDate == TestDateSupport.date(year: 2_022, month: 3, day: 1))
        #expect(monthInput.startPrecision == .month)
        #expect(yearInput.startDate == TestDateSupport.date(year: 2_022, month: 1, day: 1))
        #expect(yearInput.startPrecision == .year)
    }
}
