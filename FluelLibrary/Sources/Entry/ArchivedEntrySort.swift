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
            EntryLocalization.string("Recently archived")
        case .oldestArchived:
            EntryLocalization.string("Oldest archived")
        case .longestTogetherBeforeArchive:
            EntryLocalization.string("Longest together before archive")
        case .alphabetical:
            EntryLocalization.string("Alphabetical")
        }
    }
}
