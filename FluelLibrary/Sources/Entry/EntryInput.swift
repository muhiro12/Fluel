import Foundation

/// Validated input for creating or updating an entry.
public struct EntryInput: Equatable, Sendable {
    /// Trimmed entry title.
    public let title: String
    /// Normalized start date.
    public let startDate: Date
    /// Known start precision.
    public let startPrecision: StartPrecision

    /// Creates validated entry input.
    public init(
        title: String,
        startDate: Date,
        startPrecision: StartPrecision,
        calendar: Calendar = .autoupdatingCurrent
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw EntryValidationError.emptyTitle
        }

        self.title = trimmedTitle
        self.startDate = startPrecision.normalizedStartDate(
            from: startDate,
            calendar: calendar
        )
        self.startPrecision = startPrecision
    }
}
