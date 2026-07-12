import Foundation
import Testing

import FluelLibrary

struct EntryActivityOperationsTests {
    @Test
    func activityFactoriesPreserveEventIdentityAndSnapshotContext() throws {
        let addedID = UUID()
        let updatedID = UUID()
        let archivedID = UUID()
        let createdSnapshot = snapshot(
            title: "Notebook",
            createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
            archivedAt: nil
        )
        let archivedSnapshot = EntryOperations.archive(
            createdSnapshot,
            archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 3)
        )

        let addedActivity = EntryOperations.addedActivity(
            for: createdSnapshot,
            id: addedID
        )
        let updatedActivity = EntryOperations.updatedActivity(
            for: archivedSnapshot,
            id: updatedID
        )
        let archivedActivity = try #require(EntryOperations.archivedActivity(
            for: archivedSnapshot,
            id: archivedID
        ))

        #expect(addedActivity.id == addedID)
        #expect(addedActivity.entryID == createdSnapshot.id)
        #expect(addedActivity.title == "Notebook")
        #expect(addedActivity.kind == .added)
        #expect(addedActivity.date == createdSnapshot.createdAt)
        #expect(updatedActivity.id == updatedID)
        #expect(updatedActivity.kind == .updated)
        #expect(updatedActivity.date == archivedSnapshot.updatedAt)
        #expect(archivedActivity.id == archivedID)
        #expect(archivedActivity.kind == .archived)
        #expect(archivedActivity.date == archivedSnapshot.archivedAt)
        #expect(EntryOperations.archivedActivity(for: createdSnapshot) == nil)
    }

    @Test
    func timelinePreservesMultipleUpdatesForOneEntry() {
        let calendar = TestDateSupport.calendar
        let entryID = UUID()
        let createdSnapshot = snapshot(
            title: "Notebook",
            createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
            archivedAt: nil,
            id: entryID
        )
        let firstUpdatedSnapshot = snapshot(
            title: "Daily notebook",
            createdAt: createdSnapshot.createdAt,
            updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 2),
            archivedAt: nil,
            id: entryID
        )
        let secondUpdatedSnapshot = snapshot(
            title: "Blue notebook",
            createdAt: createdSnapshot.createdAt,
            updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 3),
            archivedAt: nil,
            id: entryID
        )
        let activity = [
            EntryOperations.addedActivity(for: createdSnapshot),
            EntryOperations.updatedActivity(for: firstUpdatedSnapshot),
            EntryOperations.updatedActivity(for: secondUpdatedSnapshot)
        ]

        let result = EntryOperations.timeline(
            from: [secondUpdatedSnapshot],
            activity: activity,
            query: .init(scope: .allTime),
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(result.summary.totalActivityCount == 3)
        #expect(result.summary.updatedCount == 2)
        #expect(result.months.flatMap(\.activity).map(\.title) == [
            "Blue notebook",
            "Daily notebook",
            "Notebook"
        ])
        #expect(Set(activity.map(\.id)).count == 3)
    }

    @Test
    func timelinePreservesArchiveAfterEntryIsRestored() throws {
        let calendar = TestDateSupport.calendar
        let createdSnapshot = snapshot(
            title: "Desk lamp",
            createdAt: TestDateSupport.date(year: 2_026, month: 1, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 1, day: 1),
            archivedAt: nil
        )
        let archivedSnapshot = EntryOperations.archive(
            createdSnapshot,
            archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 2)
        )
        let restoredSnapshot = EntryOperations.restore(
            archivedSnapshot,
            restoredAt: TestDateSupport.date(year: 2_026, month: 6, day: 3)
        )
        let archivedActivity = try #require(EntryOperations.archivedActivity(
            for: archivedSnapshot
        ))
        let activity = [
            EntryOperations.addedActivity(for: createdSnapshot),
            archivedActivity,
            EntryOperations.updatedActivity(for: restoredSnapshot)
        ]

        let result = EntryOperations.timeline(
            from: [restoredSnapshot],
            activity: activity,
            query: .init(scope: .allTime),
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(restoredSnapshot.isArchived == false)
        #expect(result.summary.archivedCount == 1)
        #expect(result.summary.updatedCount == 1)
        #expect(result.months.flatMap(\.activity).map(\.kind) == [
            .updated,
            .archived,
            .added
        ])
    }

    private func snapshot(
        title: String,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date?,
        id: UUID = .init()
    ) -> EntrySnapshot {
        .init(
            id: id,
            title: title,
            start: TestDateSupport.start(year: 2_024, month: 1, day: 1),
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt
        )
    }
}
