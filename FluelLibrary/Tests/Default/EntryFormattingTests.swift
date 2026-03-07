import Foundation
@testable import FluelLibrary
import Testing

struct EntryFormattingTests {
    private let enUS: Locale = .init(identifier: "en_US_POSIX")
    private let jaJP: Locale = .init(identifier: "ja_JP")
    private let calendar: Calendar = .init(identifier: .gregorian)

    @Test
    func primaryElapsedText_formats_english_day_precision() throws {
        let snapshot = EntryElapsedSnapshot(
            startComponents: try .init(
                precision: .day,
                year: 2_023,
                month: 1,
                day: 15
            ),
            referenceDate: isoDate("2025-04-20T12:00:00Z"),
            calendar: calendar
        )

        let result = EntryFormatting.primaryElapsedText(
            for: snapshot,
            locale: enUS
        )

        #expect(result == "2 years, 3 months")
    }

    @Test
    func primaryElapsedText_formats_english_month_precision_special_case() throws {
        let snapshot = EntryElapsedSnapshot(
            startComponents: try .init(
                precision: .month,
                year: 2_026,
                month: 3
            ),
            referenceDate: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )

        let result = EntryFormatting.primaryElapsedText(
            for: snapshot,
            locale: enUS
        )

        #expect(result == "This month")
    }

    @Test
    func startLabelText_formats_japanese_year_precision() throws {
        let result = EntryFormatting.startLabelText(
            for: try .init(
                precision: .year,
                year: 2_020
            ),
            locale: jaJP,
            calendar: calendar
        )

        #expect(result == "2020年から")
    }

    @Test
    func precisionText_formats_japanese_month_precision() {
        let result = EntryFormatting.precisionText(
            for: .month,
            locale: jaJP
        )

        #expect(result == "月まで分かる")
    }
}
