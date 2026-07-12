import Foundation
import Testing

import FluelLibrary

struct EntryEditingOperationsTests {
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
        let snapshot = makeSnapshot(calendar: calendar)
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
        let snapshot = makeSnapshot(calendar: calendar)
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

    private func makeSnapshot(calendar: Calendar) -> EntrySnapshot {
        EntrySnapshot(
            id: UUID(),
            title: "Desk lamp",
            startDate: TestDateSupport.date(year: 2_024, month: 1, day: 15),
            startPrecision: .day,
            createdAt: TestDateSupport.date(year: 2_026, month: 5, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 5, day: 2),
            archivedAt: nil,
            calendar: calendar
        )
    }
}
