import Foundation
import Testing

import FluelLibrary

struct StartPrecisionTests {
    @Test
    func monthPrecisionNormalizesToFirstDayOfMonth() {
        let calendar = TestDateSupport.calendar
        let startDate = TestDateSupport.date(year: 2_025, month: 5, day: 23)
        let expectedDate = TestDateSupport.date(year: 2_025, month: 5, day: 1)

        let normalizedDate = StartPrecision.month.normalizedStartDate(
            from: startDate,
            calendar: calendar
        )

        #expect(normalizedDate == expectedDate)
    }

    @Test
    func yearPrecisionNormalizesToFirstDayOfYear() {
        let calendar = TestDateSupport.calendar
        let startDate = TestDateSupport.date(year: 2_025, month: 5, day: 23)
        let expectedDate = TestDateSupport.date(year: 2_025, month: 1, day: 1)

        let normalizedDate = StartPrecision.year.normalizedStartDate(
            from: startDate,
            calendar: calendar
        )

        #expect(normalizedDate == expectedDate)
    }

    @Test
    func dayPrecisionHasNoApproximateRange() {
        let calendar = TestDateSupport.calendar
        let startDate = TestDateSupport.date(year: 2_025, month: 5, day: 23)

        let rangeLabel = StartPrecision.day.startRangeLabel(
            for: startDate,
            calendar: calendar
        )

        #expect(rangeLabel == nil)
    }
}
