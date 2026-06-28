import Foundation

/// Timeline activity grouped by month.
public struct EntryTimelineMonth: Equatable, Identifiable, Sendable {
    /// Stable month identifier.
    public let id: String
    /// First day of the represented month.
    public let monthDate: Date
    /// Activity visible in this month.
    public let activity: [EntryActivitySummary]

    /// Added activity count.
    public var addedCount: Int {
        activity.filter { item in
            item.kind == .added
        }
        .count
    }

    /// Updated activity count.
    public var updatedCount: Int {
        activity.filter { item in
            item.kind == .updated
        }
        .count
    }

    /// Archived activity count.
    public var archivedCount: Int {
        activity.filter { item in
            item.kind == .archived
        }
        .count
    }

    /// Creates a timeline month.
    public init(
        monthDate: Date,
        activity: [EntryActivitySummary],
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let year = calendar.component(.year, from: monthDate)
        let month = calendar.component(.month, from: monthDate)

        id = "\(year)-\(month)"
        self.monthDate = monthDate
        self.activity = activity
    }
}
