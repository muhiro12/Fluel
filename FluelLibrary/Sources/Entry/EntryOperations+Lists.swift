import Foundation

public extension EntryOperations {
    /// Returns active entries after applying search, filter, and sort.
    static func activeEntries(
        from snapshots: [EntrySnapshot],
        searchText: String = "",
        filter: EntryListFilter = .all,
        sort: ActiveEntrySort = .longestTogether,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [EntrySnapshot] {
        snapshots
            .filter { snapshot in
                !snapshot.isArchived
            }
            .filter { snapshot in
                matches(snapshot, searchText: searchText, filter: filter, calendar: calendar)
            }
            .sorted { lhs, rhs in
                activeSortPrecedes(lhs, rhs, sort: sort)
            }
    }

    /// Returns archived entries after applying search, filter, and sort.
    static func archivedEntries(
        from snapshots: [EntrySnapshot],
        searchText: String = "",
        filter: EntryListFilter = .all,
        sort: ArchivedEntrySort = .recentlyArchived,
        calendar: Calendar = .autoupdatingCurrent
    ) -> [EntrySnapshot] {
        snapshots
            .filter(\.isArchived)
            .filter { snapshot in
                matches(snapshot, searchText: searchText, filter: filter, calendar: calendar)
            }
            .sorted { lhs, rhs in
                archivedSortPrecedes(
                    lhs,
                    rhs,
                    sort: sort,
                    calendar: calendar
                )
            }
    }

    private static func matches(
        _ snapshot: EntrySnapshot,
        searchText: String,
        filter: EntryListFilter,
        calendar: Calendar
    ) -> Bool {
        guard matches(snapshot, filter: filter) else {
            return false
        }

        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearchText.isEmpty else {
            return true
        }

        return searchableText(for: snapshot, calendar: calendar)
            .localizedCaseInsensitiveContains(trimmedSearchText)
    }

    private static func matches(
        _ snapshot: EntrySnapshot,
        filter: EntryListFilter
    ) -> Bool {
        switch filter {
        case .all:
            true
        case .withNote:
            snapshot.hasNote
        case .withPhoto:
            snapshot.hasPhoto
        }
    }

    private static func searchableText(
        for snapshot: EntrySnapshot,
        calendar: Calendar
    ) -> String {
        var components = [
            snapshot.title,
            snapshot.start.precision.label,
            snapshot.start.precision.knownAsText,
            snapshot.start.precision.startLabel(for: snapshot.start, calendar: calendar)
        ]

        if let note = snapshot.note {
            components.append(note)
        }

        if let rangeLabel = snapshot.start.precision.startRangeLabel(
            for: snapshot.start,
            calendar: calendar
        ) {
            components.append(rangeLabel)
            components.append(EntryLocalization.string("Approximate start"))
        }

        if snapshot.hasPhoto {
            components.append(EntryLocalization.string("Photo"))
        }

        if let archivedAt = snapshot.archivedAt {
            components.append(EntryLocalization.string("Archived"))
            components.append(archivedAt.formatted(date: .abbreviated, time: .omitted))
        }

        return components.joined(separator: " ")
    }

    private static func activeSortPrecedes(
        _ lhs: EntrySnapshot,
        _ rhs: EntrySnapshot,
        sort: ActiveEntrySort
    ) -> Bool {
        switch sort {
        case .longestTogether:
            compare(
                lhs.start.calculationDate,
                rhs.start.calculationDate,
                tieBreak: lhs.title < rhs.title
            )
        case .mostRecentStart:
            compare(
                rhs.start.calculationDate,
                lhs.start.calculationDate,
                tieBreak: lhs.title < rhs.title
            )
        case .alphabetical:
            titlePrecedes(lhs, rhs)
        case .recentlyUpdated:
            compare(rhs.updatedAt, lhs.updatedAt, tieBreak: titlePrecedes(lhs, rhs))
        }
    }

    private static func archivedSortPrecedes(
        _ lhs: EntrySnapshot,
        _ rhs: EntrySnapshot,
        sort: ArchivedEntrySort,
        calendar: Calendar
    ) -> Bool {
        switch sort {
        case .recentlyArchived:
            compare(
                rhs.archivedAt ?? .distantPast,
                lhs.archivedAt ?? .distantPast,
                tieBreak: titlePrecedes(lhs, rhs)
            )
        case .oldestArchived:
            compare(
                lhs.archivedAt ?? .distantFuture,
                rhs.archivedAt ?? .distantFuture,
                tieBreak: titlePrecedes(lhs, rhs)
            )
        case .longestTogetherBeforeArchive:
            compare(
                archivedDuration(rhs, calendar: calendar),
                archivedDuration(lhs, calendar: calendar),
                tieBreak: titlePrecedes(lhs, rhs)
            )
        case .alphabetical:
            titlePrecedes(lhs, rhs)
        }
    }

    private static func archivedDuration(
        _ snapshot: EntrySnapshot,
        calendar: Calendar
    ) -> TimeInterval {
        guard let archivedAt = snapshot.archivedAt,
              let archiveStart = try? EntryStart(
                date: archivedAt,
                precision: .day,
                timeZone: calendar.timeZone
              ) else {
            return 0
        }

        return max(
            0,
            archiveStart.calculationDate.timeIntervalSince(snapshot.start.calculationDate)
        )
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
