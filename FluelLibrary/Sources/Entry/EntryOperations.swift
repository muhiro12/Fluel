import Foundation

/// Cross-surface entry use cases.
public enum EntryOperations {
    /// Creates validated entry input from an editable draft.
    public static func makeInput(
        from draft: EntryDraft,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntryInput {
        try draft.makeInput(calendar: calendar)
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
}
