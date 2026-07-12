import Foundation

/// Stable entry values that app, widget, intent, or preview adapters can share.
public struct EntrySnapshot: Equatable, Identifiable, Sendable {
    /// Stable entry identifier.
    public let id: UUID
    /// Entry title.
    public let title: String
    /// Optional note text.
    public let note: String?
    /// True when the entry has photo content.
    public let hasPhoto: Bool
    /// Calendar date when the entry started.
    public let start: EntryStart
    /// Creation date.
    public let createdAt: Date
    /// Last update date.
    public let updatedAt: Date
    /// Archive date when the entry is archived.
    public let archivedAt: Date?

    /// True when the entry is archived.
    public var isArchived: Bool {
        archivedAt != nil
    }

    /// True when the entry has note content.
    public var hasNote: Bool {
        note != nil
    }

    /// Creates a stable entry snapshot.
    public init(
        id: UUID,
        title: String,
        start: EntryStart,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date?,
        note: String? = nil,
        hasPhoto: Bool = false
    ) {
        self.id = id
        self.title = title
        self.note = Self.normalizedNote(note)
        self.hasPhoto = hasPhoto
        self.start = start
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }

    private static func normalizedNote(_ note: String?) -> String? {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let trimmedNote,
              !trimmedNote.isEmpty else {
            return nil
        }

        return trimmedNote
    }

    /// Returns elapsed-time presentation, stopping at the archive date when archived.
    public func timeTogether(
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> TimeTogetherSummary {
        let effectiveReferenceDate = archivedAt.map { archivedAt in
            min(referenceDate, archivedAt)
        } ?? referenceDate

        return TimeTogetherSummary(
            start: start,
            referenceDate: effectiveReferenceDate,
            calendar: calendar
        )
    }
}
