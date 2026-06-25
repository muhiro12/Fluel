import Foundation

/// Summary for the visible timeline slice.
public struct EntryTimelineSummary: Equatable, Sendable {
    /// Total activity count before visible filters.
    public let totalActivityCount: Int
    /// Visible activity count.
    public let visibleActivityCount: Int
    /// Number of represented months.
    public let representedMonthCount: Int
    /// Visible added count.
    public let addedCount: Int
    /// Visible updated count.
    public let updatedCount: Int
    /// Visible archived count.
    public let archivedCount: Int

    /// Creates a timeline summary.
    public init(
        totalActivityCount: Int,
        visibleActivityCount: Int,
        representedMonthCount: Int,
        addedCount: Int,
        updatedCount: Int,
        archivedCount: Int
    ) {
        self.totalActivityCount = totalActivityCount
        self.visibleActivityCount = visibleActivityCount
        self.representedMonthCount = representedMonthCount
        self.addedCount = addedCount
        self.updatedCount = updatedCount
        self.archivedCount = archivedCount
    }
}
