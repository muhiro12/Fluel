import Foundation

public extension EntryOperations {
    /// Returns timeline activity grouped by month.
    static func timeline(
        from snapshots: [EntrySnapshot],
        query: EntryTimelineQuery = .init(),
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryTimelineResult {
        let allActivity = snapshots.flatMap(fullActivitySummaries)
        let visibleActivity = allActivity.filter { activity in
            isVisible(
                activity,
                query: query,
                referenceDate: referenceDate,
                calendar: calendar
            )
        }
        let months = groupedMonths(from: visibleActivity, calendar: calendar)
        let visibleEntryIDs = Set(visibleActivity.map(\.entryID))
        let visibleActiveSnapshots = snapshots.filter { snapshot in
            !snapshot.isArchived && visibleEntryIDs.contains(snapshot.id)
        }

        return .init(
            summary: summary(
                totalActivityCount: allActivity.count,
                visibleActivity: visibleActivity,
                representedMonthCount: months.count
            ),
            months: months,
            upcomingMilestones: upcomingMilestones(
                from: visibleActiveSnapshots,
                referenceDate: referenceDate,
                calendar: calendar,
                limit: query.milestoneLimit
            )
        )
    }

    private static func fullActivitySummaries(
        for snapshot: EntrySnapshot
    ) -> [EntryActivitySummary] {
        var summaries = [
            EntryActivitySummary(
                entryID: snapshot.id,
                title: snapshot.title,
                kind: .added,
                date: snapshot.createdAt
            )
        ]

        if snapshot.updatedAt != snapshot.createdAt,
           snapshot.updatedAt != snapshot.archivedAt {
            summaries.append(.init(
                entryID: snapshot.id,
                title: snapshot.title,
                kind: .updated,
                date: snapshot.updatedAt
            ))
        }

        if let archivedAt = snapshot.archivedAt {
            summaries.append(.init(
                entryID: snapshot.id,
                title: snapshot.title,
                kind: .archived,
                date: archivedAt
            ))
        }

        return summaries
    }

    private static func isVisible(
        _ activity: EntryActivitySummary,
        query: EntryTimelineQuery,
        referenceDate: Date,
        calendar: Calendar
    ) -> Bool {
        query.filter.contains(activity.kind)
            && isWithinScope(
                activity.date,
                scope: query.scope,
                referenceDate: referenceDate,
                calendar: calendar
            )
            && matches(activity, searchText: query.searchText)
    }

    private static func isWithinScope(
        _ date: Date,
        scope: EntryTimelineScope,
        referenceDate: Date,
        calendar: Calendar
    ) -> Bool {
        guard let startDate = scope.startDate(referenceDate: referenceDate, calendar: calendar) else {
            return true
        }

        return date >= startDate
    }

    private static func matches(
        _ activity: EntryActivitySummary,
        searchText: String
    ) -> Bool {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearchText.isEmpty else {
            return true
        }

        return [
            activity.title,
            activity.kind.label
        ]
        .joined(separator: " ")
        .localizedCaseInsensitiveContains(trimmedSearchText)
    }

    private static func groupedMonths(
        from activity: [EntryActivitySummary],
        calendar: Calendar
    ) -> [EntryTimelineMonth] {
        let groupedActivity = Dictionary(grouping: activity) { item in
            monthStart(for: item.date, calendar: calendar)
        }

        return groupedActivity.keys
            .sorted(by: >)
            .map { monthDate in
                EntryTimelineMonth(
                    monthDate: monthDate,
                    activity: groupedActivity[monthDate, default: []].sorted { lhs, rhs in
                        compare(rhs.date, lhs.date, tieBreak: lhs.title < rhs.title)
                    },
                    calendar: calendar
                )
            }
    }

    private static func summary(
        totalActivityCount: Int,
        visibleActivity: [EntryActivitySummary],
        representedMonthCount: Int
    ) -> EntryTimelineSummary {
        .init(
            totalActivityCount: totalActivityCount,
            visibleActivityCount: visibleActivity.count,
            representedMonthCount: representedMonthCount,
            addedCount: count(.added, in: visibleActivity),
            updatedCount: count(.updated, in: visibleActivity),
            archivedCount: count(.archived, in: visibleActivity)
        )
    }

    private static func count(
        _ kind: EntryActivityKind,
        in activity: [EntryActivitySummary]
    ) -> Int {
        activity.filter { item in
            item.kind == kind
        }
        .count
    }

    private static func monthStart(
        for date: Date,
        calendar: Calendar
    ) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)

        return calendar.date(from: DateComponents(
            calendar: calendar,
            year: components.year,
            month: components.month,
            day: 1
        )) ?? calendar.startOfDay(for: date)
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
