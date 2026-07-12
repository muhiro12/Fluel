import Foundation

/// User-visible kinds of entry activity.
public enum EntryActivityKind: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
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
            EntryLocalization.string("Added")
        case .updated:
            EntryLocalization.string("Updated")
        case .archived:
            EntryLocalization.string("Archived")
        }
    }
}
