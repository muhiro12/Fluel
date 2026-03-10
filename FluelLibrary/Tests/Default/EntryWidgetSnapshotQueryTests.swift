@testable import FluelLibrary
import Foundation
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
                year: 2_018,
                note: "Still here"
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
                month: 11,
                photoData: Data([0x01])
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
        #expect(snapshot?.archivedCount == 1)
        #expect(snapshot?.activeWithNotesCount == 1)
        #expect(snapshot?.activeWithPhotosCount == 1)
        #expect(snapshot?.mostRecentlyArchivedTitle == archivedEntry.title)
        #expect(snapshot?.primaryText == "8 years")
    }

    @Test
    func snapshot_includes_upcoming_milestone_and_recent_activity() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let leadEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 10
            ),
            now: isoDate("2026-03-08T09:00:00Z"),
            calendar: calendar
        )
        let notebook = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Notebook",
                precision: .month,
                year: 2_025,
                month: 4
            ),
            now: isoDate("2026-03-08T09:00:01Z"),
            calendar: calendar
        )

        try EntryRepository.update(
            context: context,
            entry: notebook,
            input: makeInput(
                title: "Notebook",
                precision: .month,
                year: 2_025,
                month: 4,
                note: "Updated note"
            ),
            now: isoDate("2026-03-08T11:00:00Z"),
            calendar: calendar
        )

        let snapshot = try EntryWidgetSnapshotQuery.snapshot(
            context: context,
            referenceDate: isoDate("2026-03-08T12:00:00Z"),
            locale: locale,
            calendar: calendar
        )

        #expect(snapshot?.title == leadEntry.title)
        #expect(snapshot?.upcomingMilestone?.title == leadEntry.title)
        #expect(snapshot?.upcomingMilestone?.daysRemaining == 2)
        #expect(snapshot?.upcomingMilestone?.milestoneText == "2 years")
        #expect(snapshot?.recentActivity?.title == notebook.title)
        #expect(snapshot?.recentActivity?.kind == .updated)
        #expect(snapshot?.recentActivity?.timestamp == isoDate("2026-03-08T11:00:00Z"))
    }
}
