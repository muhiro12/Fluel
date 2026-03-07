import Foundation
@testable import FluelLibrary
import Testing

struct ActiveEntrySortModeTests {
    private let calendar = Calendar(identifier: .gregorian)

    @Test
    func oldestFirst_keeps_longest_together_first() throws {
        let entries = try makeEntries()

        let result = EntryListOrdering.active(
            entries,
            sortMode: .oldestFirst,
            calendar: calendar
        )

        #expect(result.map(\.title) == ["This home", "Watch", "Bag"])
    }

    @Test
    func newestFirst_brings_recent_entries_forward() throws {
        let entries = try makeEntries()

        let result = EntryListOrdering.active(
            entries,
            sortMode: .newestFirst,
            calendar: calendar
        )

        #expect(result.map(\.title) == ["Bag", "Watch", "This home"])
    }

    @Test
    func alphabetical_orders_by_title_before_date() throws {
        let entries = try makeEntries()

        let result = EntryListOrdering.active(
            entries,
            sortMode: .alphabetical,
            calendar: calendar
        )

        #expect(result.map(\.title) == ["Bag", "This home", "Watch"])
    }

    private func makeEntries() throws -> [Entry] {
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
        let watch = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .month,
                year: 2_022,
                month: 11
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )
        let bag = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Bag",
                precision: .day,
                year: 2_025,
                month: 9,
                day: 5
            ),
            now: isoDate("2026-03-08T12:00:02Z"),
            calendar: calendar
        )

        return [bag, home, watch]
    }
}
