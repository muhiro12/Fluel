import Foundation
@testable import FluelLibrary
import Testing

struct EntryActivityTimelineSectionQueryTests {
    @Test
    func sections_group_activity_by_month_in_descending_order() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let updatedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .day,
                year: 2_024,
                month: 1,
                day: 8
            ),
            now: isoDate("2026-03-03T09:00:00Z"),
            calendar: calendar
        )
        let archivedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Desk lamp",
                precision: .month,
                year: 2_024,
                month: 5
            ),
            now: isoDate("2026-02-14T09:00:00Z"),
            calendar: calendar
        )
        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Notebook",
                precision: .month,
                year: 2_026,
                month: 2
            ),
            now: isoDate("2026-02-02T09:00:00Z"),
            calendar: calendar
        )

        try EntryRepository.update(
            context: context,
            entry: updatedEntry,
            input: makeInput(
                title: "Watch",
                precision: .day,
                year: 2_024,
                month: 1,
                day: 8,
                note: "Adjusted"
            ),
            now: isoDate("2026-03-05T10:00:00Z"),
            calendar: calendar
        )
        try EntryRepository.archive(
            context: context,
            entry: archivedEntry,
            now: isoDate("2026-02-20T10:00:00Z")
        )

        let sections = try EntryActivityTimelineSectionQuery.sections(
            context: context,
            locale: locale,
            calendar: calendar
        )

        #expect(sections.map(\.title) == ["March 2026", "February 2026"])
        #expect(sections[0].items.map(\.title) == ["Watch"])
        #expect(sections[1].items.map(\.title) == ["Desk lamp", "Notebook"])
        #expect(sections[1].items.map(\.kind) == [.archived, .added])
    }

    @Test
    func sections_apply_limit_to_recent_months() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "March item",
                precision: .month,
                year: 2_026,
                month: 3
            ),
            now: isoDate("2026-03-10T09:00:00Z"),
            calendar: calendar
        )
        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "February item",
                precision: .month,
                year: 2_026,
                month: 2
            ),
            now: isoDate("2026-02-10T09:00:00Z"),
            calendar: calendar
        )
        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "January item",
                precision: .month,
                year: 2_026,
                month: 1
            ),
            now: isoDate("2026-01-10T09:00:00Z"),
            calendar: calendar
        )

        let sections = try EntryActivityTimelineSectionQuery.sections(
            context: context,
            locale: locale,
            calendar: calendar,
            limit: 2
        )

        #expect(sections.count == 2)
        #expect(sections.map(\.title) == ["March 2026", "February 2026"])
    }
}
