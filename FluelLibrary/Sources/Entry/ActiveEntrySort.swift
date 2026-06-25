import Foundation

/// Sort options for entries still with the user in daily life.
public enum ActiveEntrySort: String, CaseIterable, Identifiable, Sendable {
    case longestTogether
    case mostRecentStart
    case alphabetical
    case recentlyUpdated

    public var id: Self {
        self
    }

    /// User-facing sort label.
    public var label: String {
        switch self {
        case .longestTogether:
            "Longest together"
        case .mostRecentStart:
            "Most recent start"
        case .alphabetical:
            "Alphabetical"
        case .recentlyUpdated:
            "Recently updated"
        }
    }
}
