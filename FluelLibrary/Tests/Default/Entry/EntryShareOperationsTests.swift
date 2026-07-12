import Foundation
import Testing

import FluelLibrary

struct EntryShareOperationsTests {
    @Test
    func entryShareSummaryIncludesCoreEntryContext() {
        let calendar = TestDateSupport.calendar
        let snapshot = EntrySnapshot(
            id: UUID(),
            title: "This home",
            start: TestDateSupport.start(year: 2_021, precision: .year),
            createdAt: TestDateSupport.date(year: 2_026, month: 1, day: 1),
            updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 6),
            archivedAt: TestDateSupport.date(year: 2_026, month: 6, day: 6),
            note: "First place together."
        )

        let summary = EntryOperations.entryShareSummary(
            for: snapshot,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        #expect(summary.subject == "Fluel: This home")
        #expect(summary.text.contains("Time together: 5 years"))
        #expect(summary.text.contains("Start: 2021"))
        #expect(summary.text.contains("Precision: Known to the year"))
        #expect(summary.text.contains("Approximate range:"))
        #expect(summary.text.contains("Note: First place together."))
        #expect(summary.text.contains("Status: Archived"))
    }

    @Test
    func timelineShareSummaryIncludesVisibleSliceContext() {
        let calendar = TestDateSupport.calendar
        let query = EntryTimelineQuery(
            searchText: "watch",
            filter: .all,
            scope: .recentYear,
            milestoneLimit: 2
        )
        let snapshots = [
            EntrySnapshot(
                id: UUID(),
                title: "Watch",
                start: TestDateSupport.start(year: 2_025, month: 7, day: 10),
                createdAt: TestDateSupport.date(year: 2_026, month: 6, day: 3),
                updatedAt: TestDateSupport.date(year: 2_026, month: 6, day: 3),
                archivedAt: nil
            )
        ]
        let result = EntryOperations.timeline(
            from: snapshots,
            activity: snapshots.map { snapshot in
                EntryOperations.addedActivity(for: snapshot)
            },
            query: query,
            referenceDate: TestDateSupport.date(year: 2_026, month: 6, day: 25),
            calendar: calendar
        )

        let summary = EntryOperations.timelineShareSummary(
            for: result,
            query: query,
            calendar: calendar
        )

        #expect(summary.subject == "Fluel Timeline")
        #expect(summary.text.contains("Scope: Recent year"))
        #expect(summary.text.contains("Activity: All activity"))
        #expect(summary.text.contains("Search: watch"))
        #expect(summary.text.contains("Visible activity: 1 of 1"))
        #expect(summary.text.contains("Monthly trends"))
        #expect(summary.text.contains("June 2026: 1 activity"))
        #expect(summary.text.contains("Upcoming milestones"))
        #expect(summary.text.contains("Watch: 1 year"))
    }
}
