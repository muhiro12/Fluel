import Foundation

/// Collection overview values for the Dashboard.
public struct EntryDashboardSummary: Equatable, Sendable {
    /// Total entry count.
    public let totalCount: Int
    /// Active entry count.
    public let activeCount: Int
    /// Archived entry count.
    public let archivedCount: Int
    /// Entries with note content.
    public let noteCount: Int
    /// Entries with photo content.
    public let photoCount: Int
    /// Longest-running active entry.
    public let longestRunningActiveEntry: EntrySnapshot?
    /// Most recently archived entry.
    public let recentlyArchivedEntry: EntrySnapshot?
    /// Upcoming yearly milestones.
    public let upcomingMilestones: [EntryMilestone]
    /// Recent entry activity.
    public let recentActivity: [EntryActivitySummary]

    /// Creates a dashboard summary.
    public init(
        totalCount: Int,
        activeCount: Int,
        archivedCount: Int,
        noteCount: Int,
        photoCount: Int,
        longestRunningActiveEntry: EntrySnapshot?,
        recentlyArchivedEntry: EntrySnapshot?,
        upcomingMilestones: [EntryMilestone],
        recentActivity: [EntryActivitySummary]
    ) {
        self.totalCount = totalCount
        self.activeCount = activeCount
        self.archivedCount = archivedCount
        self.noteCount = noteCount
        self.photoCount = photoCount
        self.longestRunningActiveEntry = longestRunningActiveEntry
        self.recentlyArchivedEntry = recentlyArchivedEntry
        self.upcomingMilestones = upcomingMilestones
        self.recentActivity = recentActivity
    }
}
