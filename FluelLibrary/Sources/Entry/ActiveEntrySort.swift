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
            EntryLocalization.string("Longest together")
        case .mostRecentStart:
            EntryLocalization.string("Most recent start")
        case .alphabetical:
            EntryLocalization.string("Alphabetical")
        case .recentlyUpdated:
            EntryLocalization.string("Recently updated")
        }
    }
}
