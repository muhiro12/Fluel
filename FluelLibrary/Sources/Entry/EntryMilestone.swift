import Foundation

/// Upcoming yearly milestone for an active entry.
public struct EntryMilestone: Equatable, Identifiable, Sendable {
    /// Stable milestone identifier.
    public let id: String
    /// Entry identifier.
    public let entryID: UUID
    /// Entry title.
    public let title: String
    /// Milestone duration in years.
    public let durationYears: Int
    /// Calendar date of the milestone.
    public let date: Date
    /// Days remaining from the reference date.
    public let daysRemaining: Int
    /// True when the milestone is based on an approximate start.
    public let isApproximate: Bool

    /// User-facing duration text.
    public var durationText: String {
        durationYears == 1 ? "1 year" : "\(durationYears.formatted()) years"
    }

    /// User-facing days-remaining text.
    public var daysRemainingText: String {
        switch daysRemaining {
        case 0:
            "Today"
        case 1:
            "1 day"
        default:
            "\(daysRemaining.formatted()) days"
        }
    }

    /// Creates an entry milestone.
    public init(
        entryID: UUID,
        title: String,
        durationYears: Int,
        date: Date,
        daysRemaining: Int,
        isApproximate: Bool
    ) {
        id = "\(entryID.uuidString)-\(durationYears)"
        self.entryID = entryID
        self.title = title
        self.durationYears = durationYears
        self.date = date
        self.daysRemaining = daysRemaining
        self.isApproximate = isApproximate
    }
}
