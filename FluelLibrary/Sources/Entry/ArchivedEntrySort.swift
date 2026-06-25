import Foundation

/// Sort options for archived entries.
public enum ArchivedEntrySort: String, CaseIterable, Identifiable, Sendable {
    case recentlyArchived
    case oldestArchived
    case longestTogetherBeforeArchive
    case alphabetical

    public var id: Self {
        self
    }

    /// User-facing sort label.
    public var label: String {
        switch self {
        case .recentlyArchived:
            "Recently archived"
        case .oldestArchived:
            "Oldest archived"
        case .longestTogetherBeforeArchive:
            "Longest together before archive"
        case .alphabetical:
            "Alphabetical"
        }
    }
}
