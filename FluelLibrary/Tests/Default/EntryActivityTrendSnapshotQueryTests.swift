@testable import FluelLibrary
import Foundation
import Testing

struct EntryActivityTrendSnapshotQueryTests {
    @Test
    func recentMonths_groups_activity_and_counts_each_kind() {
        let snapshots = EntryActivityTrendSnapshotQuery.recentMonths(
            activity: sampleActivity(),
            locale: Locale(identifier: "en_US"),
            calendar: Calendar(identifier: .gregorian),
            limit: 3
        )

        #expect(snapshots.count == 3)
        #expect(snapshots[0].totalCount == 2)
        #expect(snapshots[0].addedCount == 1)
        #expect(snapshots[0].updatedCount == 1)
        #expect(snapshots[0].archivedCount == 0)
        #expect(snapshots[1].totalCount == 2)
        #expect(snapshots[1].archivedCount == 1)
    }

    @Test
    func recentMonths_orders_latest_month_first_and_applies_limit() {
        let snapshots = EntryActivityTrendSnapshotQuery.recentMonths(
            activity: sampleActivity(),
            locale: Locale(identifier: "ja_JP"),
            calendar: Calendar(identifier: .gregorian),
            limit: 2
        )

        #expect(snapshots.count == 2)
        #expect(snapshots.map(\.title) == ["2026年3月", "2026年2月"])
    }
}

private extension EntryActivityTrendSnapshotQueryTests {
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
                kind: .updated,
                timestamp: isoDate("2026-02-05T09:00:00Z")
            ),
            .init(
                entryID: UUID(),
                title: "Notebook",
                kind: .added,
                timestamp: isoDate("2026-01-10T09:00:00Z")
            )
        ]
    }
}
