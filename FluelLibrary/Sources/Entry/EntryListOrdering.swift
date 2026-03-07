import Foundation

/// Shared ordering rules for active and archived entry collections.
public enum EntryListOrdering {
    public static func active(
        _ entries: [Entry],
        calendar: Calendar = .autoupdatingCurrent
    ) -> [Entry] {
        entries.sorted { lhs, rhs in
            let lhsDate = lhs.startComponents.earliestDate(calendar: calendar) ?? .distantPast
            let rhsDate = rhs.startComponents.earliestDate(calendar: calendar) ?? .distantPast

            if lhsDate != rhsDate {
                return lhsDate < rhsDate
            }

            if lhs.startPrecision != rhs.startPrecision {
                return precisionRank(lhs.startPrecision) < precisionRank(rhs.startPrecision)
            }

            let titleComparison = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
            if titleComparison != .orderedSame {
                return titleComparison == .orderedAscending
            }

            return lhs.createdAt < rhs.createdAt
        }
    }

    public static func archived(
        _ entries: [Entry]
    ) -> [Entry] {
        entries.sorted { lhs, rhs in
            let lhsArchivedAt = lhs.archivedAt ?? .distantPast
            let rhsArchivedAt = rhs.archivedAt ?? .distantPast

            if lhsArchivedAt != rhsArchivedAt {
                return lhsArchivedAt > rhsArchivedAt
            }

            if lhs.updatedAt != rhs.updatedAt {
                return lhs.updatedAt > rhs.updatedAt
            }

            let titleComparison = lhs.title.localizedCaseInsensitiveCompare(rhs.title)

            return titleComparison == .orderedAscending
        }
    }

    public static func leadActiveEntry(
        from entries: [Entry],
        calendar: Calendar = .autoupdatingCurrent
    ) -> Entry? {
        active(
            entries.filter { entry in
                entry.isArchived == false
            },
            calendar: calendar
        ).first
    }
}

private extension EntryListOrdering {
    static func precisionRank(
        _ precision: EntryDatePrecision
    ) -> Int {
        switch precision {
        case .year:
            return 0
        case .month:
            return 1
        case .day:
            return 2
        }
    }
}
