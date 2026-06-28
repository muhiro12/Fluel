import Foundation
import Testing

import FluelLibrary

struct EntryMilestoneOperationsTests {
    @Test
    func upcomingMilestonesAreOrderedByNearestDate() {
        let calendar = TestDateSupport.calendar
        let milestones = EntryOperations.upcomingMilestones(
            from: snapshots(calendar: calendar),
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(milestones.map(\.title) == ["Watch", "This home"])
        #expect(milestones.map(\.durationYears) == [1, 6])
        #expect(milestones.first?.daysRemaining == 15)
        #expect(milestones.last?.isApproximate == true)
    }

    @Test
    func upcomingMilestonesIgnoreArchivedEntries() {
        let calendar = TestDateSupport.calendar
        let milestones = EntryOperations.upcomingMilestones(
            from: snapshots(calendar: calendar),
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(!milestones.map(\.title).contains("Desk lamp"))
    }

    private func snapshots(calendar: Calendar) -> [EntrySnapshot] {
        [
            EntrySnapshot(
                id: UUID(),
                title: "This home",
                startDate: TestDateSupport.date(year: 2_021, month: 1, day: 1),
                startPrecision: .year,
                createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
                archivedAt: nil,
                calendar: calendar
            ),
            EntrySnapshot(
                id: UUID(),
                title: "Watch",
                startDate: TestDateSupport.date(year: 2_025, month: 7, day: 10),
                startPrecision: .day,
                createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 2),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 2),
                archivedAt: nil,
                calendar: calendar
            ),
            EntrySnapshot(
                id: UUID(),
                title: "Desk lamp",
                startDate: TestDateSupport.date(year: 2_023, month: 2, day: 14),
                startPrecision: .day,
                createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 3),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 4),
                archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 4),
                calendar: calendar
            )
        ]
    }
}
