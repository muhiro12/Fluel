import Foundation
import Testing

import FluelLibrary

struct EntryOperationsTests {
    @Test
    func operationsExposeTimeTogetherFromSnapshot() {
        let calendar = TestDateSupport.calendar
        let snapshot = EntrySnapshot(
            id: UUID(),
            title: "Desk",
            startDate: TestDateSupport.date(year: 2_024, month: 1, day: 1),
            startPrecision: .year,
            createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            archivedAt: nil,
            calendar: calendar
        )

        let summary = EntryOperations.timeTogether(
            for: snapshot,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(summary.primaryText == "2 years")
        #expect(!snapshot.isArchived)
    }

    @Test
    func archiveMarksActiveSnapshotAsArchived() {
        let calendar = TestDateSupport.calendar
        let snapshot = makeSnapshot(archivedAt: nil, calendar: calendar)
        let archivedAt = TestDateSupport.date(year: 2_026, month: 7, day: 1)

        let archivedSnapshot = EntryOperations.archive(
            snapshot,
            archivedAt: archivedAt,
            calendar: calendar
        )

        #expect(archivedSnapshot.isArchived)
        #expect(archivedSnapshot.archivedAt == archivedAt)
        #expect(archivedSnapshot.updatedAt == archivedAt)
        #expect(archivedSnapshot.id == snapshot.id)
        #expect(archivedSnapshot.title == snapshot.title)
        #expect(archivedSnapshot.startDate == snapshot.startDate)
    }

    @Test
    func archiveLeavesArchivedSnapshotUnchanged() {
        let calendar = TestDateSupport.calendar
        let originalArchiveDate = TestDateSupport.date(year: 2_026, month: 6, day: 1)
        let snapshot = makeSnapshot(archivedAt: originalArchiveDate, calendar: calendar)
        let laterArchiveDate = TestDateSupport.date(year: 2_026, month: 7, day: 1)

        let archivedSnapshot = EntryOperations.archive(
            snapshot,
            archivedAt: laterArchiveDate,
            calendar: calendar
        )

        #expect(archivedSnapshot == snapshot)
    }

    @Test
    func restoreMakesArchivedSnapshotActive() {
        let calendar = TestDateSupport.calendar
        let archivedAt = TestDateSupport.date(year: 2_026, month: 6, day: 1)
        let snapshot = makeSnapshot(archivedAt: archivedAt, calendar: calendar)
        let restoredAt = TestDateSupport.date(year: 2_026, month: 7, day: 1)

        let restoredSnapshot = EntryOperations.restore(
            snapshot,
            restoredAt: restoredAt,
            calendar: calendar
        )

        #expect(!restoredSnapshot.isArchived)
        #expect(restoredSnapshot.archivedAt == nil)
        #expect(restoredSnapshot.updatedAt == restoredAt)
        #expect(restoredSnapshot.id == snapshot.id)
        #expect(restoredSnapshot.title == snapshot.title)
    }

    @Test
    func restoreLeavesActiveSnapshotUnchanged() {
        let calendar = TestDateSupport.calendar
        let snapshot = makeSnapshot(archivedAt: nil, calendar: calendar)
        let restoredAt = TestDateSupport.date(year: 2_026, month: 7, day: 1)

        let restoredSnapshot = EntryOperations.restore(
            snapshot,
            restoredAt: restoredAt,
            calendar: calendar
        )

        #expect(restoredSnapshot == snapshot)
    }

    @Test
    func permanentDeleteBelongsOnlyToArchivedSnapshots() throws {
        let calendar = TestDateSupport.calendar
        let activeSnapshot = makeSnapshot(archivedAt: nil, calendar: calendar)
        let archivedSnapshot = makeSnapshot(
            archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
            calendar: calendar
        )

        #expect(!EntryOperations.canDeletePermanently(activeSnapshot))
        #expect(EntryOperations.canDeletePermanently(archivedSnapshot))
        #expect(throws: EntryArchiveError.activeEntryCannotBeDeleted) {
            try EntryOperations.validatePermanentDelete(for: activeSnapshot)
        }

        try EntryOperations.validatePermanentDelete(for: archivedSnapshot)
    }

    private func makeSnapshot(
        archivedAt: Date?,
        calendar: Calendar
    ) -> EntrySnapshot {
        EntrySnapshot(
            id: UUID(),
            title: "Desk lamp",
            startDate: TestDateSupport.date(year: 2_024, month: 1, day: 15),
            startPrecision: .day,
            createdAt: TestDateSupport.date(year: 2_026, month: 5, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 5, day: 2),
            archivedAt: archivedAt,
            calendar: calendar
        )
    }
}
