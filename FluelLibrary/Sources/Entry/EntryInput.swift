import Foundation

/// Validated input for creating or updating an entry.
public struct EntryInput: Equatable, Sendable {
    /// Trimmed entry title.
    public let title: String
    /// Optional trimmed note text.
    public let note: String?
    /// Normalized start date.
    public let startDate: Date
    /// Known start precision.
    public let startPrecision: StartPrecision

    /// Creates validated entry input.
    public init(
        title: String,
        startDate: Date,
        startPrecision: StartPrecision,
        note: String? = nil,
        calendar: Calendar = .autoupdatingCurrent
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw EntryValidationError.emptyTitle
        }

        self.title = trimmedTitle
        self.note = Self.normalizedNote(note)
        self.startDate = startPrecision.normalizedStartDate(
            from: startDate,
            calendar: calendar
        )
        self.startPrecision = startPrecision
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
