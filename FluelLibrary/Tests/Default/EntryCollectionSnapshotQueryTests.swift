import Foundation
@testable import FluelLibrary
import Testing

struct EntryCollectionSnapshotQueryTests {
    @Test
    func snapshot_returns_counts_and_lead_active_highlight() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = isoDate("2026-03-08T12:00:00Z")
        let photoData = Data([0x01, 0x02, 0x03])

        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "This home",
                precision: .year,
                year: 2_018,
                note: "A quiet place"
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )
        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .month,
                year: 2_023,
                month: 6,
                photoData: photoData
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )
        let archivedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Desk lamp",
                precision: .day,
                year: 2_024,
                month: 7,
                day: 9,
                photoData: photoData,
                note: "Moved to storage"
            ),
            now: isoDate("2026-03-08T12:00:02Z"),
            calendar: calendar
        )

        try EntryRepository.archive(
            context: context,
            entry: archivedEntry,
            now: isoDate("2026-03-08T13:00:00Z")
        )

        let snapshot = try EntryCollectionSnapshotQuery.snapshot(
            context: context,
            referenceDate: referenceDate,
            calendar: calendar
        )

        #expect(snapshot.totalCount == 3)
        #expect(snapshot.activeCount == 2)
        #expect(snapshot.archivedCount == 1)
        #expect(snapshot.activeWithNotesCount == 1)
        #expect(snapshot.activeWithPhotosCount == 1)
        #expect(snapshot.archivedWithNotesCount == 1)
        #expect(snapshot.archivedWithPhotosCount == 1)
        #expect(snapshot.leadActiveTitle == "This home")
        #expect(snapshot.leadActiveStartComponents?.precision == .year)
        #expect(snapshot.leadActiveElapsedSnapshot?.years == 8)
        #expect(snapshot.mostRecentlyArchivedTitle == "Desk lamp")
    }

    @Test
    func snapshot_returns_empty_counts_when_no_entries_exist() throws {
        let context = try makeTestContext()

        let snapshot = try EntryCollectionSnapshotQuery.snapshot(
            context: context
        )

        #expect(snapshot.totalCount == 0)
        #expect(snapshot.activeCount == 0)
        #expect(snapshot.archivedCount == 0)
        #expect(snapshot.activeWithNotesCount == 0)
        #expect(snapshot.activeWithPhotosCount == 0)
        #expect(snapshot.archivedWithNotesCount == 0)
        #expect(snapshot.archivedWithPhotosCount == 0)
        #expect(snapshot.leadActiveTitle == nil)
        #expect(snapshot.leadActiveStartComponents == nil)
        #expect(snapshot.leadActiveElapsedSnapshot == nil)
        #expect(snapshot.mostRecentlyArchivedTitle == nil)
    }
}
