import Foundation

/// Monthly aggregate snapshot derived from timeline activity.
public struct EntryActivityTrendSnapshot: Equatable, Sendable {
    public let monthStart: Date
    public let title: String
    public let totalCount: Int
    public let addedCount: Int
    public let updatedCount: Int
    public let archivedCount: Int

    public init(
        monthStart: Date,
        title: String,
        totalCount: Int,
        addedCount: Int,
        updatedCount: Int,
        archivedCount: Int
    ) {
        self.monthStart = monthStart
        self.title = title
        self.totalCount = totalCount
        self.addedCount = addedCount
        self.updatedCount = updatedCount
        self.archivedCount = archivedCount
    }
}

/// Query helpers that summarize visible timeline activity into monthly trends.
public enum EntryActivityTrendSnapshotQuery {
    public static func recentMonths(
        activity: [EntryActivitySnapshot],
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        limit: Int = 4
    ) -> [EntryActivityTrendSnapshot] {
        guard limit > 0 else {
            return []
        }

        let groupedActivity = Dictionary(grouping: activity) { snapshot in
            monthStart(
                for: snapshot.timestamp,
                calendar: calendar
            )
        }

        return groupedActivity
            .keys
            .sorted(by: >)
            .prefix(limit)
            .compactMap { monthStart in
                guard let monthActivity = groupedActivity[monthStart] else {
                    return nil
                }

                return .init(
                    monthStart: monthStart,
                    title: monthTitle(
                        for: monthStart,
                        locale: locale
                    ),
                    totalCount: monthActivity.count,
                    addedCount: monthActivity.count { $0.kind == .added },
                    updatedCount: monthActivity.count { $0.kind == .updated },
                    archivedCount: monthActivity.count { $0.kind == .archived }
                )
            }
    }
}

private extension EntryActivityTrendSnapshotQuery {
    static func monthStart(
        for date: Date,
        calendar: Calendar
    ) -> Date {
        let components = calendar.dateComponents(
            [.year, .month],
            from: date
        )
        return calendar.date(from: components) ?? date
    }

    static func monthTitle(
        for monthStart: Date,
        locale: Locale
    ) -> String {
        monthStart.formatted(
            .dateTime
                .locale(locale)
                .year()
                .month(.wide)
        )
    }
}
