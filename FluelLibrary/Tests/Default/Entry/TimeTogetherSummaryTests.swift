import Foundation
import Testing

import FluelLibrary

struct TimeTogetherSummaryTests {
    @Test
    func dayPrecisionSummarizesElapsedYearsMonthsAndDays() {
        let calendar = TestDateSupport.calendar
        let summary = TimeTogetherSummary(
            start: TestDateSupport.start(year: 2_024, month: 1, day: 15),
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
            start: TestDateSupport.start(
                year: 2_025,
                month: 5,
                precision: .month
            ),
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
            start: TestDateSupport.start(year: 2_024, precision: .year),
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(summary.primaryText == "2 years")
        #expect(summary.fullText == "2 years")
        #expect(summary.supportingText != nil)
        #expect(summary.totalValueLabel == nil)
        #expect(summary.totalValueText == nil)
    }

    @Test
    func elapsedSummaryRemainsStableAcrossTimeZones() {
        let start = TestDateSupport.start(year: 2_024, month: 1, day: 15)
        let tokyo = TestDateSupport.calendar(timeZoneIdentifier: "Asia/Tokyo")
        let losAngeles = TestDateSupport.calendar(
            timeZoneIdentifier: "America/Los_Angeles"
        )
        let tokyoSummary = TimeTogetherSummary(
            start: start,
            referenceDate: TestDateSupport.date(
                year: 2_026,
                month: 6,
                day: 25,
                calendar: tokyo
            ),
            calendar: tokyo
        )
        let losAngelesSummary = TimeTogetherSummary(
            start: start,
            referenceDate: TestDateSupport.date(
                year: 2_026,
                month: 6,
                day: 25,
                calendar: losAngeles
            ),
            calendar: losAngeles
        )

        #expect(tokyoSummary == losAngelesSummary)
    }
}
