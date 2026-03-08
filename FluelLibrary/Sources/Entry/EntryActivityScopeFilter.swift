import Foundation

/// Visible scope options for narrowing timeline activity by recency.
public enum EntryActivityScopeMode: String, CaseIterable, Sendable {
    case recentSixMonths
    case recentYear
    case allTime
}

/// Filters activity snapshots to a visible time window.
public enum EntryActivityScopeFilter {
    public static func filter(
        _ activity: [EntryActivitySnapshot],
        mode: EntryActivityScopeMode,
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [EntryActivitySnapshot] {
        guard let cutoffDate = cutoffDate(
            for: mode,
            referenceDate: referenceDate,
            calendar: calendar
        ) else {
            return activity
        }

        return activity.filter { snapshot in
            snapshot.timestamp >= cutoffDate
        }
    }
}

private extension EntryActivityScopeFilter {
    static func cutoffDate(
        for mode: EntryActivityScopeMode,
        referenceDate: Date,
        calendar: Calendar
    ) -> Date? {
        guard mode != .allTime else {
            return nil
        }

        let monthStart = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: referenceDate
            )
        ) ?? referenceDate

        let monthsToSubtract: Int
        switch mode {
        case .recentSixMonths:
            monthsToSubtract = 5
        case .recentYear:
            monthsToSubtract = 11
        case .allTime:
            return nil
        }

        return calendar.date(
            byAdding: .month,
            value: -monthsToSubtract,
            to: monthStart
        ) ?? monthStart
    }
}
