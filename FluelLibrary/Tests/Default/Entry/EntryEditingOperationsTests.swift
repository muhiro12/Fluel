import Foundation
import Testing

import FluelLibrary

struct EntryEditingOperationsTests {
    @Test
    func operationsCreateDraftFromSnapshot() throws {
        let calendar = TestDateSupport.calendar
        let snapshot = EntrySnapshot(
            id: UUID(),
            title: "Notebook",
            start: TestDateSupport.start(
                year: 2_025,
                month: 5,
                precision: .month
            ),
            createdAt: TestDateSupport.date(year: 2_026, month: 1, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 2, day: 1),
            archivedAt: nil,
            note: "Ordinary thoughts",
            hasPhoto: true
        )

        let draft = try EntryOperations.makeDraft(
            from: snapshot,
            calendar: calendar
        )
        let expectedDayDate = try snapshot.start.date(in: calendar.timeZone)

        #expect(draft.title == snapshot.title)
        #expect(draft.note == snapshot.note)
        #expect(draft.precision == snapshot.start.precision)
        #expect(draft.dayDate == expectedDayDate)
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
            start: TestDateSupport.start(year: 2_024, precision: .year),
            createdAt: createdAt,
            updatedAt: archivedAt,
            archivedAt: archivedAt,
            note: "Old note",
            hasPhoto: true
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
        #expect(updatedSnapshot.start == TestDateSupport.start(
            year: 2_024,
            month: 6,
            precision: .month
        ))
    }

    @Test
    func draftRoundTripPreservesStartAcrossTimeZones() throws {
        let snapshot = makeSnapshot()
        let calendars = [
            TestDateSupport.calendar(timeZoneIdentifier: "Asia/Tokyo"),
            TestDateSupport.calendar(timeZoneIdentifier: "America/Los_Angeles")
        ]

        for calendar in calendars {
            let draft = try EntryOperations.makeDraft(
                from: snapshot,
                calendar: calendar
            )
            let roundTripStart = try draft.start(calendar: calendar)

            #expect(roundTripStart == snapshot.start)
        }
    }

    @Test
    func operationsRejectEmptyTitleWhenUpdatingSnapshot() {
        let calendar = TestDateSupport.calendar
        let snapshot = makeSnapshot()
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
        let snapshot = makeSnapshot()
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

    private func makeSnapshot() -> EntrySnapshot {
        EntrySnapshot(
            id: UUID(),
            title: "Desk lamp",
            start: TestDateSupport.start(year: 2_024, month: 1, day: 15),
            createdAt: TestDateSupport.date(year: 2_026, month: 5, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 5, day: 2),
            archivedAt: nil
        )
    }
}
