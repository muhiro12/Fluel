import Foundation
import Testing

import FluelLibrary

struct EntryMilestoneOperationsTests {
    @Test
    func upcomingMilestonesAreOrderedByNearestDate() {
        let calendar = TestDateSupport.calendar
        let milestones = EntryOperations.upcomingMilestones(
            from: snapshots(),
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
            from: snapshots(),
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(!milestones.map(\.title).contains("Desk lamp"))
    }

    @Test
    func milestonesRemainStableAcrossTimeZones() {
        let tokyo = TestDateSupport.calendar(timeZoneIdentifier: "Asia/Tokyo")
        let losAngeles = TestDateSupport.calendar(
            timeZoneIdentifier: "America/Los_Angeles"
        )
        let tokyoMilestones = EntryOperations.upcomingMilestones(
            from: snapshots(),
            referenceDate: TestDateSupport.date(
                year: 2_026,
                month: 6,
                day: 25,
                calendar: tokyo
            ),
            calendar: tokyo
        )
        let losAngelesMilestones = EntryOperations.upcomingMilestones(
            from: snapshots(),
            referenceDate: TestDateSupport.date(
                year: 2_026,
                month: 6,
                day: 25,
                calendar: losAngeles
            ),
            calendar: losAngeles
        )

        #expect(tokyoMilestones.map(\.date) == losAngelesMilestones.map(\.date))
        #expect(tokyoMilestones.map(\.daysRemaining) == losAngelesMilestones.map(\.daysRemaining))
    }

    private func snapshots() -> [EntrySnapshot] {
        [
            EntrySnapshot(
                id: UUID(),
                title: "This home",
                start: TestDateSupport.start(year: 2_021, precision: .year),
                createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 1),
                archivedAt: nil
            ),
            EntrySnapshot(
                id: UUID(),
                title: "Watch",
                start: TestDateSupport.start(year: 2_025, month: 7, day: 10),
                createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 2),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 2),
                archivedAt: nil
            ),
            EntrySnapshot(
                id: UUID(),
                title: "Desk lamp",
                start: TestDateSupport.start(year: 2_023, month: 2, day: 14),
                createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 3),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 4),
                archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 4)
            )
        ]
    }
}
