import Foundation
import Testing

import FluelLibrary

struct StartPrecisionTests {
    @Test
    func startLabelsRemainStableAcrossTimeZones() {
        let tokyo = TestDateSupport.calendar(timeZoneIdentifier: "Asia/Tokyo")
        let losAngeles = TestDateSupport.calendar(
            timeZoneIdentifier: "America/Los_Angeles"
        )
        let starts = [
            TestDateSupport.start(year: 2_025, month: 5, day: 23),
            TestDateSupport.start(year: 2_025, month: 5, precision: .month),
            TestDateSupport.start(year: 2_025, precision: .year)
        ]

        for start in starts {
            let tokyoLabel = start.precision.startLabel(
                for: start,
                calendar: tokyo
            )
            let losAngelesLabel = start.precision.startLabel(
                for: start,
                calendar: losAngeles
            )

            #expect(tokyoLabel == losAngelesLabel)
        }
    }

    @Test
    func approximateRangeRemainsStableAcrossTimeZones() {
        let tokyo = TestDateSupport.calendar(timeZoneIdentifier: "Asia/Tokyo")
        let losAngeles = TestDateSupport.calendar(
            timeZoneIdentifier: "America/Los_Angeles"
        )
        let start = TestDateSupport.start(
            year: 2_024,
            month: 2,
            precision: .month
        )

        let tokyoRange = start.precision.startRangeLabel(
            for: start,
            calendar: tokyo
        )
        let losAngelesRange = start.precision.startRangeLabel(
            for: start,
            calendar: losAngeles
        )

        #expect(tokyoRange == losAngelesRange)
        #expect(tokyoRange?.contains("29") == true)
    }

    @Test
    func dayPrecisionHasNoApproximateRange() {
        let calendar = TestDateSupport.calendar
        let start = TestDateSupport.start(year: 2_025, month: 5, day: 23)

        let rangeLabel = start.precision.startRangeLabel(
            for: start,
            calendar: calendar
        )

        #expect(rangeLabel == nil)
    }
}
