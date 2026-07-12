import Foundation
import Testing

import FluelLibrary

struct EntryTimelineOperationsTests {
    private struct Values {
        let title: String
        let startYear: Int
        let startMonth: Int
        let startDay: Int
        let precision: StartPrecision
        let createdAt: Date
        let updatedAt: Date
        let archivedAt: Date?
    }

    private var fixtures: [Values] {
        [
            .init(
                title: "This home",
                startYear: 2_021,
                startMonth: 1,
                startDay: 1,
                precision: .year,
                createdAt: TestDateSupport.date(year: 2_026, month: 1, day: 1),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 2),
                archivedAt: nil
            ),
            .init(
                title: "Watch",
                startYear: 2_025,
                startMonth: 7,
                startDay: 10,
                precision: .day,
                createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 3),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 3),
                archivedAt: nil
            ),
            .init(
                title: "Desk lamp",
                startYear: 2_023,
                startMonth: 2,
                startDay: 14,
                precision: .day,
                createdAt: TestDateSupport.date(year: 2_026, month: 3, day: 4),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 6),
                archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 6)
            )
        ]
    }

    @Test
    func timelineGroupsActivityByMonthAndSummarizesVisibleSlice() {
        let calendar = TestDateSupport.calendar
        let snapshots = snapshots()
        let result = EntryOperations.timeline(
            from: snapshots,
            activity: activity(from: snapshots),
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(result.summary.totalActivityCount == 5)
        #expect(result.summary.visibleActivityCount == 5)
        #expect(result.summary.representedMonthCount == 3)
        #expect(result.summary.addedCount == 3)
        #expect(result.summary.updatedCount == 1)
        #expect(result.summary.archivedCount == 1)
        #expect(result.months.map(\.activity.count) == [3, 1, 1])
    }

    @Test
    func timelineAppliesSearchFilterScopeAndVisibleMilestones() {
        let calendar = TestDateSupport.calendar
        let snapshots = snapshots()
        let query = EntryTimelineQuery(
            searchText: "watch",
            filter: .all,
            scope: .recentYear,
            milestoneLimit: 2
        )

        let result = EntryOperations.timeline(
            from: snapshots,
            activity: activity(from: snapshots),
            query: query,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(result.summary.visibleActivityCount == 1)
        #expect(result.months.first?.activity.first?.title == "Watch")
        #expect(result.upcomingMilestones.map(\.title) == ["Watch"])
    }

    @Test
    func timelineFiltersArchivedActivityWithoutActiveMilestones() {
        let calendar = TestDateSupport.calendar
        let snapshots = snapshots()
        let query = EntryTimelineQuery(filter: .archived, scope: .recentYear)

        let result = EntryOperations.timeline(
            from: snapshots,
            activity: activity(from: snapshots),
            query: query,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(result.summary.visibleActivityCount == 1)
        #expect(result.summary.archivedCount == 1)
        #expect(result.months.first?.activity.first?.kind == .archived)
        #expect(result.upcomingMilestones.isEmpty)
    }

    @Test
    func timelineDoesNotSynthesizeMissingActivityFromSnapshots() {
        let calendar = TestDateSupport.calendar
        let snapshots = snapshots()

        let result = EntryOperations.timeline(
            from: snapshots,
            activity: [],
            query: .init(scope: .allTime),
            calendar: calendar
        )

        #expect(result.summary.totalActivityCount == 0)
        #expect(result.months.isEmpty)
        #expect(result.upcomingMilestones.isEmpty)
    }

    private func snapshots() -> [EntrySnapshot] {
        fixtures.map { values in
            EntrySnapshot(
                id: UUID(),
                title: values.title,
                start: TestDateSupport.start(
                    year: values.startYear,
                    month: values.startMonth,
                    day: values.startDay,
                    precision: values.precision
                ),
                createdAt: values.createdAt,
                updatedAt: values.updatedAt,
                archivedAt: values.archivedAt
            )
        }
    }

    private func activity(
        from snapshots: [EntrySnapshot]
    ) -> [EntryActivitySummary] {
        snapshots.flatMap { snapshot in
            var activity = [EntryOperations.addedActivity(for: snapshot)]

            if snapshot.updatedAt != snapshot.createdAt,
               snapshot.updatedAt != snapshot.archivedAt {
                activity.append(EntryOperations.updatedActivity(for: snapshot))
            }

            if let archivedActivity = EntryOperations.archivedActivity(for: snapshot) {
                activity.append(archivedActivity)
            }

            return activity
        }
    }
}
