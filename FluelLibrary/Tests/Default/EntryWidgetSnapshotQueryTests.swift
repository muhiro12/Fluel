import Foundation
@testable import FluelLibrary
import Testing

struct EntryWidgetSnapshotQueryTests {
    @Test
    func snapshot_ignores_archived_entries_and_returns_oldest_active() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let leadEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "This home",
                precision: .year,
                year: 2_018
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )
        let archivedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Old wallet",
                precision: .year,
                year: 2_010
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )

        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .month,
                year: 2_021,
                month: 11
            ),
            now: isoDate("2026-03-08T12:00:02Z"),
            calendar: calendar
        )

        try EntryRepository.archive(
            context: context,
            entry: archivedEntry,
            now: isoDate("2026-03-08T13:00:00Z")
        )

        let snapshot = try EntryWidgetSnapshotQuery.snapshot(
            context: context,
            referenceDate: isoDate("2026-03-08T12:00:00Z"),
            locale: locale,
            calendar: calendar
        )

        #expect(snapshot?.title == leadEntry.title)
        #expect(snapshot?.activeCount == 2)
        #expect(snapshot?.primaryText == "8 years")
    }
}
