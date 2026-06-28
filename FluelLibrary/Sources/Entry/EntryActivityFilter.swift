import Foundation

/// Timeline activity filter.
public enum EntryActivityFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case added
    case updated
    case archived

    public var id: Self {
        self
    }

    /// User-facing filter label.
    public var label: String {
        switch self {
        case .all:
            EntryLocalization.string("All activity")
        case .added:
            EntryLocalization.string("Added")
        case .updated:
            EntryLocalization.string("Updated")
        case .archived:
            EntryLocalization.string("Archived")
        }
    }

    /// Returns true when the filter includes the activity kind.
    public func contains(_ kind: EntryActivityKind) -> Bool {
        switch self {
        case .all:
            true
        case .added:
            kind == .added
        case .updated:
            kind == .updated
        case .archived:
            kind == .archived
        }
    }
}
