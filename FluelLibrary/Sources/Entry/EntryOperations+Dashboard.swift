import Foundation

public extension EntryOperations {
    /// Returns collection overview values for the Dashboard.
    static func dashboardSummary(
        from snapshots: [EntrySnapshot],
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent,
        milestoneLimit: Int = 3,
        activityLimit: Int = 3
    ) -> EntryDashboardSummary {
        let activeSnapshots = snapshots.filter { snapshot in
            !snapshot.isArchived
        }
        let archivedSnapshots = snapshots.filter(\.isArchived)

        return .init(
            totalCount: snapshots.count,
            activeCount: activeSnapshots.count,
            archivedCount: archivedSnapshots.count,
            noteCount: snapshots.filter(\.hasNote).count,
            photoCount: snapshots.filter(\.hasPhoto).count,
            longestRunningActiveEntry: longestRunningEntry(from: activeSnapshots),
            recentlyArchivedEntry: recentlyArchivedEntry(from: archivedSnapshots),
            upcomingMilestones: upcomingMilestones(
                from: activeSnapshots,
                referenceDate: referenceDate,
                calendar: calendar,
                limit: milestoneLimit
            ),
            recentActivity: recentActivity(from: snapshots, limit: activityLimit)
        )
    }

    private static func longestRunningEntry(
        from snapshots: [EntrySnapshot]
    ) -> EntrySnapshot? {
        snapshots.min { lhs, rhs in
            compare(lhs.startDate, rhs.startDate, tieBreak: titlePrecedes(lhs, rhs))
        }
    }

    private static func recentlyArchivedEntry(
        from snapshots: [EntrySnapshot]
    ) -> EntrySnapshot? {
        snapshots.max { lhs, rhs in
            let leftArchiveDate = lhs.archivedAt ?? .distantPast
            let rightArchiveDate = rhs.archivedAt ?? .distantPast

            return leftArchiveDate < rightArchiveDate
        }
    }

    private static func recentActivity(
        from snapshots: [EntrySnapshot],
        limit: Int
    ) -> [EntryActivitySummary] {
        snapshots
            .flatMap(activitySummaries)
            .sorted { lhs, rhs in
                compare(rhs.date, lhs.date, tieBreak: lhs.title < rhs.title)
            }
            .prefix(max(0, limit))
            .map(\.self)
    }

    private static func activitySummaries(
        for snapshot: EntrySnapshot
    ) -> [EntryActivitySummary] {
        if let archivedAt = snapshot.archivedAt {
            return [
                .init(
                    entryID: snapshot.id,
                    title: snapshot.title,
                    kind: .archived,
                    date: archivedAt
                )
            ]
        }

        if snapshot.updatedAt != snapshot.createdAt {
            return [
                .init(
                    entryID: snapshot.id,
                    title: snapshot.title,
                    kind: .updated,
                    date: snapshot.updatedAt
                )
            ]
        }

        return [
            .init(
                entryID: snapshot.id,
                title: snapshot.title,
                kind: .added,
                date: snapshot.createdAt
            )
        ]
    }

    private static func titlePrecedes(
        _ lhs: EntrySnapshot,
        _ rhs: EntrySnapshot
    ) -> Bool {
        lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }

    private static func compare<T: Comparable>(
        _ lhs: T,
        _ rhs: T,
        tieBreak: Bool
    ) -> Bool {
        if lhs == rhs {
            return tieBreak
        }

        return lhs < rhs
    }
}
