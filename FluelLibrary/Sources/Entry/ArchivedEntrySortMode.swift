import Foundation

/// Supported ordering options for archived entry collections.
public enum ArchivedEntrySortMode: String, CaseIterable, Sendable {
    case recentlyArchived
    case oldestArchived
    case longestTogether
    case alphabetical
}
