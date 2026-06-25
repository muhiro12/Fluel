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

    private static func upcomingMilestones(
        from snapshots: [EntrySnapshot],
        referenceDate: Date,
        calendar: Calendar,
        limit: Int
    ) -> [EntryMilestone] {
        snapshots
            .compactMap { snapshot in
                upcomingMilestone(for: snapshot, referenceDate: referenceDate, calendar: calendar)
            }
            .sorted { lhs, rhs in
                compare(lhs.date, rhs.date, tieBreak: lhs.title < rhs.title)
            }
            .prefix(max(0, limit))
            .map(\.self)
    }

    private static func upcomingMilestone(
        for snapshot: EntrySnapshot,
        referenceDate: Date,
        calendar: Calendar
    ) -> EntryMilestone? {
        let normalizedReferenceDate = calendar.startOfDay(for: referenceDate)
        let normalizedStartDate = calendar.startOfDay(for: snapshot.startDate)
        var durationYears = max(
            1,
            calendar.dateComponents(
                [.year],
                from: normalizedStartDate,
                to: normalizedReferenceDate
            ).year ?? 0
        )

        guard var milestoneDate = calendar.date(
            byAdding: .year,
            value: durationYears,
            to: normalizedStartDate
        ) else {
            return nil
        }

        while milestoneDate < normalizedReferenceDate {
            durationYears += 1

            guard let nextMilestoneDate = calendar.date(
                byAdding: .year,
                value: durationYears,
                to: normalizedStartDate
            ) else {
                return nil
            }

            milestoneDate = nextMilestoneDate
        }

        let daysRemaining = max(
            0,
            calendar.dateComponents(
                [.day],
                from: normalizedReferenceDate,
                to: milestoneDate
            ).day ?? 0
        )

        return .init(
            entryID: snapshot.id,
            title: snapshot.title,
            durationYears: durationYears,
            date: milestoneDate,
            daysRemaining: daysRemaining,
            isApproximate: snapshot.startPrecision.isApproximate
        )
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
