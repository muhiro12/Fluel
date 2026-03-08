import Foundation
import SwiftData

/// Timeline section that groups entry activity snapshots by month.
public struct EntryActivityTimelineSection: Equatable, Sendable {
    public let monthStart: Date
    public let title: String
    public let items: [EntryActivitySnapshot]

    public init(
        monthStart: Date,
        title: String,
        items: [EntryActivitySnapshot]
    ) {
        self.monthStart = monthStart
        self.title = title
        self.items = items
    }
}

/// Query helpers that group entry activity into month-based timeline sections.
public enum EntryActivityTimelineSectionQuery {
    public static func sections(
        context: ModelContext,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        limit: Int = 6
    ) throws -> [EntryActivityTimelineSection] {
        sections(
            entries: try EntryRepository.fetchAllEntries(context: context),
            locale: locale,
            calendar: calendar,
            limit: limit
        )
    }

    public static func sections(
        entries: [Entry],
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        limit: Int = 6
    ) -> [EntryActivityTimelineSection] {
        let activity = EntryActivitySnapshotQuery.recent(
            entries: entries,
            limit: max(entries.count, limit)
        )

        return sections(
            activity: activity,
            locale: locale,
            calendar: calendar,
            limit: limit
        )
    }

    public static func sections(
        activity: [EntryActivitySnapshot],
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        limit: Int = 6
    ) -> [EntryActivityTimelineSection] {
        guard limit > 0 else {
            return []
        }

        let groupedActivity = Dictionary(grouping: activity) { snapshot in
            monthStartDate(
                for: snapshot.timestamp,
                calendar: calendar
            )
        }

        return groupedActivity.keys
            .sorted(by: >)
            .prefix(limit)
            .compactMap { monthStart in
                guard let items = groupedActivity[monthStart] else {
                    return nil
                }

                return .init(
                    monthStart: monthStart,
                    title: monthTitle(
                        for: monthStart,
                        locale: locale,
                        calendar: calendar
                    ),
                    items: items.sorted(by: sortActivity)
                )
            }
    }
}

private extension EntryActivityTimelineSectionQuery {
    static func monthStartDate(
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
        for date: Date,
        locale: Locale,
        calendar: Calendar
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")

        return formatter.string(from: date)
    }

    static func sortActivity(
        lhs: EntryActivitySnapshot,
        rhs: EntryActivitySnapshot
    ) -> Bool {
        if lhs.timestamp != rhs.timestamp {
            return lhs.timestamp > rhs.timestamp
        }

        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }
}
