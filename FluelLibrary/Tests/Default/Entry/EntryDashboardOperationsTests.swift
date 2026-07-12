import Foundation
import Testing

import FluelLibrary

struct EntryDashboardOperationsTests {
    private struct Values {
        let title: String
        let note: String?
        let hasPhoto: Bool
        let startYear: Int
        let startMonth: Int
        let startDay: Int
        let precision: StartPrecision
        let createdDay: Int
        let updatedDay: Int
        let archivedDay: Int?
    }

    private var fixtures: [Values] {
        [
            .init(
                title: "This home",
                note: "A home is where daily life gathers.",
                hasPhoto: false,
                startYear: 2_021,
                startMonth: 4,
                startDay: 1,
                precision: .year,
                createdDay: 1,
                updatedDay: 2,
                archivedDay: nil
            ),
            .init(
                title: "Watch",
                note: nil,
                hasPhoto: true,
                startYear: 2_025,
                startMonth: 7,
                startDay: 10,
                precision: .day,
                createdDay: 3,
                updatedDay: 3,
                archivedDay: nil
            ),
            .init(
                title: "Desk lamp",
                note: "Moved to storage.",
                hasPhoto: false,
                startYear: 2_023,
                startMonth: 2,
                startDay: 14,
                precision: .day,
                createdDay: 4,
                updatedDay: 6,
                archivedDay: 6
            )
        ]
    }

    @Test
    func dashboardSummaryCountsEntriesAndHighlights() {
        let calendar = TestDateSupport.calendar
        let summary = EntryOperations.dashboardSummary(
            from: snapshots(calendar: calendar),
            activity: [],
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(summary.totalCount == 3)
        #expect(summary.activeCount == 2)
        #expect(summary.archivedCount == 1)
        #expect(summary.noteCount == 2)
        #expect(summary.photoCount == 1)
        #expect(summary.longestRunningActiveEntry?.title == "This home")
        #expect(summary.recentlyArchivedEntry?.title == "Desk lamp")
        #expect(summary.recentActivity.isEmpty)
    }

    @Test
    func dashboardSummaryIncludesUpcomingMilestones() {
        let calendar = TestDateSupport.calendar
        let summary = EntryOperations.dashboardSummary(
            from: snapshots(calendar: calendar),
            activity: [],
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar,
            milestoneLimit: 2
        )

        #expect(summary.upcomingMilestones.map(\.title) == ["Watch", "This home"])
        #expect(summary.upcomingMilestones.first?.durationYears == 1)
        #expect(summary.upcomingMilestones.first?.daysRemaining == 15)
        #expect(summary.upcomingMilestones.last?.isApproximate == true)
    }

    @Test
    func dashboardSummaryIncludesRecentActivity() throws {
        let calendar = TestDateSupport.calendar
        let snapshots = snapshots(calendar: calendar)
        let archivedActivity = try #require(EntryOperations.archivedActivity(
            for: snapshots[2]
        ))
        let activity = [
            EntryOperations.updatedActivity(for: snapshots[0]),
            EntryOperations.addedActivity(for: snapshots[1]),
            archivedActivity
        ]
        let summary = EntryOperations.dashboardSummary(
            from: snapshots,
            activity: activity,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar,
            activityLimit: 3
        )

        #expect(summary.recentActivity.map(\.title) == ["Desk lamp", "Watch", "This home"])
        #expect(summary.recentActivity.map(\.kind) == [.archived, .added, .updated])
    }

    private func snapshots(calendar: Calendar) -> [EntrySnapshot] {
        fixtures.map { values in
            EntrySnapshot(
                id: UUID(),
                title: values.title,
                startDate: TestDateSupport.date(
                    year: values.startYear,
                    month: values.startMonth,
                    day: values.startDay
                ),
                startPrecision: values.precision,
                createdAt: activityDate(day: values.createdDay),
                updatedAt: activityDate(day: values.updatedDay),
                archivedAt: values.archivedDay.map(activityDate(day:)),
                note: values.note,
                hasPhoto: values.hasPhoto,
                calendar: calendar
            )
        }
    }

    private func activityDate(day: Int) -> Date {
        TestDateSupport.date(year: 2_026, month: 6, day: day)
    }
}
