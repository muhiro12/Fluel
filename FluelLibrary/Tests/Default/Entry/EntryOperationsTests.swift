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
            start: TestDateSupport.start(year: 2_024, precision: .year),
            createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            archivedAt: nil
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
    func archivedTimeTogetherStopsAtArchiveDate() {
        let calendar = TestDateSupport.calendar
        let archivedAt = TestDateSupport.date(year: 2_026, month: 6, day: 10)
        let snapshot = makeTimeTogetherSnapshot(
            archivedAt: archivedAt
        )

        let summary = EntryOperations.timeTogether(
            for: snapshot,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 20),
            calendar: calendar
        )

        #expect(summary.primaryText == "9 days")
    }

    @Test
    func archivedTimeTogetherUsesEarlierReferenceDate() {
        let calendar = TestDateSupport.calendar
        let archivedAt = TestDateSupport.date(year: 2_026, month: 6, day: 10)
        let snapshot = makeTimeTogetherSnapshot(
            archivedAt: archivedAt
        )

        let summary = EntryOperations.timeTogether(
            for: snapshot,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 5),
            calendar: calendar
        )

        #expect(summary.primaryText == "4 days")
    }

    @Test
    func restoredTimeTogetherUsesReferenceDate() {
        let calendar = TestDateSupport.calendar
        let archivedSnapshot = makeTimeTogetherSnapshot(
            archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 10)
        )
        let restoredSnapshot = EntryOperations.restore(
            archivedSnapshot,
            restoredAt: TestDateSupport.date(year: 2_026, month: 6, day: 15)
        )

        let summary = EntryOperations.timeTogether(
            for: restoredSnapshot,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 20),
            calendar: calendar
        )

        #expect(summary.primaryText == "19 days")
    }

    @Test
    func archiveMarksActiveSnapshotAsArchived() {
        let snapshot = makeSnapshot(archivedAt: nil)
        let archivedAt = TestDateSupport.date(year: 2_026, month: 7, day: 1)

        let archivedSnapshot = EntryOperations.archive(
            snapshot,
            archivedAt: archivedAt
        )

        #expect(archivedSnapshot.isArchived)
        #expect(archivedSnapshot.archivedAt == archivedAt)
        #expect(archivedSnapshot.updatedAt == archivedAt)
        #expect(archivedSnapshot.id == snapshot.id)
        #expect(archivedSnapshot.title == snapshot.title)
        #expect(archivedSnapshot.start == snapshot.start)
    }

    @Test
    func archiveLeavesArchivedSnapshotUnchanged() {
        let originalArchiveDate = TestDateSupport.date(year: 2_026, month: 6, day: 1)
        let snapshot = makeSnapshot(archivedAt: originalArchiveDate)
        let laterArchiveDate = TestDateSupport.date(year: 2_026, month: 7, day: 1)

        let archivedSnapshot = EntryOperations.archive(
            snapshot,
            archivedAt: laterArchiveDate
        )

        #expect(archivedSnapshot == snapshot)
    }

    @Test
    func restoreMakesArchivedSnapshotActive() {
        let archivedAt = TestDateSupport.date(year: 2_026, month: 6, day: 1)
        let snapshot = makeSnapshot(archivedAt: archivedAt)
        let restoredAt = TestDateSupport.date(year: 2_026, month: 7, day: 1)

        let restoredSnapshot = EntryOperations.restore(
            snapshot,
            restoredAt: restoredAt
        )

        #expect(!restoredSnapshot.isArchived)
        #expect(restoredSnapshot.archivedAt == nil)
        #expect(restoredSnapshot.updatedAt == restoredAt)
        #expect(restoredSnapshot.id == snapshot.id)
        #expect(restoredSnapshot.title == snapshot.title)
    }

    @Test
    func restoreLeavesActiveSnapshotUnchanged() {
        let snapshot = makeSnapshot(archivedAt: nil)
        let restoredAt = TestDateSupport.date(year: 2_026, month: 7, day: 1)

        let restoredSnapshot = EntryOperations.restore(
            snapshot,
            restoredAt: restoredAt
        )

        #expect(restoredSnapshot == snapshot)
    }

    @Test
    func permanentDeleteBelongsOnlyToArchivedSnapshots() throws {
        let activeSnapshot = makeSnapshot(archivedAt: nil)
        let archivedSnapshot = makeSnapshot(
            archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 1)
        )

        #expect(!EntryOperations.canDeletePermanently(activeSnapshot))
        #expect(EntryOperations.canDeletePermanently(archivedSnapshot))
        #expect(throws: EntryArchiveError.activeEntryCannotBeDeleted) {
            try EntryOperations.validatePermanentDelete(for: activeSnapshot)
        }

        try EntryOperations.validatePermanentDelete(for: archivedSnapshot)
    }

    private func makeSnapshot(archivedAt: Date?) -> EntrySnapshot {
        EntrySnapshot(
            id: UUID(),
            title: "Desk lamp",
            start: TestDateSupport.start(year: 2_024, month: 1, day: 15),
            createdAt: TestDateSupport.date(year: 2_026, month: 5, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 5, day: 2),
            archivedAt: archivedAt
        )
    }

    private func makeTimeTogetherSnapshot(
        archivedAt: Date?
    ) -> EntrySnapshot {
        let startDate = TestDateSupport.date(year: 2_026, month: 6, day: 1)

        return .init(
            id: UUID(),
            title: "Desk lamp",
            start: TestDateSupport.start(year: 2_026, month: 6, day: 1),
            createdAt: startDate,
            updatedAt: archivedAt ?? startDate,
            archivedAt: archivedAt
        )
    }
}
