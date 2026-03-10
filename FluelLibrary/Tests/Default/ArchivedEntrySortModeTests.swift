@testable import FluelLibrary
import Foundation
import Testing

struct ArchivedEntrySortModeTests {
    private let calendar = Calendar(identifier: .gregorian)

    @Test
    func recentlyArchived_keeps_latest_archives_first() throws {
        let entries = try makeArchivedEntries()

        let result = EntryListOrdering.archived(
            entries,
            sortMode: .recentlyArchived,
            calendar: calendar
        )

        #expect(result.map(\.title) == ["This home", "Watch", "Bag"])
    }

    @Test
    func oldestArchived_brings_old_archives_forward() throws {
        let entries = try makeArchivedEntries()

        let result = EntryListOrdering.archived(
            entries,
            sortMode: .oldestArchived,
            calendar: calendar
        )

        #expect(result.map(\.title) == ["Bag", "Watch", "This home"])
    }

    @Test
    func longestTogether_orders_by_archive_duration() throws {
        let entries = try makeArchivedEntries()

        let result = EntryListOrdering.archived(
            entries,
            sortMode: .longestTogether,
            calendar: calendar
        )

        #expect(result.map(\.title) == ["This home", "Bag", "Watch"])
    }

    @Test
    func alphabetical_orders_titles_before_archive_date() throws {
        let entries = try makeArchivedEntries()

        let result = EntryListOrdering.archived(
            entries,
            sortMode: .alphabetical,
            calendar: calendar
        )

        #expect(result.map(\.title) == ["Bag", "This home", "Watch"])
    }

    private func makeArchivedEntries() throws -> [Entry] {
        let context = try makeTestContext()

        let home = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "This home",
                precision: .year,
                year: 2_018
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )
        let bag = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Bag",
                precision: .month,
                year: 2_022,
                month: 6
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )
        let watch = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .day,
                year: 2_024,
                month: 10,
                day: 11
            ),
            now: isoDate("2026-03-08T12:00:02Z"),
            calendar: calendar
        )

        try EntryRepository.archive(
            context: context,
            entry: home,
            now: isoDate("2026-03-11T12:00:00Z")
        )
        try EntryRepository.archive(
            context: context,
            entry: bag,
            now: isoDate("2026-03-09T12:00:00Z")
        )
        try EntryRepository.archive(
            context: context,
            entry: watch,
            now: isoDate("2026-03-10T12:00:00Z")
        )

        return [watch, bag, home]
    }
}
