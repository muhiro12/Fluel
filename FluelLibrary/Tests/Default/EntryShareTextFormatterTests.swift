import Foundation
@testable import FluelLibrary
import Testing

struct EntryShareTextFormatterTests {
    private let enUS: Locale = .init(identifier: "en_US_POSIX")
    private let jaJP: Locale = .init(identifier: "ja_JP")
    private let calendar: Calendar = .init(identifier: .gregorian)

    @Test
    func text_includes_active_entry_details_and_note() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 8,
                note: "Always in the same pocket."
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )

        let text = EntryShareTextFormatter.text(
            for: entry,
            referenceDate: isoDate("2026-03-08T12:00:00Z"),
            locale: enUS,
            calendar: calendar
        )

        #expect(text.contains("Wallet"))
        #expect(text.contains("Time together: 2 years"))
        #expect(text.contains("Started: Since"))
        #expect(text.contains("Known as: Exact day"))
        #expect(text.contains("Note: Always in the same pocket."))
    }

    @Test
    func text_includes_archived_metadata_in_japanese() throws {
        let context = try makeTestContext()
        let entry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "この家",
                precision: .year,
                year: 2_018
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )

        try EntryRepository.archive(
            context: context,
            entry: entry,
            now: isoDate("2026-03-09T12:00:00Z")
        )

        let text = EntryShareTextFormatter.text(
            for: entry,
            referenceDate: isoDate("2026-03-10T12:00:00Z"),
            locale: jaJP,
            calendar: calendar
        )

        #expect(text.contains("この家"))
        #expect(text.contains("重なってきた時間: 8年"))
        #expect(text.contains("始まり: 2018年から"))
        #expect(text.contains("分かる範囲: 年まで分かる"))
        #expect(text.contains("保管: "))
        #expect(text.contains("保管済み"))
    }
}
