import Foundation
@testable import FluelLibrary
import Testing

struct EntryFormattingTests {
    private let enUS: Locale = .init(identifier: "en_US_POSIX")
    private let jaJP: Locale = .init(identifier: "ja_JP")
    private let esES: Locale = .init(identifier: "es_ES")
    private let frFR: Locale = .init(identifier: "fr_FR")
    private let zhHans: Locale = .init(identifier: "zh-Hans")
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
    func primaryElapsedText_formats_spanish_day_precision() throws {
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
            locale: esES
        )

        #expect(result == "2 años, 3 meses")
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
    func startLabelText_formats_french_year_precision() throws {
        let result = EntryFormatting.startLabelText(
            for: try .init(
                precision: .year,
                year: 2_020
            ),
            locale: frFR,
            calendar: calendar
        )

        #expect(result == "Depuis 2020")
    }

    @Test
    func formStartSummaryText_formats_english_day_precision() throws {
        let result = EntryFormatting.formStartSummaryText(
            for: try .init(
                precision: .day,
                year: 2_024,
                month: 5,
                day: 11
            ),
            locale: enUS,
            calendar: calendar
        )

        #expect(result == "Starts on May 11, 2024")
    }

    @Test
    func formStartSummaryText_formats_english_month_precision() throws {
        let result = EntryFormatting.formStartSummaryText(
            for: try .init(
                precision: .month,
                year: 2_024,
                month: 3
            ),
            locale: enUS,
            calendar: calendar
        )

        #expect(result == "Starts sometime in Mar 2024")
    }

    @Test
    func formStartSummaryText_formats_japanese_year_precision() throws {
        let result = EntryFormatting.formStartSummaryText(
            for: try .init(
                precision: .year,
                year: 2_018
            ),
            locale: jaJP,
            calendar: calendar
        )

        #expect(result == "2018年のどこかで始まる")
    }

    @Test
    func formStartSummaryText_formats_chinese_month_precision() throws {
        let result = EntryFormatting.formStartSummaryText(
            for: try .init(
                precision: .month,
                year: 2_024,
                month: 3
            ),
            locale: zhHans,
            calendar: calendar
        )

        #expect(result.contains("大约始于"))
        #expect(result.contains("2024"))
    }

    @Test
    func precisionText_formats_japanese_month_precision() {
        let result = EntryFormatting.precisionText(
            for: .month,
            locale: jaJP
        )

        #expect(result == "月まで分かる")
    }

    @Test
    func precisionText_formats_spanish_month_precision() {
        let result = EntryFormatting.precisionText(
            for: .month,
            locale: esES
        )

        #expect(result == "Conocido hasta el mes")
    }

    @Test
    func startRangeText_formats_english_month_precision() throws {
        let result = EntryFormatting.startRangeText(
            for: try .init(
                precision: .month,
                year: 2_024,
                month: 3
            ),
            locale: enUS,
            calendar: calendar
        )

        #expect(result == "Sometime in Mar 2024")
    }

    @Test
    func startRangeText_formats_japanese_year_precision() throws {
        let result = EntryFormatting.startRangeText(
            for: try .init(
                precision: .year,
                year: 2_018
            ),
            locale: jaJP,
            calendar: calendar
        )

        #expect(result == "2018年のどこか")
    }

    @Test
    func notePreviewText_collapses_multiline_whitespace() {
        let result = EntryFormatting.notePreviewText(
            "  Always here\nwith me \n  every day  "
        )

        #expect(result == "Always here with me every day")
    }

    @Test
    func notePreviewText_returns_nil_for_blank_note() {
        let result = EntryFormatting.notePreviewText(
            " \n "
        )

        #expect(result == nil)
    }

    @Test
    func noteCharacterCountText_formats_english_plural_count() {
        let result = EntryFormatting.noteCharacterCountText(
            "With a lamp",
            locale: enUS
        )

        #expect(result == "11 characters")
    }

    @Test
    func noteCharacterCountText_returns_nil_for_blank_note() {
        let result = EntryFormatting.noteCharacterCountText(
            " \n ",
            locale: jaJP
        )

        #expect(result == nil)
    }

    @Test
    func noteCharacterCountText_formats_chinese_count() {
        let result = EntryFormatting.noteCharacterCountText(
            "With a lamp",
            locale: zhHans
        )

        #expect(result == "11 个字符")
    }

    @Test
    func metadataBadgeTexts_returns_photo_note_and_approximate_start_badges() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Lamp",
                precision: .month,
                year: 2_024,
                month: 3,
                photoData: Data([0x01]),
                note: "  By the sofa  "
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )

        let result = EntryFormatting.metadataBadgeTexts(
            for: entry,
            locale: enUS
        )

        #expect(result == ["Photo", "Note", "Approximate start"])
    }

    @Test
    func metadataBadgeTexts_skips_note_badge_for_blank_note() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Desk",
                precision: .year,
                year: 2_020,
                note: " \n "
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )

        let result = EntryFormatting.metadataBadgeTexts(
            for: entry,
            locale: jaJP
        )

        #expect(result == ["開始はおおよそ"])
    }

    @Test
    func metadataBadgeTexts_skips_approximate_start_for_exact_day() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_025,
                month: 8,
                day: 14,
                photoData: Data([0x02])
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )

        let result = EntryFormatting.metadataBadgeTexts(
            for: entry,
            locale: enUS
        )

        #expect(result == ["Photo"])
    }

    @Test
    func metadataBadgeTexts_formats_french_badges() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Lampe",
                precision: .month,
                year: 2_024,
                month: 3,
                photoData: Data([0x01]),
                note: "  Salon  "
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )

        let result = EntryFormatting.metadataBadgeTexts(
            for: entry,
            locale: frFR
        )

        #expect(result == ["Photo", "Note", "Début approximatif"])
    }

    @Test
    func archivedFooterText_returns_archived_text_without_note() {
        let result = EntryFormatting.archivedFooterText(
            archivedAt: isoDate("2026-03-08T12:00:00Z"),
            note: nil,
            locale: enUS
        )

        #expect(result == "Archived on Mar 8, 2026")
    }

    @Test
    func archivedFooterText_appends_note_preview() {
        let result = EntryFormatting.archivedFooterText(
            archivedAt: isoDate("2026-03-08T12:00:00Z"),
            note: "  Living room\nlamp  ",
            locale: enUS
        )

        #expect(result == "Archived on Mar 8, 2026 | Living room lamp")
    }

    @Test
    func createdOnText_formats_english_date() {
        let result = EntryFormatting.createdOnText(
            isoDate("2026-03-08T12:00:00Z"),
            locale: enUS
        )

        #expect(result == "Created on Mar 8, 2026")
    }

    @Test
    func createdOnText_formats_japanese_date() {
        let result = EntryFormatting.createdOnText(
            isoDate("2026-03-08T12:00:00Z"),
            locale: jaJP
        )

        #expect(result == "2026年3月8日に作成")
    }

    @Test
    func updatedOnText_formats_english_date() {
        let result = EntryFormatting.updatedOnText(
            isoDate("2026-03-08T12:00:00Z"),
            locale: enUS
        )

        #expect(result == "Updated on Mar 8, 2026")
    }

    @Test
    func updatedOnText_formats_japanese_date() {
        let result = EntryFormatting.updatedOnText(
            isoDate("2026-03-08T12:00:00Z"),
            locale: jaJP
        )

        #expect(result == "2026年3月8日に更新")
    }

    @Test
    func createdOnText_formats_spanish_date() {
        let result = EntryFormatting.createdOnText(
            isoDate("2026-03-08T12:00:00Z"),
            locale: esES
        )

        #expect(result.contains("Creado el"))
    }

    @Test
    func archivedDurationText_formats_english_elapsed_value() throws {
        let result = EntryFormatting.archivedDurationText(
            startComponents: try .init(
                precision: .month,
                year: 2_024,
                month: 3
            ),
            archivedAt: isoDate("2026-03-08T12:00:00Z"),
            locale: enUS,
            calendar: calendar
        )

        #expect(result == "2 years")
    }

    @Test
    func archivedDurationText_formats_japanese_elapsed_value() throws {
        let result = EntryFormatting.archivedDurationText(
            startComponents: try .init(
                precision: .year,
                year: 2_020
            ),
            archivedAt: isoDate("2026-03-08T12:00:00Z"),
            locale: jaJP,
            calendar: calendar
        )

        #expect(result == "6年")
    }
}
