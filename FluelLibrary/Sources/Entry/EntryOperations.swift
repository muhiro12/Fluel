import Foundation

/// Cross-surface entry use cases.
public enum EntryOperations {
    /// Creates an editable draft from an entry snapshot.
    public static func makeDraft(
        from snapshot: EntrySnapshot,
        calendar: Calendar = .autoupdatingCurrent
    ) -> EntryDraft {
        let startComponents = calendar.dateComponents(
            [.year, .month],
            from: snapshot.startDate
        )

        return .init(
            title: snapshot.title,
            note: snapshot.note ?? "",
            precision: snapshot.startPrecision,
            dayDate: snapshot.startDate,
            month: startComponents.month,
            year: startComponents.year,
            calendar: calendar
        )
    }

    /// Creates validated entry input from an editable draft.
    public static func makeInput(
        from draft: EntryDraft,
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntryInput {
        try draft.makeInput(currentDate: currentDate, calendar: calendar)
    }

    /// Returns an updated snapshot after validating editable draft values.
    ///
    /// Identity, creation, archive, and photo state remain unchanged.
    public static func update(
        _ snapshot: EntrySnapshot,
        from draft: EntryDraft,
        updatedAt: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> EntrySnapshot {
        let input = try makeInput(
            from: draft,
            currentDate: updatedAt,
            calendar: calendar
        )

        return .init(
            id: snapshot.id,
            title: input.title,
            startDate: input.startDate,
            startPrecision: input.startPrecision,
            createdAt: snapshot.createdAt,
            updatedAt: updatedAt,
            archivedAt: snapshot.archivedAt,
            note: input.note,
            hasPhoto: snapshot.hasPhoto,
            calendar: calendar
        )
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
}
