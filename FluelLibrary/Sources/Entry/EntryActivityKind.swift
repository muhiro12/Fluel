import Foundation

/// User-visible kinds of entry activity.
public enum EntryActivityKind: String, CaseIterable, Identifiable, Sendable {
    case added
    case updated
    case archived

    public var id: Self {
        self
    }

    /// User-facing activity label.
    public var label: String {
        switch self {
        case .added:
            "Added"
        case .updated:
            "Updated"
        case .archived:
            "Archived"
        }
    }
}
