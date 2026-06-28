import Foundation

/// Cross-surface entry use cases.
public enum EntryOperations {
    /// Creates validated entry input from an editable draft.
    public static func makeInput(
        from draft: EntryDraft,
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntryInput {
        try draft.makeInput(currentDate: currentDate, calendar: calendar)
    }

    /// Returns elapsed-time presentation for an entry snapshot.
    public static func timeTogether(
        for snapshot: EntrySnapshot,
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> TimeTogetherSummary {
        snapshot.timeTogether(referenceDate: referenceDate, calendar: calendar)
    }

    /// Returns the display label for a snapshot's known start.
    public static func startLabel(
        for snapshot: EntrySnapshot,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String {
        snapshot.startPrecision.startLabel(
            for: snapshot.startDate,
            calendar: calendar
        )
    }

    /// Returns the approximate start range for a snapshot, when applicable.
    public static func startRangeLabel(
        for snapshot: EntrySnapshot,
        calendar: Calendar = .autoupdatingCurrent
    ) -> String? {
        snapshot.startPrecision.startRangeLabel(
            for: snapshot.startDate,
            calendar: calendar
        )
    }

    /// Returns an archived snapshot.
    public static func archive(
        _ snapshot: EntrySnapshot,
        archivedAt: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntrySnapshot {
        guard !snapshot.isArchived else {
            return snapshot
        }

        return EntrySnapshot(
            id: snapshot.id,
            title: snapshot.title,
            startDate: snapshot.startDate,
            startPrecision: snapshot.startPrecision,
            createdAt: snapshot.createdAt,
            updatedAt: archivedAt,
            archivedAt: archivedAt,
            note: snapshot.note,
            hasPhoto: snapshot.hasPhoto,
            calendar: calendar
        )
    }

    /// Returns a restored active snapshot.
    public static func restore(
        _ snapshot: EntrySnapshot,
        restoredAt: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntrySnapshot {
        guard snapshot.isArchived else {
            return snapshot
        }

        return EntrySnapshot(
            id: snapshot.id,
            title: snapshot.title,
            startDate: snapshot.startDate,
            startPrecision: snapshot.startPrecision,
            createdAt: snapshot.createdAt,
            updatedAt: restoredAt,
            archivedAt: nil,
            note: snapshot.note,
            hasPhoto: snapshot.hasPhoto,
            calendar: calendar
        )
    }

    /// Returns true when an entry is eligible for permanent deletion.
    public static func canDeletePermanently(_ snapshot: EntrySnapshot) -> Bool {
        snapshot.isArchived
    }

    /// Verifies that an entry can be permanently deleted.
    public static func validatePermanentDelete(for snapshot: EntrySnapshot) throws {
        guard canDeletePermanently(snapshot) else {
            throw EntryArchiveError.activeEntryCannotBeDeleted
        }
    }

    /// Returns active entries after applying search, filter, and sort.
    public static func activeEntries(
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
    public static func archivedEntries(
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
                archivedSortPrecedes(lhs, rhs, sort: sort)
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
            snapshot.startPrecision.label,
            snapshot.startPrecision.knownAsText,
            snapshot.startPrecision.startLabel(for: snapshot.startDate, calendar: calendar)
        ]

        if let note = snapshot.note {
            components.append(note)
        }

        if let rangeLabel = snapshot.startPrecision.startRangeLabel(
            for: snapshot.startDate,
            calendar: calendar
        ) {
            components.append(rangeLabel)
            components.append("Approximate start")
        }

        if snapshot.hasPhoto {
            components.append("Photo")
        }

        if let archivedAt = snapshot.archivedAt {
            components.append("Archived")
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
            compare(lhs.startDate, rhs.startDate, tieBreak: lhs.title < rhs.title)
        case .mostRecentStart:
            compare(rhs.startDate, lhs.startDate, tieBreak: lhs.title < rhs.title)
        case .alphabetical:
            titlePrecedes(lhs, rhs)
        case .recentlyUpdated:
            compare(rhs.updatedAt, lhs.updatedAt, tieBreak: titlePrecedes(lhs, rhs))
        }
    }

    private static func archivedSortPrecedes(
        _ lhs: EntrySnapshot,
        _ rhs: EntrySnapshot,
        sort: ArchivedEntrySort
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
                archivedDuration(rhs),
                archivedDuration(lhs),
                tieBreak: titlePrecedes(lhs, rhs)
            )
        case .alphabetical:
            titlePrecedes(lhs, rhs)
        }
    }

    private static func archivedDuration(_ snapshot: EntrySnapshot) -> TimeInterval {
        guard let archivedAt = snapshot.archivedAt else {
            return 0
        }

        return archivedAt.timeIntervalSince(snapshot.startDate)
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
