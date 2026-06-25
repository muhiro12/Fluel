import Foundation

/// Complete timeline operation result.
public struct EntryTimelineResult: Equatable, Sendable {
    /// Visible timeline summary.
    public let summary: EntryTimelineSummary
    /// Visible activity grouped by month.
    public let months: [EntryTimelineMonth]
    /// Upcoming milestones related to visible active entries.
    public let upcomingMilestones: [EntryMilestone]

    /// Creates a timeline result.
    public init(
        summary: EntryTimelineSummary,
        months: [EntryTimelineMonth],
        upcomingMilestones: [EntryMilestone]
    ) {
        self.summary = summary
        self.months = months
        self.upcomingMilestones = upcomingMilestones
    }
}
