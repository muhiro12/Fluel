import Foundation
import Testing

import FluelLibrary

struct EntryOperationsTests {
    @Test
    func operationsCreateDraftFromSnapshot() {
        let calendar = TestDateSupport.calendar
        let snapshot = EntrySnapshot(
            id: UUID(),
            title: "Notebook",
            startDate: TestDateSupport.date(year: 2_025, month: 5, day: 1),
            startPrecision: .month,
            createdAt: TestDateSupport.date(year: 2_026, month: 1, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 2, day: 1),
            archivedAt: nil,
            note: "Ordinary thoughts",
            hasPhoto: true,
            calendar: calendar
        )

        let draft = EntryOperations.makeDraft(
            from: snapshot,
            calendar: calendar
        )

        #expect(draft.title == snapshot.title)
        #expect(draft.note == snapshot.note)
        #expect(draft.precision == snapshot.startPrecision)
        #expect(draft.dayDate == snapshot.startDate)
        #expect(draft.month == 5)
        #expect(draft.year == 2_025)
    }

    @Test
    func operationsUpdateSnapshotFromValidatedDraft() throws {
        let calendar = TestDateSupport.calendar
        let identifier = UUID()
        let createdAt = TestDateSupport.date(year: 2_025, month: 1, day: 1)
        let archivedAt = TestDateSupport.date(year: 2_026, month: 5, day: 1)
        let updatedAt = TestDateSupport.date(year: 2_026, month: 6, day: 25)
        let snapshot = EntrySnapshot(
            id: identifier,
            title: "Notebook",
            startDate: TestDateSupport.date(year: 2_024, month: 1, day: 1),
            startPrecision: .year,
            createdAt: createdAt,
            updatedAt: archivedAt,
            archivedAt: archivedAt,
            note: "Old note",
            hasPhoto: true,
            calendar: calendar
        )
        let draft = EntryDraft(
            title: "  Daily notebook  ",
            note: "   ",
            precision: .month,
            month: 6,
            year: 2_024,
            calendar: calendar
        )

        let updatedSnapshot = try EntryOperations.update(
            snapshot,
            from: draft,
            updatedAt: updatedAt,
            calendar: calendar
        )

        #expect(updatedSnapshot.id == identifier)
        #expect(updatedSnapshot.createdAt == createdAt)
        #expect(updatedSnapshot.archivedAt == archivedAt)
        #expect(updatedSnapshot.hasPhoto)
        #expect(updatedSnapshot.updatedAt == updatedAt)
        #expect(updatedSnapshot.title == "Daily notebook")
        #expect(updatedSnapshot.note == nil)
        #expect(updatedSnapshot.startDate == TestDateSupport.date(year: 2_024, month: 6, day: 1))
        #expect(updatedSnapshot.startPrecision == .month)
    }

    @Test
    func operationsRejectEmptyTitleWhenUpdatingSnapshot() {
        let calendar = TestDateSupport.calendar
        let snapshot = makeSnapshot(archivedAt: nil, calendar: calendar)
        let draft = EntryDraft(
            title: "   ",
            precision: .day,
            dayDate: TestDateSupport.date(year: 2_026, month: 6, day: 1),
            calendar: calendar
        )

        #expect(throws: EntryValidationError.emptyTitle) {
            try EntryOperations.update(
                snapshot,
                from: draft,
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 25),
                calendar: calendar
            )
        }
    }

    @Test
    func operationsRejectFutureStartWhenUpdatingSnapshot() {
        let calendar = TestDateSupport.calendar
        let snapshot = makeSnapshot(archivedAt: nil, calendar: calendar)
        let draft = EntryDraft(
            title: "Desk lamp",
            precision: .day,
            dayDate: TestDateSupport.date(year: 2_026, month: 6, day: 26),
            calendar: calendar
        )

        #expect(throws: EntryValidationError.futureStart) {
            try EntryOperations.update(
                snapshot,
                from: draft,
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 25),
                calendar: calendar
            )
        }
    }

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
    func archivedTimeTogetherStopsAtArchiveDate() {
        let calendar = TestDateSupport.calendar
        let archivedAt = TestDateSupport.date(year: 2_026, month: 6, day: 10)
        let snapshot = makeTimeTogetherSnapshot(
            archivedAt: archivedAt,
            calendar: calendar
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
            archivedAt: archivedAt,
            calendar: calendar
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
            archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 10),
            calendar: calendar
        )
        let restoredSnapshot = EntryOperations.restore(
            archivedSnapshot,
            restoredAt: TestDateSupport.date(year: 2_026, month: 6, day: 15),
            calendar: calendar
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

    private func makeTimeTogetherSnapshot(
        archivedAt: Date?,
        calendar: Calendar
    ) -> EntrySnapshot {
        let startDate = TestDateSupport.date(year: 2_026, month: 6, day: 1)

        return .init(
            id: UUID(),
            title: "Desk lamp",
            startDate: startDate,
            startPrecision: .day,
            createdAt: startDate,
            updatedAt: archivedAt ?? startDate,
            archivedAt: archivedAt,
            calendar: calendar
        )
    }
}
