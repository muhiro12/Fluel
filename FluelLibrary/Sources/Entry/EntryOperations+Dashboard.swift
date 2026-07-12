import Foundation

public extension EntryOperations {
    /// Returns collection overview values for the Dashboard.
    static func dashboardSummary(
        from snapshots: [EntrySnapshot],
        activity: [EntryActivitySummary],
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
            recentActivity: recentActivity(from: activity, limit: activityLimit)
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
        from activity: [EntryActivitySummary],
        limit: Int
    ) -> [EntryActivitySummary] {
        activity
            .sorted { lhs, rhs in
                compare(
                    rhs.date,
                    lhs.date,
                    tieBreak: lhs.id.uuidString < rhs.id.uuidString
                )
            }
            .prefix(max(0, limit))
            .map(\.self)
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
