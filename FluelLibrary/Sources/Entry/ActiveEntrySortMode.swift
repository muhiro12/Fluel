import Foundation

/// Supported ordering options for active entry collections.
public enum ActiveEntrySortMode: String, CaseIterable, Sendable {
    case oldestFirst
    case newestFirst
    case alphabetical
}
