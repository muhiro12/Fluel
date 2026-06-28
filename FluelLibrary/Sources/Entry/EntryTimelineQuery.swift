import Foundation

/// Query values for building a timeline slice.
public struct EntryTimelineQuery: Equatable, Sendable {
    /// Search text matched against entry titles and activity kinds.
    public let searchText: String
    /// Activity kind filter.
    public let filter: EntryActivityFilter
    /// Date scope.
    public let scope: EntryTimelineScope
    /// Maximum visible-entry milestones to include.
    public let milestoneLimit: Int

    /// Creates a timeline query.
    public init(
        searchText: String = "",
        filter: EntryActivityFilter = .all,
        scope: EntryTimelineScope = .recentYear,
        milestoneLimit: Int = 3
    ) {
        self.searchText = searchText
        self.filter = filter
        self.scope = scope
        self.milestoneLimit = milestoneLimit
    }
}
