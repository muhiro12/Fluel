import Foundation
@testable import FluelLibrary
import Testing

struct EntryActivitySnapshotQueryTests {
    @Test
    func recent_orders_archived_updated_and_added_events_by_timestamp() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)

        let updatedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 8
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )
        let addedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Plant",
                precision: .month,
                year: 2_025,
                month: 11
            ),
            now: isoDate("2026-03-08T12:05:00Z"),
            calendar: calendar
        )
        let archivedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Desk lamp",
                precision: .year,
                year: 2_020
            ),
            now: isoDate("2026-03-08T12:10:00Z"),
            calendar: calendar
        )

        try EntryRepository.update(
            context: context,
            entry: updatedEntry,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 8,
                note: "Adjusted"
            ),
            now: isoDate("2026-03-08T12:20:00Z"),
            calendar: calendar
        )
        try EntryRepository.archive(
            context: context,
            entry: archivedEntry,
            now: isoDate("2026-03-08T12:30:00Z")
        )

        let activity = try EntryActivitySnapshotQuery.recent(
            context: context,
            limit: 5
        )

        #expect(activity.map(\.title) == ["Desk lamp", "Wallet", "Plant"])
        #expect(activity.map(\.kind) == [.archived, .updated, .added])
    }

    @Test
    func recent_applies_limit() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)

        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "A",
                precision: .year,
                year: 2_024
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )
        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "B",
                precision: .year,
                year: 2_025
            ),
            now: isoDate("2026-03-08T12:01:00Z"),
            calendar: calendar
        )

        let activity = try EntryActivitySnapshotQuery.recent(
            context: context,
            limit: 1
        )

        #expect(activity.count == 1)
        #expect(activity.first?.title == "B")
    }
}
