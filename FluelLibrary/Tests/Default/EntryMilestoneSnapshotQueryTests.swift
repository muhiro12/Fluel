@testable import FluelLibrary
import Foundation
import Testing

struct EntryMilestoneSnapshotQueryTests {
    @Test
    func upcomingActiveMilestones_orders_by_nearest_yearly_milestone() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let referenceDate = isoDate("2026-03-08T12:00:00Z")

        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Wallet",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 20
            ),
            now: referenceDate,
            calendar: calendar
        )
        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Watch",
                precision: .month,
                year: 2_023,
                month: 6
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )
        let archivedEntry = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "Desk lamp",
                precision: .year,
                year: 2_020
            ),
            now: isoDate("2026-03-08T12:00:02Z"),
            calendar: calendar
        )

        try EntryRepository.archive(
            context: context,
            entry: archivedEntry,
            now: isoDate("2026-03-08T12:30:00Z")
        )

        let milestones = try EntryMilestoneSnapshotQuery.upcomingActiveMilestones(
            context: context,
            referenceDate: referenceDate,
            locale: locale,
            calendar: calendar,
            limit: 5
        )

        #expect(milestones.map(\.title) == ["Wallet", "Watch"])
        #expect(milestones[0].daysRemaining == 12)
        #expect(milestones[0].milestoneText == "2 years")
        #expect(milestones[0].isApproximate == false)
        #expect(milestones[1].milestoneText == "3 years")
        #expect(milestones[1].isApproximate)
    }

    @Test
    func upcomingActiveMilestones_applies_limit() throws {
        let context = try makeTestContext()
        let calendar = Calendar(identifier: .gregorian)

        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "A",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 9
            ),
            now: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar
        )
        _ = try EntryRepository.create(
            context: context,
            input: makeInput(
                title: "B",
                precision: .day,
                year: 2_024,
                month: 3,
                day: 10
            ),
            now: isoDate("2026-03-08T12:00:01Z"),
            calendar: calendar
        )

        let milestones = try EntryMilestoneSnapshotQuery.upcomingActiveMilestones(
            context: context,
            referenceDate: isoDate("2026-03-08T12:00:00Z"),
            calendar: calendar,
            limit: 1
        )

        #expect(milestones.count == 1)
        #expect(milestones.first?.title == "A")
    }
}
