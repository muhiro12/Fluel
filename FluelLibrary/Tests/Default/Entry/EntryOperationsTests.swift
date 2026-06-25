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
}
