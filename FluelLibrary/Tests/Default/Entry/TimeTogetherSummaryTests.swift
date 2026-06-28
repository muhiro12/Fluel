import Foundation
import Testing

import FluelLibrary

struct TimeTogetherSummaryTests {
    @Test
    func dayPrecisionSummarizesElapsedYearsMonthsAndDays() {
        let calendar = TestDateSupport.calendar
        let summary = TimeTogetherSummary(
            startDate: TestDateSupport.date(year: 2_024, month: 1, day: 15),
            precision: .day,
            referenceDate: TestDateSupport.date(year: 2_025, month: 3, day: 20),
            calendar: calendar
        )

        #expect(summary.primaryText == "1 year, 2 months")
        #expect(summary.fullText == "1 year, 2 months, 5 days")
        #expect(summary.supportingText == nil)
        #expect(summary.totalValueLabel == "Total days")
        #expect(summary.totalValueText != nil)
    }

    @Test
    func monthPrecisionSummarizesFromEarliestMonthDay() {
        let calendar = TestDateSupport.calendar
        let summary = TimeTogetherSummary(
            startDate: TestDateSupport.date(year: 2_025, month: 5, day: 30),
            precision: .month,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(summary.primaryText == "1 year, 1 month")
        #expect(summary.fullText == "1 year, 1 month")
        #expect(summary.supportingText != nil)
        #expect(summary.totalValueLabel == "Total months")
        #expect(summary.totalValueText == "13")
    }

    @Test
    func yearPrecisionSummarizesFromEarliestYearDay() {
        let calendar = TestDateSupport.calendar
        let summary = TimeTogetherSummary(
            startDate: TestDateSupport.date(year: 2_024, month: 10, day: 15),
            precision: .year,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(summary.primaryText == "2 years")
        #expect(summary.fullText == "2 years")
        #expect(summary.supportingText != nil)
        #expect(summary.totalValueLabel == nil)
        #expect(summary.totalValueText == nil)
    }
}
