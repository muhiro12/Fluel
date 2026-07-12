import Foundation

/// Validated input for creating or updating an entry.
public struct EntryInput: Equatable, Sendable {
    /// Trimmed entry title.
    public let title: String
    /// Optional trimmed note text.
    public let note: String?
    /// Validated calendar date when the entry started.
    public let start: EntryStart

    /// Creates validated entry input.
    public init(
        title: String,
        start: EntryStart,
        note: String? = nil,
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw EntryValidationError.emptyTitle
        }

        let currentStart = try EntryStart(
            date: currentDate,
            precision: .day,
            timeZone: calendar.timeZone
        )

        guard start <= currentStart else {
            throw EntryValidationError.futureStart
        }

        self.title = trimmedTitle
        self.note = Self.normalizedNote(note)
        self.start = start
    }

    private static func normalizedNote(_ note: String?) -> String? {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let trimmedNote,
              !trimmedNote.isEmpty else {
            return nil
        }

        return trimmedNote
    }
}
