import Foundation
@testable import FluelLibrary
import Testing

struct EntryActivityTimelineSummaryQueryTests {
    @Test
    func summary_counts_visible_activity_by_kind_and_month() {
        let summary = EntryActivityTimelineSummaryQuery.summary(
            totalActivity: sampleActivity(),
            displayedActivity: [
                sampleActivity()[0],
                sampleActivity()[1],
                sampleActivity()[2],
            ],
            calendar: Calendar(identifier: .gregorian)
        )

        #expect(summary.totalCount == 4)
        #expect(summary.displayedCount == 3)
        #expect(summary.monthCount == 2)
        #expect(summary.addedCount == 1)
        #expect(summary.updatedCount == 1)
        #expect(summary.archivedCount == 1)
    }

    @Test
    func summary_returns_zero_months_for_empty_visible_activity() {
        let summary = EntryActivityTimelineSummaryQuery.summary(
            totalActivity: sampleActivity(),
            displayedActivity: [],
            calendar: Calendar(identifier: .gregorian)
        )

        #expect(summary.totalCount == 4)
        #expect(summary.displayedCount == 0)
        #expect(summary.monthCount == 0)
    }
}

private extension EntryActivityTimelineSummaryQueryTests {
    func sampleActivity() -> [EntryActivitySnapshot] {
        [
            .init(
                entryID: UUID(),
                title: "Wallet",
                kind: .added,
                timestamp: isoDate("2026-03-08T12:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Plant",
                kind: .updated,
                timestamp: isoDate("2026-03-01T10:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Desk lamp",
                kind: .archived,
                timestamp: isoDate("2026-02-10T09:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Shoes",
                kind: .added,
                timestamp: isoDate("2025-11-10T09:00:00Z")
            ),
        ]
    }
}
