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
        currentDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw EntryValidationError.emptyTitle
        }

        let normalizedStartDate = startPrecision.normalizedStartDate(
            from: startDate,
            calendar: calendar
        )
        let normalizedCurrentDate = StartPrecision.day.normalizedStartDate(
            from: currentDate,
            calendar: calendar
        )

        guard normalizedStartDate <= normalizedCurrentDate else {
            throw EntryValidationError.futureStart
        }

        self.title = trimmedTitle
        self.note = Self.normalizedNote(note)
        self.startDate = normalizedStartDate
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
