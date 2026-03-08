import Foundation

/// Aggregate counts for the currently visible activity timeline.
public struct EntryActivityTimelineSummary: Equatable, Sendable {
    public let totalCount: Int
    public let displayedCount: Int
    public let monthCount: Int
    public let addedCount: Int
    public let updatedCount: Int
    public let archivedCount: Int

    public init(
        totalCount: Int,
        displayedCount: Int,
        monthCount: Int,
        addedCount: Int,
        updatedCount: Int,
        archivedCount: Int
    ) {
        self.totalCount = totalCount
        self.displayedCount = displayedCount
        self.monthCount = monthCount
        self.addedCount = addedCount
        self.updatedCount = updatedCount
        self.archivedCount = archivedCount
    }
}

/// Query helpers that describe the visible shape of the activity timeline.
public enum EntryActivityTimelineSummaryQuery {
    public static func summary(
        totalActivity: [EntryActivitySnapshot],
        displayedActivity: [EntryActivitySnapshot],
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryActivityTimelineSummary {
        let monthCount = Set(
            displayedActivity.map { snapshot in
                monthBucket(
                    for: snapshot.timestamp,
                    calendar: calendar
                )
            }
        ).count

        return .init(
            totalCount: totalActivity.count,
            displayedCount: displayedActivity.count,
            monthCount: monthCount,
            addedCount: displayedActivity.count { $0.kind == .added },
            updatedCount: displayedActivity.count { $0.kind == .updated },
            archivedCount: displayedActivity.count { $0.kind == .archived }
        )
    }
}

private extension EntryActivityTimelineSummaryQuery {
    static func monthBucket(
        for date: Date,
        calendar: Calendar
    ) -> DateComponents {
        calendar.dateComponents(
            [.year, .month],
            from: date
        )
    }
}
