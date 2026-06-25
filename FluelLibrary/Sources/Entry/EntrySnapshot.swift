import Foundation

/// Stable entry values that app, widget, intent, or preview adapters can share.
public struct EntrySnapshot: Equatable, Identifiable, Sendable {
    /// Stable entry identifier.
    public let id: UUID
    /// Entry title.
    public let title: String
    /// Normalized start date.
    public let startDate: Date
    /// Known start precision.
    public let startPrecision: StartPrecision
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

    /// Creates a stable entry snapshot.
    public init(
        id: UUID,
        title: String,
        startDate: Date,
        startPrecision: StartPrecision,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date?,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.id = id
        self.title = title
        self.startDate = startPrecision.normalizedStartDate(
            from: startDate,
            calendar: calendar
        )
        self.startPrecision = startPrecision
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
    }

    /// Returns elapsed-time presentation for this snapshot.
    public func timeTogether(
        referenceDate: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) -> TimeTogetherSummary {
        TimeTogetherSummary(
            startDate: startDate,
            precision: startPrecision,
            referenceDate: referenceDate,
            calendar: calendar
        )
    }
}
